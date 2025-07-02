//
//  MockFirebaseFetcher.swift
//  Atra
//
//  Created by Daniel Velikov on 2.07.25.
//

import FirebaseRemoteConfig
@testable import Atra

final class MockFirebaseFetcher: FirebaseConfigFetcher {
    private var values: [String: RemoteConfigValue] = [:]
    
    var configSettings: RemoteConfigSettings = RemoteConfigSettings()
    
    var fetchResult: Result<RemoteConfigFetchAndActivateStatus, Error> = .success(.successFetchedFromRemote)
    
    var applyUpdatesResult: (Bool, Error?) = (true, nil)
    var updateResult: (RemoteConfigUpdate?, Error?) = (nil, nil)
    

    func setValue(_ value: Data, forKey key: String) {
        let value = MockRemoteConfigValue(variant: .data(value))
        values[key] = value
    }

    func fetchAndActivate() async throws -> RemoteConfigFetchAndActivateStatus {
        switch fetchResult {
        case .success(let state):
            return state
        case .failure(let error):
            throw error
        }
    }

    func applyUpdates(_ completion: @escaping (Bool, Error?) -> Void) {
        completion(applyUpdatesResult.0, applyUpdatesResult.1)
    }
    
    func applyUpdates() async throws {
        let _ = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Bool, Error>) in
            applyUpdates { (success, error) in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: success)
                }
            }
        }
    }

    func addUpdateListener(_ handler: @escaping (RemoteConfigUpdate?, Error?) -> Void) {
        handler(updateResult.0, updateResult.1)
    }
    
    subscript(key: String) -> RemoteConfigValue {
        values[key] ?? RemoteConfigValue()
    }
}
