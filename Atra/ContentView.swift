//
//  ContentView.swift
//  Atra
//
//  Created by Daniel Velikov on 19.06.25.
//

import SwiftUI

protocol DependencyProvider {
    var coinCacheProvider: CoinCacheProvider { get }
    var watchlistProvider: WatchlistProvider { get }
}

@Observable
final class DependencyService: DependencyProvider {
    let coinCacheProvider: CoinCacheProvider
    let watchlistProvider: WatchlistProvider
    
    init(coinCacheProvider: CoinCacheProvider, watchlistProvider: WatchlistProvider) {
        self.coinCacheProvider = coinCacheProvider
        self.watchlistProvider = watchlistProvider
    }
}

struct ContentView: View {
    @State private var viewModel: any BaseAppViewModel & SplashViewModel
    let dependencyProvider: DependencyProvider
    
    init(configService: ConfigService, dependencyProvider: DependencyProvider) {
        self.dependencyProvider = dependencyProvider
        
        let client = WebSocketService(connector: URLSession(configuration: .default))
        
        viewModel = AppViewModel(
            configService: configService,
            socketConsumer: CoinDataConsumer(
                client: client,
                cacheProvider: dependencyProvider.coinCacheProvider,
                watchlistProvider: dependencyProvider.watchlistProvider
            )
        )
    }
    
    private var splashView: some View {
        SplashView(viewModel: viewModel)
            .task {
                await viewModel.fetchRemoteConfig()
            }
    }
    
    private var contentView: some View {
        VStack {
            let coordinator = AppCoordinator(config: viewModel.appConfig, dependencyProvider: dependencyProvider)
            coordinator.containerView
        }
        .disabled(viewModel.shouldForceUpdate)
        .toast(
            isPresented: $viewModel.shouldShowVersionUpdateNotification,
            config: viewModel.versionNotificationConfig(),
            isDismissable: viewModel.shouldForceUpdate == false,
            action: viewModel.redirectToAppStore
        )
    }
    
    var body: some View {
        if viewModel.requestState != .success {
            splashView
        } else {
            contentView
        }
    }
}

#Preview {
    ContentView(
        configService: FirebaseConfigService(with: "ContentView"),
        dependencyProvider: DependencyService(
            coinCacheProvider: CoinCacheService(),
            watchlistProvider: WatchlistProviderService()
        )
    )
}
