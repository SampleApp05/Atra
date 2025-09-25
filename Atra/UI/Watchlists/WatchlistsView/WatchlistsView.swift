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
    
    private var addView: some View {
        HStack {
            Spacer()
            
            Button {
                viewModel.showCreateSheet()
            } label: {
                Image(systemName: "plus.app")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundStyle(.primaryText)
                    .padding(8)
                    .background(Color.accentGray)
                    .rounded(.all(10))
            }
        }
    }
    
    private var carouselView: some View {
        WatchlistsCarouselView(
            selectedTab: $viewModel.selectedTab,
            watchlistIDs: viewModel.watchlists
        ) {
            viewModel.fetchWatchlistName(for: $0)
        }
        .frame(height: 60)
    }
    
    private var listView: some View {
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
    
    var body: some View {
        VStack(spacing: 5) {
            VStack(spacing: 0) {
                addView
                carouselView
            }
            
            Divider()
            listView
        }
        .padding(10)
        .background(Color.background)
        .sheet(isPresented: $viewModel.isShowingCreateSheet) {
            WatchlistEditView(variant: .create)
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
    }
}

#Preview {
    WatchlistsView(
        viewModel: .init(
            cacheProvider: CoinCacheService(),
            watchlistProvider: WatchlistProviderService()
        )
    )
}
