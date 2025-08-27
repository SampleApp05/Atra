//
//  WatchlistsView+ViewModel.swift
//  Atra
//
//  Created by Daniel Velikov on 25.08.25.
//

import SwiftUI

extension WatchlistsView {
    @Observable
    final class ViewModel {
        let cacheProvider: CoinCacheProvider
        let watchlistProvider: WatchlistProvider
        let formatter: ValueFormatter = CoinValueFormatter()
        
        var selectedTab: UUID?
        var watchlists: [UUID] { watchlistProvider.watchlistIds }
        
        var activeWatchlistCoinIds: [String] {
            guard let selectedTab else { return [] }
            return fetchWatchlist(for: selectedTab)?.coins ?? []
        }
        
        init(cacheProvider: CoinCacheProvider, watchlistProvider: WatchlistProvider) {
            self.cacheProvider = cacheProvider
            self.watchlistProvider = watchlistProvider
            selectedTab = watchlists.first
        }
        
        // MARK: - Private
        private func fetchWatchlist(for id: UUID) -> Watchlist? {
            watchlistProvider.fetchWatchlist(with: id)
        }
        
        func fetchWatchlistName(for id: UUID) -> String? {
            fetchWatchlist(for: id)?.name
        }
        
        // MARK: - Public
        func fetchCellConfig(for id: String) -> CoinCellView.Config? {
            guard let coin = cacheProvider.fetchData(for: id) else { return nil }
            
            let priceDirection: CoinCellView.PriceDirection = {
                guard let change = coin.priceChange24h ?? coin.priceChangePercentage24h else { return .none }
                
                return change > 0 ? .up : (change < 0 ? .down : .none)
            }()
            
            return .init(
                name: coin.name,
                symbol: coin.symbol,
                imageURL: coin.imageURL,
                price: formatter.formatPrice(coin.price),
                priceChange: formatter.formatPriceChange(coin.priceChange24h),
                priceChangePercentage: formatter.formatPercentage(coin.priceChangePercentage24h),
                priceDirection: priceDirection
            )
        }
    }
}
