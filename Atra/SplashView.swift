//
//  SplashView.swift
//  Atra
//
//  Created by Daniel Velikov on 8.07.25.
//

import SwiftUI

protocol SplashViewModel: Observable {
    var shouldShowRetryButton: Bool { get }
    var infoText: String { get }
    
    func didTapRetryButton()
}

extension AppViewModel: SplashViewModel {
    var shouldShowRetryButton: Bool { requestState == .failure }
    
    var infoText: String {
        switch requestState {
        case .notStarted:
            return "Initializing..."
        case .inProgress:
            return "Loading..."
        case .failure:
            return "Failed to load configuration. Please try again."
        case .success:
            return "Configuration loaded successfully."
        }
    }
    
    func didTapRetryButton() {
        Task {
            await fetchRemoteConfig()
        }
    }
}

struct SplashView: View {
    private let viewModel: SplashViewModel
    
    init(viewModel: SplashViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 25) {
            Text("Atra")
                .font(.system(size: 32, weight: .bold))
            
            Spacer()
            
            VStack {
                if viewModel.shouldShowRetryButton {
                    Button {
                        viewModel.didTapRetryButton()
                    } label: {
                        Text("Retry")
                    }
                }
                
                Text(viewModel.infoText)
                    .padding(.bottom, 20)
            }
        }
    }
}

#Preview {
    SplashView(
        viewModel: AppViewModel(
            configService: FirebaseConfigService(with: "SplashView"),
            socketClient: WebSocketService(webSocketConnector: URLSession.shared)
        )
    )
}
