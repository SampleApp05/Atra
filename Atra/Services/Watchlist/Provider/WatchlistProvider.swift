//
//  WatchlistProvider.swift
//  Atra
//
//  Created by Daniel Velikov on 20.08.25.
//

import Foundation

protocol WatchlistProvider: AnyObject, Observable {
    var watchlistCacheProvider: WatchlistCacheProvider { get }
    
    var watchlistIds: [UUID] { get }
    var localWatchlistIds: [UUID] { get }
    var watchlists: [UUID: Watchlist] { get }
    
    func createWatchlist(with name: String)
    func removeWatchlist(with id: UUID)
    
    func updateLocalWatchlist(_ watchlist: Watchlist)
    func updateRemoteWatchlist(_ watchlist: Watchlist)
    
    func fetchWatchlist(with id: UUID) -> Watchlist?
    func addToWatchlist(with id: UUID, coin: String)
    func removeFromWatchlist(with id: UUID, coin: String)
}

protocol WatchlistModifier {
    func createWatchlist(with name: String)
    func removeWatchlist(with id: UUID)
}
