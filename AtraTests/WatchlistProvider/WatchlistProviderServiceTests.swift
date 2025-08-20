//
//  WatchlistProviderServiceTests.swift
//  Atra
//
//  Created by Daniel Velikov on 19.08.25.
//

import Testing
import Foundation

@testable import Atra

struct WatchlistProviderServiceTests {
    let cacheProvider: MockWatchlistCacheProvider
    
    init() {
        cacheProvider = .init()
    }
    
    @Test
    func testLocalLoadOnInit() {
        let id = UUID()
        let name = "Test"
        let coins = ["btc", "eth"]
        
        cacheProvider.localWatchlists = [id]
        cacheProvider.localWatchlistsData[id] = .init(
            id: id,
            name: name,
            origin: .local,
            coins: coins
        )
        
        let sut = WatchlistProviderService(cacheProvider: cacheProvider)
        
        #expect(sut.watchlistIds.count == 1)
        #expect(sut.localWatchlistIds.count == 1)
        
        #expect(sut.watchlistIds.first == id)
        #expect(sut.localWatchlistIds.first == id)
        
        #expect(sut.watchlists.count == 1)
        
        let watchlist = sut.watchlists[id]
        #expect(watchlist != nil)
        #expect(watchlist?.id == id)
        #expect(watchlist?.name == name)
        #expect(watchlist?.origin == .local)
        #expect(watchlist?.coins == coins)
    }
    
    @Test
    func testCreateWatchlist() {
        let sut = WatchlistProviderService(cacheProvider: cacheProvider)
        
        let name = "New Watchlist"
        sut.createWatchlist(with: name)
        
        #expect(sut.watchlistIds.count == 1)
        #expect(sut.localWatchlistIds.count == 1)
        #expect(sut.watchlistIds.first == sut.localWatchlistIds.first)
        
        #expect(cacheProvider.localWatchlists == sut.watchlistIds)
        
        let id = sut.watchlistIds.first!
        let watchlist = sut.fetchWatchlist(with: id)
        
        #expect(watchlist != nil)
        #expect(watchlist?.id == id)
        #expect(watchlist?.name == name)
        #expect(watchlist?.origin == .local)
        #expect(watchlist?.coins.isEmpty == true)
        
        #expect(cacheProvider.localWatchlistsData[id] == watchlist)
    }
    
    @Test
    func testRemoveWatchlist() {
        let sut = WatchlistProviderService(cacheProvider: cacheProvider)
        
        let name = "New Watchlist"
        sut.createWatchlist(with: name)
        
        let id = sut.watchlistIds.first!
        sut.removeWatchlist(with: id)
        
        #expect(sut.localWatchlistIds.isEmpty == true)
        #expect(sut.watchlists.isEmpty == true)
        #expect(cacheProvider.localWatchlists.isEmpty == true)
        #expect(cacheProvider.localWatchlistsData.isEmpty == true)
    }
    
    @Test
    func testUpdateRemoteWatchlist() {
        let sut = WatchlistProviderService(cacheProvider: cacheProvider)
        
        let id = UUID()
        let name = "Remote Watchlist"
        let coins = ["btc", "eth"]
        
        let watchlist = Watchlist(id: id, name: name, origin: .remote, coins: coins)
        sut.updateRemoteWatchlist(watchlist)
        
        #expect(sut.watchlistIds.count == 1)
        #expect(sut.localWatchlistIds.count == 0)
        
        #expect(cacheProvider.localWatchlists.isEmpty == true)
        #expect(cacheProvider.localWatchlistsData.isEmpty == true)
        
        let storedWatchlist = sut.watchlists[id]
        #expect(storedWatchlist == watchlist)
        
        let updatedCoins = ["btc", "eth", "xrp"]
        let updatedWatchlist = Watchlist(id: id, name: name, origin: .remote, coins: updatedCoins)
        
        sut.updateRemoteWatchlist(updatedWatchlist)
        
        #expect(sut.watchlistIds.count == 1)
        #expect(sut.localWatchlistIds.count == 0)
        
        #expect(cacheProvider.localWatchlists.isEmpty == true)
        #expect(cacheProvider.localWatchlistsData.isEmpty == true)
        
        let updatedStoredWatchlist = sut.watchlists[id]
        #expect(updatedStoredWatchlist == updatedWatchlist)
    }
    
    @Test
    func testAddToWatchlist() {
        let sut = WatchlistProviderService(cacheProvider: cacheProvider)
        
        let coin = "btc_wrapped"
        sut.createWatchlist(with: "Mock Watchlist")
        let id = sut.watchlistIds.first!
        
        sut.addToWatchlist(with: id, coin: coin)
        let watchlist = sut.watchlists[id]
        
        #expect(watchlist != nil)
        #expect(watchlist?.coins.count == 1)
        #expect(watchlist?.coins.first == coin)
        #expect(cacheProvider.localWatchlistsData[id] == watchlist)
    }
    
    @Test
    func testRemoveFromWatchlist() {
        let sut = WatchlistProviderService(cacheProvider: cacheProvider)
        
        let coin = "btc_wrapped"
        sut.createWatchlist(with: "Mock Watchlist")
        let id = sut.watchlistIds.first!
        
        sut.addToWatchlist(with: id, coin: coin)
        sut.removeFromWatchlist(with: id, coin: coin)
        
        let watchlist = sut.fetchWatchlist(with: id)
        #expect(watchlist?.coins.isEmpty == true)
        #expect(cacheProvider.localWatchlistsData[id] == watchlist)
    }
}
