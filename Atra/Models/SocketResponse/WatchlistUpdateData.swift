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
    let coins: [String]
}
