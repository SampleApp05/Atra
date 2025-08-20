//
//  MockWatchlistCacheProvider.swift
//  Atra
//
//  Created by Daniel Velikov on 19.08.25.
//

import Foundation
@testable import Atra

final class MockWatchlistCacheProvider: WatchlistCacheProvider {
    var localWatchlists: [UUID] = []
    var localWatchlistsData: [UUID: Watchlist] = [:]
    
    func loadWatchlists() -> [UUID] {
        localWatchlists
    }
    
    func loadWatchlistsData(for ids: [UUID]) -> [UUID: Watchlist] {
        ids.reduce(into: [UUID: Watchlist]()) { (result, id) in
            result[id] = localWatchlistsData[id]
        }
    }
    
    func saveWatchlists(with ids: [UUID]) {
        localWatchlists = ids
    }
    
    func saveWatchlistData(_ watchlist: Watchlist) {
        localWatchlistsData[watchlist.id] = watchlist
    }
    
    func removeWatchlistData(for id: UUID) {
        localWatchlistsData.removeValue(forKey: id)
    }
}
