//
//  WatchlistCardView.swift
//  Atra
//
//  Created by Daniel Velikov on 24.08.25.
//

import SwiftUI

struct WatchlistCardView: View {
    let name: String
    let isSelected: Bool
    
    private var foregroundColor: Color {
        isSelected ? .primaryText : .secondaryText
    }
    
    private var backgroundColor: Color {
        isSelected ? .secondaryText : .background
    }
    
    var body: some View {
        Text(name)
            .font(.primary, size: .headline, weight: .semiBold)
            .foregroundStyle(foregroundColor)
            .lineLimit(1)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
            .background(backgroundColor)
            .rounded(.all(10))
    }
}

#Preview {
    VStack {
        WatchlistCardView(name: "Favorites 1", isSelected: true)
        WatchlistCardView(name: "Favorites 2", isSelected: false)
        WatchlistCardView(name: "Favorites 3", isSelected: false)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.background)
}
