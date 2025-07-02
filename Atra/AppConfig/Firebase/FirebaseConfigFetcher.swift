//
//  FirebaseConfigFetcher.swift
//  Atra
//
//  Created by Daniel Velikov on 2.07.25.
//

import Foundation
import FirebaseRemoteConfig

// we need it for mocking in tests
protocol FirebaseConfigFetcher {
    var configSettings: RemoteConfigSettings { get set }
    subscript(key: String) -> RemoteConfigValue { get }
    
    func fetchAndActivate() async throws -> RemoteConfigFetchAndActivateStatus
    func applyUpdates(_ completion: @escaping (Bool, Error?) -> Void)
    func applyUpdates() async throws
    func addUpdateListener(_ handler: @escaping (RemoteConfigUpdate?, Error?) -> Void)
}

extension RemoteConfig: FirebaseConfigFetcher {
    private var instance: RemoteConfig { Self.remoteConfig() } // its a singleton under the hood => wont reinit on call
    
    func applyUpdates(_ completion: @escaping (Bool, Error?) -> Void) {
        instance.activate(completion: completion)
    }
    
    func applyUpdates() async throws {
        try await Self.remoteConfig().activate()
    }
    
    func addUpdateListener(_ handler: @escaping (RemoteConfigUpdate?, (any Error)?) -> Void) {
        Self.remoteConfig().addOnConfigUpdateListener(remoteConfigUpdateCompletion: handler)
    }
}
