//
//  UserDefaults+Helper.swift
//  Atra
//
//  Created by Daniel Velikov on 20.08.25.
//

import Foundation

extension UserDefaults {
    enum Key: String {
        case watchlists
    }
    
    func store<T: Encodable>(_ value: T?, for key: String) {
        guard let value = value, let data = try? JSONEncoder().encode(value) else { return }
        setValue(data, forKey: key)
    }
    
    func read<T: Decodable>(for key: String) -> T? {
        guard let data = data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }
    
    func store<T: Encodable>(_ value: T?, for key: Key) {
        store(value, for: key.rawValue)
    }
    
    func read<T: Decodable>(for key: Key) -> T? {
        read(for: key.rawValue)
    }
}
