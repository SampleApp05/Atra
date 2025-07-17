//
//  WebSocketClient.swift
//  Atra
//
//  Created by Daniel Velikov on 1.07.25.
//

import SwiftUI
import AsyncAlgorithms

typealias WebSocketChannel = AsyncChannel<WebSocketMessage>

protocol WebSocketClient: Actor {
    var webSocketTask: WebSocketTask? { get }
    var channel: WebSocketChannel { get }
    
    var isConnected: Bool { get }
    
    func connect(with config: WebSocketConfig) throws
    func disconnect(with code: URLSessionWebSocketTask.CloseCode)
    
    func startReceiving()
    func stopReceivingIfNeeded()
    
    func handleSocketMessage() async
    func send(_ message: WebSocketMessage) async throws
}
