//
//  WatchlistCacheProvider.swift
//  Atra
//
//  Created by Daniel Velikov on 20.08.25.
//

import Foundation

protocol WatchlistCacheProvider: AnyObject {
    func loadWatchlists() -> [UUID]
    func loadWatchlistsData(for ids: [UUID]) -> [UUID: Watchlist]
    
    func saveWatchlists(with ids: [UUID])
    func saveWatchlistData(_ watchlist: Watchlist)
    func removeWatchlistData(for id: UUID)
}
