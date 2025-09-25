//
//  CoinCellView.swift
//  Atra
//
//  Created by Daniel Velikov on 20.08.25.
//

import SwiftUI

struct CoinCellView: View {
    enum PriceDirection {
        case up
        case down
        case none
        
        var color: Color {
            switch self {
            case .up:
                return .brandGreen
            case .down:
                return .brandRed
            case .none:
                return .secondaryText
            }
        }
    }
    
    struct Config {
        let name: String
        let symbol: String
        let imageURL: URL
        let price: String
        let priceChange: String?
        let priceChangePercentage: String?
        let priceDirection: PriceDirection
    }
    
    private let config: Config
    
    init(config: Config) {
        self.config = config
    }
    
    private var logoView: some View {
        AsyncImage(url: config.imageURL) { (result) in
            result.image?.resizable()
                .scaledToFill()
        }
        .frame(width: 45, height: 45)
        .rounded(.all(10))
    }
    
    private var headlineView: some View {
        HStack {
            Text(config.name)
            Spacer()
            Text(config.price)
        }
        .font(.secondary, size: .title3, weight: .bold)
        .lineLimit(1)
        .minimumScaleFactor(0.65)
        .foregroundStyle(.primaryText)
    }
    
    private var detailView: some View {
        HStack(spacing: 5) {
            Text(config.symbol.uppercased())
                .foregroundStyle(.secondaryText)
                .font(.secondary, size: .subheadline, weight: .medium)
            Spacer()
            if let priceChange = config.priceChange {
                Text(priceChange)
                    .foregroundStyle(config.priceDirection.color)
                    .font(.secondary, size: .subheadline, weight: .semiBold)
            }
            
            if let priceChangePercentage = config.priceChangePercentage {
                Divider()
                    .background(.primaryText)
                    .frame(height: 10)
                Text(priceChangePercentage)
                    .foregroundStyle(config.priceDirection.color)
                    .font(.secondary, size: .subheadline, weight: .semiBold)
            }
        }
        .padding(.trailing, 5)
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            logoView
            
            VStack(alignment: .leading, spacing: 0) {
                headlineView
                detailView
            }
        }
    }
}

#Preview {
    VStack(spacing: 10) {
        ForEach(0...5, id: \.self) { (item) in
            CoinCellView(
                config: .init(
                    name: "Bitcoin",
                    symbol: "BTC",
                    imageURL: .init(string: "https://coin-images.coingecko.com/coins/images/52379/large/_COCA_Token_1.png?1733257913")!,
                    price: "100_000",
                    priceChange: "50",
                    priceChangePercentage: "1.25%",
                    priceDirection: item == 0 ? .none : item % 2 == 0 ? .up : .down
                )
            )
        }
    }
    .scrollable()
    .background(Color.background)
}
