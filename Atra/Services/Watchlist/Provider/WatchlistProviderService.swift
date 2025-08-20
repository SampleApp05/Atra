//
//  WatchlistProviderService.swift
//  Atra
//
//  Created by Daniel Velikov on 20.08.25.
//

import Foundation

@Observable
final class WatchlistProviderService: WatchlistProvider {
    private(set) var watchlistCacheProvider: WatchlistCacheProvider
    
    private(set) var watchlistIds: [UUID] = []
    private(set) var watchlists: [UUID: Watchlist] = [:]
    
    var localWatchlistIds: [UUID] { watchlists.values.filter { $0.origin == .local }.map(\.id) }
    
    init(cacheProvider: WatchlistCacheProvider = WatchlistCacheService()) {
        watchlistCacheProvider = cacheProvider
        loadWatchlists()
    }
    
    // MARK: Private
    private func loadWatchlists() {
        watchlistIds = watchlistCacheProvider.loadWatchlists()
        watchlists = watchlistCacheProvider.loadWatchlistsData(for: watchlistIds)
    }
    
    private func storeWatchlist(_ watchlist: Watchlist, shouldPersist: Bool) {
        let id = watchlist.id
        
        if watchlistIds.contains(id) == false {
            switch watchlist.origin {
            case .local:
                watchlistIds.insert(id, at: 0)
            case .remote:
                watchlistIds.append(id)
            }
        }
        
        watchlists[id] = watchlist
        
        if shouldPersist {
            watchlistCacheProvider.saveWatchlistData(watchlist)
            watchlistCacheProvider.saveWatchlists(with: watchlistIds)
        }
    }
    
    // MARK: - Public
    // using UUID ensures unique watchlists
    func createWatchlist(with name: String) {
        let id = UUID()
        let watchlist = Watchlist(id: id, name: name, origin: .local, coins: [])
        
        storeWatchlist(watchlist, shouldPersist: true)
    }
    
    func removeWatchlist(with id: UUID) {
        guard localWatchlistIds.contains(id) else { return }
        
        watchlistIds.removeAll { $0 == id }
        watchlists.removeValue(forKey: id)
        
        watchlistCacheProvider.removeWatchlistData(for: id)
        watchlistCacheProvider.saveWatchlists(with: watchlistIds)
    }
    
    func updateLocalWatchlist(_ watchlist: Watchlist) {
        storeWatchlist(watchlist, shouldPersist: true)
    }
    
    func updateRemoteWatchlist(_ watchlist: Watchlist) {
        storeWatchlist(watchlist, shouldPersist: false)
    }
    
    func fetchWatchlist(with id: UUID) -> Watchlist? {
        watchlists[id]
    }
    
    func addToWatchlist(with id: UUID, coin: String) {
        guard var watchlist = watchlists[id], watchlist.origin == .local else { return }
        watchlist.coins.insert(coin, at: 0)
        
        watchlists[id] = watchlist
        watchlistCacheProvider.saveWatchlistData(watchlist)
    }
    
    func removeFromWatchlist(with id: UUID, coin: String) {
        guard var watchlist = watchlists[id], watchlist.origin == .local else { return }
        
        watchlist.coins.removeAll { $0 == coin }
        watchlists[id] = watchlist
        watchlistCacheProvider.saveWatchlistData(watchlist)
    }
}
