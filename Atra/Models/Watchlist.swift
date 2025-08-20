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
    
    let id: UUID
    let name: String
    let origin: Origin
    var coins: [String]
    
    init(id: UUID, name: String, origin: Origin, coins: [String]) {
        self.id = id
        self.name = name
        self.origin = origin
        self.coins = coins
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.name = try container.decode(String.self, forKey: .name)
        self.origin = (try? container.decode(Origin.self, forKey: .origin)) ?? .remote
        self.coins = try container.decode([String].self, forKey: .coins)
    }
}
