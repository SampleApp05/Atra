//
//  AtraApp.swift
//  Atra
//
//  Created by Daniel Velikov on 19.06.25.
//

import SwiftUI

@main
struct AtraApp: App {
    let dependencyProvider = DependencyService(
        coinCacheProvider: CoinCacheService(),
        watchlistProvider: WatchlistProviderService()
    )
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    let logger: Logger = Logger()
    
    var body: some Scene {
        WindowGroup {
            LoggerContext.$current.withValue(logger) {
                ContentView(configService: delegate.configService, dependencyProvider: dependencyProvider)
            }
        }
    }
}
