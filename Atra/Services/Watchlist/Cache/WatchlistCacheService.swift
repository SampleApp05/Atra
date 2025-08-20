//
//  WatchlistCacheService.swift
//  Atra
//
//  Created by Daniel Velikov on 20.08.25.
//

import Foundation

final class WatchlistCacheService: WatchlistCacheProvider {
    // MARK: - Public
    func loadWatchlists() -> [UUID] {
        UserDefaults.standard.read(for: .watchlists) ?? []
    }
    
    func loadWatchlistsData(for ids: [UUID]) -> [UUID: Watchlist] {
        ids.reduce(into: [UUID: Watchlist]()) { (result, id) in
            let data: Watchlist? = UserDefaults.standard.read(for: id.uuidString)
            result[id] = data
        }
    }
    
    func saveWatchlists(with ids: [UUID]) {
        UserDefaults.standard.store(ids, for: .watchlists)
    }
    
    func saveWatchlistData(_ watchlist: Watchlist) {
        let id = watchlist.id
        UserDefaults.standard.store(watchlist, for: id.uuidString)
    }
    
    func removeWatchlistData(for id: UUID) {
        UserDefaults.standard.removeObject(forKey: id.uuidString)
    }
}
