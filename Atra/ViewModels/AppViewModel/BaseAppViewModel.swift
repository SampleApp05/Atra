//
//  BaseAppViewModel.swift
//  Atra
//
//  Created by Daniel Velikov on 4.07.25.
//

import Foundation

protocol BaseAppViewModel: Observable {
    var requestState: RequestState { get }
    
    var configIsValid: Bool { get }
    var appVersionState: AppVersionState { get }
    var watchlistApiKey: String { get }
    
    func fetchRemoteConfig() async
    func userDidTapRetryButton() async
    func handleConfigError(_ error: Error)
    
    func startConfigUpdateListener()
    func handleConfigUpdate(for keys: Set<String>)
    func handleUpdateError(_ error: Error)
    
    func handleAppVersionUpdate()
    func handleApiKeyUpdate()
}
