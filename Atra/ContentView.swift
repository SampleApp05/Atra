//
//  ContentView.swift
//  Atra
//
//  Created by Daniel Velikov on 19.06.25.
//

import SwiftUI
import FirebaseRemoteConfig

struct ContentView: View {
    @State var coordinator = AppCoordinator()
    
    let viewModel: AppViewModel
    
    init(configService: ConfigService) {
//        let webSocketService = WebSocketService(
//            webSocketConnector: URLSession(
//                configuration: .default
//            ),
//            config: .init(
//                url: URL(string: "ws://localhost:8080")!
//            )
//        )
        
        viewModel = .init(configService: configService)
    }
    
    var body: some View {
        coordinator.containerView
            .task {
                await viewModel.fetchRemoteConfig()
                viewModel.startConfigUpdateListener()
            }
    }
}

#Preview {
    ContentView(
        configService: FirebaseConfigService(with: "ContentView") { RemoteConfig.remoteConfig() }
    )
}
