//
//  AppViewModel.swift
//  Atra
//
//  Created by Daniel Velikov on 3.07.25.
//

import SwiftUI

protocol CoinCacheProvider: AnyObject, Observable {
    var coinCache: [String] { get } // update to map
}

@Observable
final class AppViewModel: BaseAppViewModel, AppVersionEvaluator, CoinCacheProvider {
    // MARK: - Properties
    private(set) var requestState: RequestState = .notStarted
    
    private(set) var configIsValid: Bool = true
    private(set) var appConfig: AppConfig = AppConfig()
    
    private let configService: ConfigService
    
    private(set) var shouldDisableUI: Bool = false
    var shouldShowVersionUpdateNotification: Bool = false
    
    var notificationDuration: TimeInterval { GlobalConstants.notificationDuration }
    
    private(set) var coinCache: [String] = [] // Placeholder for coin cache, update to map if needed
    
    private let socketClient: WebSocketClient
    
    private var socketEventHandler: Task<Void, Never>?
    
    // MARK: - Initializer
    init(configService: ConfigService, socketClient: WebSocketClient) {
        self.configService = configService
        self.socketClient = socketClient
    }
    
    // MARK: Private
    private func buildSubscribeMessage() throws -> WebSocketMessage {
        let subscribeMessage = SubscribeMessage()
        let jsonData = try JSONEncoder().encode(subscribeMessage)
        
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            throw WebSocketError.invalidSubscribeMessage
        }
        
        return .string(jsonString)
    }
    
    private func startSocketEventListener() {
        stopWebSocketListenerIfNeeded()
        
        socketEventHandler = Task {
            await startWebSocketListener()
        }
    }
    
    private func stopWebSocketListenerIfNeeded() {
        guard socketEventHandler != nil else { return }
        
        socketEventHandler?.cancel()
        socketEventHandler = nil
    }
    
    // MARK: - Public
    func setupAppState() async {
        await fetchRemoteConfig()
        startConfigUpdateListener()
        
        await establishSocketConnection()
        startSocketEventListener()
    }
    
    func establishSocketConnection() async {
        guard configIsValid else { return }
        
        do {
            if await socketClient.isConnected {
                socketEventHandler?.cancel()
                socketEventHandler = nil
                await socketClient.disconnect(with: .normalClosure)
            }
            
            try await socketClient.connect(with: appConfig.webSocketConfig)
        } catch {
            print("Failed to establish WebSocket connection: \(error.localizedDescription)")
            // should be terminal error, handle accordingly
        }
    }
    
    func startWebSocketListener() async {
        do {
            let subscribeMessage = try buildSubscribeMessage()
            
            try await socketClient.send(subscribeMessage)
            
            for try await message in await socketClient.channel {
                print("Received WebSocket message \(message)")
                //try handleSocketMessage(message)
            }
        } catch {
            print("Error receiving WebSocket message: \(error.localizedDescription)")
            // Handle error accordingly, maybe reconnect or notify user
        }
    }
    
    func handleSocketMessage(_ message: WebSocketMessage) throws {
        let socketMessage: SocketMessage
        
        switch message {
        case .data(let data):
            socketMessage = try JSONDecoder().decode(SocketMessage.self, from: data)
        case .string(let data):
            socketMessage = try JSONDecoder().decode(SocketMessage.self, from: Data(data.utf8))
        @unknown default:
            throw WebSocketError.unsupportedMessageFormat
        }
        
        switch socketMessage.event {
        case .connection:
            print("WebSocket connection established.")
        case .status:
            print("WebSocket status update received.")
        case .cacheUpdate:
            print("Coin cache updated with")
        case .watchlist:
            let watchlist: [String] = try JSONDecoder().decode([String].self, from: socketMessage.data)
            print("Watchlist updated with \(watchlist.count) items.")
        case .error:
            let errorMessage = String(data: socketMessage.data, encoding: .utf8) ?? "Unknown error"
            print("WebSocket error received: \(errorMessage)")
        }
    }
    
    func fetchRemoteConfig() async {
        guard requestState != .inProgress else { return }
        
        requestState = .inProgress
        
        do {
            try await configService.fetch()
            
            handleAppVersionUpdate()
            handleWebSocketConfigUpdate()
            
            requestState = .success
        } catch {
            handleConfigError(error)
            requestState = .failure
        }
    }
    
    func userDidTapRetryButton() async {
        await fetchRemoteConfig()
    }
    
    // MARK: -- Config Fetch Error Handler
    func handleConfigError(_ error: Error) {
        configIsValid = false // should trigger blocking UI
    }
    
    // MARK: - Config Update Listener
    func startConfigUpdateListener() {
        Task {
            do {
                for try await updatedKeys in configService.updateStream {
                    handleConfigUpdate(for: updatedKeys)
                }
            } catch {
                handleUpdateError(error)
            }
        }
    }
    
    // MARK: -- Config Update Result Handlers
    func handleConfigUpdate(for keys: Set<String>) {
        let mappedKeys = keys.compactMap { AppConfigKey(rawValue: $0) } // unsupported keys will be ignored
        
        mappedKeys.forEach { (key) in
            switch key {
            case .version:
                handleAppVersionUpdate()
            case .webSocketConfig:
                handleWebSocketConfigUpdate()
                Task {
                    await establishSocketConnection()
                    startSocketEventListener()
                }
            }
        }
    }
    
    func handleUpdateError(_ error: Error) {
        var shouldTerminateApp = false
        
        guard let configError = error as? ConfigServiceUpdateError else {
            print("Unexpected error: \(error)")
            shouldTerminateApp = true // Unexpected error, we should terminate the app
            return
        }
        
        switch configError {
        case .updateFailed(let error):
            print("Config update failed: \(error)")
            shouldTerminateApp = true // Update failure is critical
        case .updateListMissing:
            print("Config update list is missing")
            shouldTerminateApp = false // Missing update list is not critical, but should be logged
        case .updateListEmpty:
            print("Config update list is empty")
            shouldTerminateApp = false // Update event with empty list not critical, but should be logged
        case .activationFailed(let error):
            print("Config activation failed: \(error?.localizedDescription ?? "Unknown error")")
            shouldTerminateApp = true // Activation failure is critical
        }
        
        configIsValid = shouldTerminateApp // should trigger blocking UI
    }
    
    // MARK: - Config Update Handlers
    func handleAppVersionUpdate() {
        do {
            let remoteVersion: AppVersion = try configService.fetchValue(for: .version)
            
            guard remoteVersion.version.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
                throw ConfigError.invalidAppVersion
            }
            
            let versionState = evaluateAppVersion(against: remoteVersion)
            appConfig.appVersionState = versionState
            
            shouldShowVersionUpdateNotification = versionState != .upToDate
            shouldDisableUI = versionState == .incompatible
        } catch {
            handleConfigError(error)
        }
    }
    
    func handleWebSocketConfigUpdate() {
        do {
            let config: WebSocketConfig = try configService.fetchValue(for: .webSocketConfig)
            
            guard config.urlPath.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
                throw ConfigError.invalidWebSocketConfig
            }
            
            appConfig.webSocketConfig = config
        } catch {
            handleConfigError(error)
        }
    }
    
    func versionNotificationConfig() -> ToastView.Config {
        let versionState = appConfig.appVersionState
        
        let title = "Version Update Available"
        let message: String
        
        switch versionState {
        case .incompatible:
            message = "Your app version is incompatible with the server. Please update to continue using the app."
        case .outdated:
            message = "A new version of the app is available. Please update to enjoy the latest features and improvements."
        case .updateAvailable:
            message = "A new version of the app is available. Consider updating to access new features."
        case .upToDate:
            message = "Your app is up to date." // This case should not trigger a notification
        }
        
        let image = Image(systemName: versionState == .incompatible ? "xmark.octagon" : "bell.fill")
        
        return .init(title: title, message: message, image: image)
    }
    
    func redirectToAppStore() {
        print("Redirecting to App Store for version update...")
    }
}
