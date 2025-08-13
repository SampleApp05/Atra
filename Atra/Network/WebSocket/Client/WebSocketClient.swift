//
//  WebSocketClient.swift
//  Atra
//
//  Created by Daniel Velikov on 1.07.25.
//

import SwiftUI
import AsyncAlgorithms

typealias WebSocketChannel = AsyncChannel<Result<WebSocketMessage, Error>>

protocol WebSocketClient: Actor {
    var connector: WebSocketConnector { get }
    var webSocketTask: WebSocketTask? { get }
    var channel: WebSocketChannel { get }
    var receiveTask: VoidTask? { get }
    
    var isConnected: Bool { get }
    
    func connect(with config: WebSocketConfig) throws
    func send(_ message: WebSocketMessage) async throws
    func subscribe<T: SocketSubsribeMessage>(with message: T) async throws
    func establishConnection<T: SocketSubsribeMessage>(with config: WebSocketConfig, subsribeMessage: T) async throws
    
    func startReceiving() throws
    func stopReceiving()
    
    func disconnect(with code: URLSessionWebSocketTask.CloseCode)
    
    func handleSocketMessage() async throws
}
