//
//  CoinDataStorageTests.swift
//  Atra
//
//  Created by Daniel Velikov on 12.08.25.
//

import Foundation
import Testing
@testable import Atra

struct CoinDataStorageTests {
    let mockCoinArray: [Coin] = [
        .init(
            id: "bitcoin",
            name: "Bitcoin",
            symbol: "BTC",
            imageURL: URL(string: "btc_image_url")!,
            price: 30000.0,
            marketCap: 600000000000,
            marketCapRank: 1,
            priceChange24h: 100.5,
            priceChangePercentage24h: 2.15
        ),
        .init(
            id: "ethereum",
            name: "Ethereum",
            symbol: "ETH",
            imageURL: URL(string: "eth_image_url")!,
            price: 2000.0,
            marketCap: 250000000000,
            marketCapRank: 2,
            priceChange24h: -50.0,
            priceChangePercentage24h: -2.5
        )
    ]
    
    let sut = CoinCacheService()
    
    @Test
    func shouldUpdateCache() {
        sut.updateCache(with: mockCoinArray)
        
        #expect(sut.cache.count == mockCoinArray.count)
        #expect(sut.fetchData(for: mockCoinArray[0].id) == mockCoinArray[0])
        #expect(sut.fetchData(for: mockCoinArray[1].id) == mockCoinArray[1])
    }
}
