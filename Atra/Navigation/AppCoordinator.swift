//
//  AppCoordinator.swift
//  Atra
//
//  Created by Daniel Velikov on 19.06.25.
//

import SwiftUI

enum AppFlow: CaseIterable {
    case watchilists
    case staking
}

@Observable
final class AppCoordinator: TabViewContentProvider {
    private let config: AppConfig
    private let dependencyProvider: DependencyProvider
    
    private(set) var tabs = AppFlow.allCases
    var selectedFlow: AppFlow = .watchilists
    
    var containerView: some View { TabViewContainerView(provider: self) }
    
    init(config: AppConfig, dependencyProvider: DependencyProvider) {
        self.config = config
        self.dependencyProvider = dependencyProvider
    }
    
    func start(with initial: AppFlow = .watchilists, tabs: [AppFlow]? = nil) {
        defer {
            selectedFlow = initial
        }
        
        guard let tabs = tabs, tabs.contains(initial) else {
            preconditionFailure("Initial flow \(initial) must be part of the provided stack.")
        }
        
        self.tabs = tabs
    }
    
    func content(for flow: AppFlow) -> some View {
        switch flow {
        case .watchilists:
            let viewModel = WatchlistsView.ViewModel(
                cacheProvider: dependencyProvider.coinCacheProvider,
                watchlistProvider: dependencyProvider.watchlistProvider
            )
            
            WatchlistsView(viewModel: viewModel)
        case .staking:
            Color.purple
        }
    }
    
    func navigate(to flow: AppFlow) {
        selectedFlow = flow
    }
}
