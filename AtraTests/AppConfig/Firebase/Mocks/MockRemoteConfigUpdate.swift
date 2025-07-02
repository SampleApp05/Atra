//
//  MockRemoteConfigUpdate.swift
//  Atra
//
//  Created by Daniel Velikov on 2.07.25.
//

import FirebaseRemoteConfig

final class MockRemoteConfigUpdate: RemoteConfigUpdate {
    var keys: Set<String> = []
    
    override var updatedKeys: Set<String> { keys }
}
