//
//  CoinDataConsumerTests.swift
//  Atra
//
//  Created by Daniel Velikov on 12.08.25.
//

import Foundation
import Testing
@testable import Atra

struct CoinDataConsumerTests {
    let connector: MockWebSocketConnector
    let client: WebSocketClient
    let storage: CoinDataStorage
    let sut: CoinDataConsumer<CoinDataStorage>
    
    let config = WebSocketConfig(urlPath: "ws://example.com/socket")
    let subscribeMessage: any SocketSubsribeMessage = SubscribeMessage()
    
    init() {
        connector = MockWebSocketConnector()
        client = WebSocketService(connector: connector)
        storage = .init()
        sut = CoinDataConsumer(client: client, dataStorage: storage)
    }
    
    @Test
    func testConnection() async throws {
        await sut.connect(with: config, subscribeMessage: subscribeMessage)
        
        #expect(connector.task.sentMessages.count == 1)
        #expect(connector.task.didResume == true)
        #expect(await client.isConnected == true)
        #expect(sut.messageTask != nil)
    }
    
    @Test
    func testDisconnect() async throws {
        await sut.connect(with: config, subscribeMessage: subscribeMessage)
        await sut.disconnect(with: .abnormalClosure)
        
        #expect(connector.task.didCancel == true)
        #expect(connector.task.sentMessages.count == 1) // Initial subscribe message
        #expect(connector.task.closeCode == .abnormalClosure)
        #expect(await client.isConnected == false)
        #expect(sut.messageTask == nil)
    }
    
    @Test
    func testExtractDataMessage() throws {
        let mockMessage = "Test message"
        let mockData = Data(mockMessage.utf8)
        
        let resultData = try sut.extractMessageData(from: .data(mockData))
        let resultMessage = String(data: resultData, encoding: .utf8)
        
        #expect(resultData == mockData)
        #expect(resultMessage == mockMessage)
    }
    
    @Test
    func testExtractStringMessage() throws {
        let mockMessage = "Test string message"
        let mockData = Data(mockMessage.utf8)
        
        let resultData = try sut.extractMessageData(from: .string(mockMessage))
        let resultMessage = String(data: resultData, encoding: .utf8)
        
        #expect(resultData == mockData)
        #expect(resultMessage == mockMessage)
    }
    
    @Test
    func testCacheUpdateEvent() {
        let mockMessage = """
{
  "event": "cache_update",
  "data": {
    "lastUpdated": "2025-08-12T14:00:00Z",
    "nextUpdate": "2025-08-12T18:00:00Z",
    "data": [
      {
        "id": "bitcoin",
        "name": "Bitcoin",
        "image": "https://example.com/bitcoin.png",
        "current_price": 35000.0,
        "market_cap": 650000000000.0,
        "market_cap_rank": 1,
        "price_change_24h": 500.0,
        "price_change_percentage_24h": 1.44
      },
      {
        "id": "ethereum",
        "name": "Ethereum",
        "image": "https://example.com/ethereum.png",
        "current_price": 2400.0,
        "market_cap": 280000000000.0,
        "market_cap_rank": 2,
        "price_change_24h": -50.0,
        "price_change_percentage_24h": -2.04
      }
    ]
  }
}
"""
        sut.handleSocketMessage(.success(.string(mockMessage)))
        let btcData = storage.fetchData(for: "bitcoin")
        let ethData = storage.fetchData(for: "ethereum")
        
        #expect(storage.cache.count == 2)
        #expect(btcData != nil)
        #expect(ethData != nil)
        #expect(btcData?.id == "bitcoin")
        #expect(ethData?.id == "ethereum")
    }
    
    @Test
    func testWatchlistUpdateEvent() async throws {
        let mockMessage = """
{
  "event": "watchlist_update",
  "data": {
    "variant": "top_marketcap",
    "lastUpdated": "2025-08-12T14:00:00Z",
    "nextUpdate": "2025-08-12T18:00:00Z",
    "data": [
      "bitcoin",
      "ethereum",
      "ripple"
    ]
  }
}
"""
        
        sut.handleSocketMessage(.success(.string(mockMessage)))
        let watchlistIds = storage.subsets[.marketcap]
        
        #expect(storage.allSubsets.count == 1)
        #expect(watchlistIds != nil)
        #expect(watchlistIds?.count == 3)
        #expect(watchlistIds?[0] == "bitcoin")
        #expect(watchlistIds?[1] == "ethereum")
        #expect(watchlistIds?[2] == "ripple")
    }
}
