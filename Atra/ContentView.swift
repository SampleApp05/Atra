//
//  ContentView.swift
//  Atra
//
//  Created by Daniel Velikov on 19.06.25.
//

import SwiftUI

struct ContentView: View {
    @State private var viewModel: BaseAppViewModel & SplashViewModel
    
    init(configService: ConfigService) {
        viewModel = AppViewModel(
            configService: configService,
            socketClient: WebSocketService(webSocketConnector: URLSession(configuration: .default))
        )
    }
    
    private var splashView: some View {
        SplashView(viewModel: viewModel)
            .task {
                await viewModel.setupAppState()
            }
    }
    
    private var contentView: some View {
        VStack {
            let coordinator = AppCoordinator(config: viewModel.appConfig)
            coordinator.containerView
            Button {
                print("Retry tapped")
            } label: {
                Text("Button")
            }
            .buttonStyle(.borderedProminent)
        }
        .disabled(viewModel.shouldDisableUI)
        .toast(
            isPresented: $viewModel.shouldShowVersionUpdateNotification,
            config: viewModel.versionNotificationConfig(),
            duration: viewModel.notificationDuration,
            isDismissable: viewModel.shouldDisableUI == false,
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
