//
//  RemoteConfigFetchAndActivateStatus+Helper.swift
//  Atra
//
//  Created by Daniel Velikov on 2.07.25.
//

import FirebaseRemoteConfig

extension RemoteConfigFetchAndActivateStatus {
    var didSucceed: Bool {
        switch self {
        case .successFetchedFromRemote, .successUsingPreFetchedData:
            return true
        default:
            return false
            
        }
    }
}
