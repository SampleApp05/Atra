//
//  MockRemoteConfigValue.swift
//  Atra
//
//  Created by Daniel Velikov on 2.07.25.
//

import FirebaseRemoteConfig

final class MockRemoteConfigValue: RemoteConfigValue {
    override var dataValue: Data {
        data
    }
    
    override var stringValue: String {
        String(data: data, encoding: .utf8) ?? "failed to decode data string"
    }
    
    override var numberValue: NSNumber {
        NSNumber(value: data.count) // Example conversion, adjust as needed
    }
    
    override var boolValue: Bool {
        data.isEmpty == false// Example conversion, adjust as needed
    }
        
    let data: Data
    
    init(data: Data) {
        self.data = data
    }
}
