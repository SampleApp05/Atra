//
//  AppViewModel.swift
//  Atra
//
//  Created by Daniel Velikov on 3.07.25.
//

import SwiftUI
import AsyncAlgorithms

@Observable
final class AppViewModel: BaseAppViewModel {
    let configService: ConfigService
    let appVersionEvaluator: VersionEvaluator = AppVersionEvaluator()
    let socketConsumer: CoinDataConsumer<CoinDataStorage>
    private(set) var configUpdateListenerTask: VoidTask?
    
    // MARK: - Properties
    private(set) var requestState: RequestState = .notStarted
    
    private(set) var configIsValid: Bool = true
    private(set) var appConfig: AppConfig = AppConfig()
    
    var shouldShowVersionUpdateNotification: Bool = false
    var shouldForceUpdate: Bool { appConfig.appVersionState.shouldForceUpdate }
    
    // MARK: - Initializer
    init(configService: ConfigService, socketConsumer: T) {
        self.configService = configService
        self.socketConsumer = socketConsumer
    }
    
    // MARK: - Public    
    func fetchRemoteConfig() async {
        guard requestState != .inProgress else { return }
        
        requestState = .inProgress
        
        do {
            try await configService.fetch()
            startConfigUpdateListener()
            
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
    
    // MARK: - Config Fetch Error Handler
    func handleConfigError(_ error: Error) {
        configIsValid = false // should trigger blocking UI
    }
    
    // MARK: - Config Update Listener
    func startConfigUpdateListener() {
        // storing the task to keep it alive
        configUpdateListenerTask = Task {
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
            
            let versionState = appVersionEvaluator.evaluateAppVersion(against: remoteVersion)
            appConfig.appVersionState = versionState
            shouldShowVersionUpdateNotification = versionState.shouldShowUpdateNotification
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
            
            Task {
                await socketConsumer.connect(with: appConfig.webSocketConfig, subscribeMessage: SubscribeMessage())
            }
        } catch {
            handleConfigError(error)
        }
    }
    
    func versionNotificationConfig() -> ToastView.Config {
        let state = appConfig.appVersionState
        
        return .init(
            title: state.messageTitle,
            message: state.messageDescription,
            image: state.messsageImage
        )
    }
    
    func redirectToAppStore() {
        print("Redirecting to App Store for version update...")
    }
}
