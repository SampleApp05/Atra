//
//  ToastView.swift
//  Atra
//
//  Created by Daniel Velikov on 10.07.25.
//

import SwiftUI

struct ToastView: View {
    struct Config {
        let title: String
        let message: String?
        let image: Image?
    }
    
    private let config: Config
    
    init(config: Config) {
        self.config = config
    }
    
    var body: some View {
        HStack(spacing: 0) {
            Spacer(minLength: 30)
            
            HStack(alignment: .center, spacing: 15) {
                VStack {
                    Text(config.title)
                        .font(.callout)
                        .fontWeight(.bold)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .padding(.horizontal, 15)
                    
                    if let message = config.message {
                        Text(message)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(3)
                            .multilineTextAlignment(.center)
                    }
                }
                
                if let image = config.image {
                    image
                        .resizable()
                        .frame(width: 24, height: 24)
                }
            }
            .padding(.vertical, 15)
            .padding(.horizontal, 20)
            .background(.ultraThickMaterial)
            .rounded(.all(25))
            
            Spacer(minLength: 30)
        }
    }
}

#Preview {
    ToastView(
        config: .init(
            title: "Sample Toast",
            message: "This is a message that can be quite long and should be truncated if it exceeds the available space.",
            image: Image(systemName: "checkmark.circle.fill")
        )
    )
}
