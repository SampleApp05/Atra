//
//  CoinCacheData.swift
//  Atra
//
//  Created by Daniel Velikov on 6.08.25.
//

import Foundation

struct CoinCacheData: Codable {
    let lastUpdated: String?
    let nextUpdate: String
    let data: [Coin] // Your Coin model
}
