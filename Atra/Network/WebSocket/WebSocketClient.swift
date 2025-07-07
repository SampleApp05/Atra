//
//  WebSocketClient.swift
//  Atra
//
//  Created by Daniel Velikov on 1.07.25.
//

import Foundation

typealias WebSocketStream = AsyncThrowingStream<WebSocketMessage, Error>

protocol WebSocketClient: Actor {
    var stream: WebSocketStream { get }
    var webSocketTask: WebSocketTask? { get }
    
    func connect() throws
    func disconnect(with code: URLSessionWebSocketTask.CloseCode)
    func handleSocketMessage(continuation: WebSocketStream.Continuation) async
    func send(_ message: WebSocketMessage) async throws
}
