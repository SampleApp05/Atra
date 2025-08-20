//
//  WatchlistUpdateData.swift
//  Atra
//
//  Created by Daniel Velikov on 6.08.25.
//

import Foundation

struct WatchlistUpdateData: Codable {
    let id: UUID
    let name: String
    let variant: WatchlistUpdateVariant
    let lastUpdated: String?
    let nextUpdate: String
    let data: [String] // Coin IDs
}

enum WatchlistUpdateVariant: String, Codable {
    case marketcap = "top_marketcap"
    case gainers = "top_gainers"
    case losers = "top_losers"
    case volume = "top_volume"
}
