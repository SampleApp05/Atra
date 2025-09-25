//
//  Watchlist.swift
//  Atra
//
//  Created by Daniel Velikov on 20.08.25.
//

import Foundation

struct Watchlist: Codable, Equatable {
    enum Origin: String, Codable {
        case local
        case remote
    }
    
    struct Name: Codable, Equatable {
        enum WatchlistNameError: Error {
            case invalidName
        }
        
        let value: String
        
        init(with value: String?) throws {
            let name = value?.trimmingCharacters(in: .whitespacesAndNewlines)
            
            guard let name = name else {
                throw WatchlistNameError.invalidName
            }
            
            self.value = name
        }
    }
    
    let id: UUID
    let name: Name
    let origin: Origin
    var coins: [String]
    
    init(id: UUID, name: Name, origin: Origin, coins: [String]) {
        self.id = id
        self.name = name
        self.origin = origin
        self.coins = coins
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(UUID.self, forKey: .id)
        
        let nameValue = try container.decode(String.self, forKey: .name)
        self.name = try .init(with: nameValue)
        
        self.origin = (try? container.decode(Origin.self, forKey: .origin)) ?? .remote
        self.coins = try container.decode([String].self, forKey: .coins)
    }
}
