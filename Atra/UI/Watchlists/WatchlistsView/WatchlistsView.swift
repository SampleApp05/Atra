//
//  WatchlistsView.swift
//  Atra
//
//  Created by Daniel Velikov on 23.08.25.
//

import SwiftUI

struct WatchlistsView: View {
    @Bindable private var viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(spacing: 5) {
            WatchlistsCarouselView(
                selectedTab: $viewModel.selectedTab,
                watchlistIDs: viewModel.watchlists
            ) {
                viewModel.fetchWatchlistName(for: $0)
            }
            .frame(height: 60)
            
            List(viewModel.activeWatchlistCoinIds, id: \.self) { (coinID) in
                if let cellConfig = viewModel.fetchCellConfig(for: coinID) {
                    CoinCellView(config: cellConfig)
                        .id(coinID)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color.clear)
                }
            }
            .listStyle(.plain)
            .scrollIndicators(.hidden)
            .scrollBounceBehavior(.basedOnSize)
            .scroll(to: viewModel.activeWatchlistCoinIds.first, on: viewModel.selectedTab)
        }
        .padding(10)
        .background(Color.background)    }
}

#Preview {
    WatchlistsView(
        viewModel: .init(
            cacheProvider: CoinCacheService(),
            watchlistProvider: WatchlistProviderService()
        )
    )
}
