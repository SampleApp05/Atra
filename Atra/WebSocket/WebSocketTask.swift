//
//  WebSocketTask.swift
//  Atra
//
//  Created by Daniel Velikov on 28.06.25.
//

import Foundation
typealias WebSocketMessage = URLSessionWebSocketTask.Message

protocol WebSocketTask {
    var closeCode: URLSessionWebSocketTask.CloseCode { get }
    
    func resume()
    func cancel(with closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?)
    func send(_ message: WebSocketMessage) async throws
    func receive() async throws -> WebSocketMessage
}

extension URLSessionWebSocketTask: WebSocketTask { }
