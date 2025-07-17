//
//  SocketMessage.swift
//  Atra
//
//  Created by Daniel Velikov on 14.07.25.
//

import Foundation

struct SocketMessage: Codable {
    let event: SocketEvent
    let data: Data
}

enum SocketEvent: String, Codable {
    case connection = "connection_established"
    case status
    case cacheUpdate = "coins_update"
    case watchlist = "watchlist_update"
    case error
}
