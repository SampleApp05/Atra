//
//  MockRemoteConfigValue.swift
//  Atra
//
//  Created by Daniel Velikov on 2.07.25.
//

import FirebaseRemoteConfig

final class MockRemoteConfigValue: RemoteConfigValue {
    enum Variant {
        case data(Data)
        case string(String)
        case number(Int)
        case boolean(Bool)
    }
    
    let variant: Variant
    
    override var dataValue: Data {
        switch variant {
        case .data(let data):
            return data
        case .string(let string):
            return Data(string.utf8)
        case .number(let number):
            return try! JSONEncoder().encode(number)
        case .boolean(let boolean):
            return try! JSONEncoder().encode(boolean)
        }
    }
    
    override var stringValue: String {
        switch variant {
        case .data(let data):
            return String(data: data, encoding: .utf8) ?? "failed to decode data string"
        case .string(let string):
            return string
        case .number(let number):
            return String(number)
        case .boolean(let boolean):
            return boolean ? "true" : "false"
        }
    }
    
    override var numberValue: NSNumber {
        switch variant {
            case .data(let data):
                return NSNumber(value: data.count) // Example conversion, adjust as needed
            case .string(let string):
                return NSNumber(value: Int(string) ?? 0)
            case .number(let number):
            return NSNumber(value: number)
        case .boolean(let boolean):
            return NSNumber(value: boolean)
        }
    }
    
    override var boolValue: Bool {
        switch variant {
        case .data(let data):
            return data.isEmpty == false// Example conversion, adjust as needed
        case .string(let string):
            return Bool(string) ?? false
        case .number(let number):
            return number != 0
        case .boolean(let boolean):
            return boolean
        }
    }
        
    
    init(variant: Variant) {
        self.variant = variant
    }
}
