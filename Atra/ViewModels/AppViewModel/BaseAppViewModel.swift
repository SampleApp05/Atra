//
//  BaseAppViewModel.swift
//  Atra
//
//  Created by Daniel Velikov on 4.07.25.
//

import SwiftUI

protocol BaseAppViewModel: Observable {
    var requestState: RequestState { get }
    
    var configIsValid: Bool { get }
    var appConfig: AppConfig { get }
    
    var shouldShowVersionUpdateNotification: Bool { get set }
    var shouldDisableUI: Bool { get }
    var notificationDuration: TimeInterval { get }
    
    func setupAppState() async
    
    func establishSocketConnection() async
    func startWebSocketListener() async
    func handleSocketMessage(_ message: WebSocketMessage) throws
    
    func fetchRemoteConfig() async
    func userDidTapRetryButton() async
    func handleConfigError(_ error: Error)
    
    func startConfigUpdateListener()
    func handleConfigUpdate(for keys: Set<String>)
    func handleUpdateError(_ error: Error)
    
    func handleAppVersionUpdate()
    func handleWebSocketConfigUpdate()
    
    func versionNotificationConfig() -> ToastView.Config
    func redirectToAppStore()
}
