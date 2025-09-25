//
//  WatchlistsCarouselView.swift
//  Atra
//
//  Created by Daniel Velikov on 24.08.25.
//

import SwiftUI

struct WatchlistsCarouselView: View {
    @Binding private var selectedTab: UUID?
    private let watchlistIDs: [UUID]
    private let watchlistNameProvider: (UUID) -> String?
    
    init(
        selectedTab: Binding<UUID?>,
        watchlistIDs: [UUID],
        watchlistNameProvider: @escaping (UUID) -> String?
    ) {
        self._selectedTab = selectedTab
        self.watchlistIDs = watchlistIDs
        self.watchlistNameProvider = watchlistNameProvider
    }
    
    var body: some View {
        ZStack {
            Spacer().containerRelativeFrame([.horizontal])
            LazyHStack(spacing: 0) {
                ForEach(watchlistIDs, id: \.self) { id in
                    if let name = watchlistNameProvider(id) {
                        WatchlistCardView(name: name, isSelected: selectedTab == id)
                            .padding(.horizontal, 5)
                            .id(id)
                            .onTapGesture {
                                withAnimation {
                                    selectedTab = id
                                }
                            }
                    }
                }
            }
            .padding(.horizontal, 5)
            .scrollable(.horizontal)
            .scroll(to: selectedTab, on: selectedTab)
            .background(Color.background)
        }
    }
}

#Preview {
    let id = UUID()
    StatePreviewWrapper(state: id) { (state) in
        WatchlistsCarouselView(
            selectedTab: state,
            watchlistIDs: [id, UUID(), UUID(), UUID(), UUID()],
        ) { _ in "Test Watchlist" }
    }
}
