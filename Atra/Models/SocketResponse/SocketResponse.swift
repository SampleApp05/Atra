//
//  SocketResponse.swift
//  Atra
//
//  Created by Daniel Velikov on 6.08.25.
//

import Foundation

enum SocketResponse: Decodable {
    case connection(ConnectionData)
    case status(StatusData)
    case cacheUpdate(CoinCacheData)
    case watchlistUpdate(WatchlistUpdateData)
    case error(ErrorData)
    
    enum CodingKeys: String, CodingKey {
        case event
        case data
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let event = try container.decode(SocketEvent.self, forKey: .event)
        
        switch event {
        case .connection:
            let data = try container.decode(ConnectionData.self, forKey: .data)
            self = .connection(data)
        case .status:
            let data = try container.decode(StatusData.self, forKey: .data)
            self = .status(data)
        case .cacheUpdate:
            let data = try container.decode(CoinCacheData.self, forKey: .data)
            self = .cacheUpdate(data)
        case .watchlist:
            let data = try container.decode(WatchlistUpdateData.self, forKey: .data)
            self = .watchlistUpdate(data)
        case .error:
            let data = try container.decode(ErrorData.self, forKey: .data)
            self = .error(data)
        }
    }
}
