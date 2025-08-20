//
//  ContentView.swift
//  Atra
//
//  Created by Daniel Velikov on 19.06.25.
//

import SwiftUI

struct ContentView: View {
    @State private var viewModel: any BaseAppViewModel & SplashViewModel
    
    init(configService: ConfigService) {
        let client = WebSocketService(connector: URLSession(configuration: .default))
        let coinCache = CoinCacheService()
        let watchlistService = WatchlistProviderService()
        
        viewModel = AppViewModel(
            configService: configService,
            socketConsumer: CoinDataConsumer(
                client: client,
                cacheProvider: coinCache,
                watchlistProvider: watchlistService
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
            let coordinator = AppCoordinator(config: viewModel.appConfig)
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
    )
}
