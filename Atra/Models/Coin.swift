//
//  Coin.swift
//  Atra
//
//  Created by Daniel Velikov on 6.08.25.
//

import Foundation

extension JSONDecoder {
    static var snakeCaseDecoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }
}

struct Coin: Codable, Equatable {
    let id: String
    let name: String
    let symbol: String
    let imageURL: URL
    
    let price: Double
    let marketCap: Double
    let marketCapRank: Int
    
    let priceChange24h: Double?
    let priceChangePercentage24h: Double?
    
    enum CodingKeys : String, CodingKey {
        case id
        case name
        case symbol
        case imageURL = "image"
        case price = "current_price"
        case marketCap = "market_cap"
        case marketCapRank = "market_cap_rank"
        case priceChange24h = "price_change_24h"
        case priceChangePercentage24h = "price_change_percentage_24h"
    }
}
