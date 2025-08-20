//
//  BaseAppViewModel.swift
//  Atra
//
//  Created by Daniel Velikov on 4.07.25.
//

import SwiftUI

protocol BaseAppViewModel: Observable {
    var configService: ConfigService { get }
    var appVersionEvaluator: VersionEvaluator { get }
    var socketConsumer: CoinSocketDataConsumer { get }
    var configUpdateListenerTask: VoidTask? { get }
    
    var requestState: RequestState { get }
    
    var configIsValid: Bool { get }
    var appConfig: AppConfig { get }
    
    var shouldShowVersionUpdateNotification: Bool { get set }
    var shouldForceUpdate: Bool { get }
    
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
