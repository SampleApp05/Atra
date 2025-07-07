//
//  AppViewModel.swift
//  Atra
//
//  Created by Daniel Velikov on 3.07.25.
//

import Foundation

final class AppViewModel: BaseAppViewModel, AppVersionEvaluator {
    // MARK: - Properties
    private(set) var requestState: RequestState = .notStarted
    
    private(set) var configIsValid: Bool = true
    private(set) var appVersionState: AppVersionState = .upToDate
    private(set) var watchlistApiKey: String = ""
    private(set) var proxyToken: String = ""
    
    private let configService: ConfigService
    
    // MARK: - Initializer
    init(configService: ConfigService) {
        self.configService = configService
    }
    
    // MARK: - Remote Config Fetching
    func fetchRemoteConfig() async {
        guard requestState != .inProgress else { return }
        
        requestState = .inProgress
        
        do {
            try await configService.fetch()
            
            handleAppVersionUpdate()
            handleApiKeyUpdate()
            handleProxyTokenUpdate()
            
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
            case .watchlistAPIKey:
                handleApiKeyUpdate()
            case .proxyToken:
                handleProxyTokenUpdate()
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
            appVersionState = evaluateAppVersion(against: remoteVersion)
        } catch {
            handleConfigError(error)
        }
    }
    
    func handleApiKeyUpdate() {
        do {
            let apiKey: String = try configService.fetchValue(for: .watchlistAPIKey)
            
            guard apiKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
                throw ConfigError.invalidAPIKeyValue
            }
            
            watchlistApiKey = apiKey
        } catch {
            handleConfigError(error)
        }
    }
    
    func handleProxyTokenUpdate() {
        do {
            let token: String = try configService.fetchValue(for: .proxyToken)
            
            guard token.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
                throw ConfigError.invalidAPIKeyValue
            }
            
            proxyToken = token
        } catch {
            handleConfigError(error)
        }
    }
}
