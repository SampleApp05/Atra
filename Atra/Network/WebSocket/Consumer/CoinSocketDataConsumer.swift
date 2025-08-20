//
//  CoinSocketDataConsumer.swift
//  Atra
//
//  Created by Daniel Velikov on 11.08.25.
//

import Foundation

protocol CoinSocketDataConsumer: AnyObject {
    var client: WebSocketClient { get }
    var messageTask: VoidTask? { get }
    var cacheProvider: CoinCacheProvider { get }
    var watchlistProvider: WatchlistProvider { get }
    
    func connect(with config: WebSocketConfig, subscribeMessage: SocketSubsribeMessage) async
    func disconnect(with code: URLSessionWebSocketTask.CloseCode) async
    func startReceiving()
    
    func handleSocketMessage(_ message: Result<WebSocketMessage, Error>)
    func extractMessageData(from message: WebSocketMessage) throws -> Data
    func handleSocketResponse(_ response: SocketResponse)
    func handleSocketConnectionError(_ error: Error)
}
