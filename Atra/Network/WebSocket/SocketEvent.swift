//
//  SocketEvent.swift
//  Atra
//
//  Created by Daniel Velikov on 14.07.25.
//

import Foundation

enum SocketEvent: String, Codable {
    case connection = "connection_established"
    case status
    case cacheUpdate = "cache_update"
    case watchlist = "watchlist_update"
    case error
}
