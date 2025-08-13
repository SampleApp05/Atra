//
//  MockWebSocketTask.swift
//  Atra
//
//  Created by Daniel Velikov on 1.07.25.
//

import Foundation
@testable import Atra

final class MockWebSocketTask: WebSocketTask {
    var didResume = false
    var didCancel = false
    var sentMessages: [WebSocketMessage] = []
    var receiveResult: Result<WebSocketMessage, Error>?
    
    var state: URLSessionTask.State = .running
    var closeCode: URLSessionWebSocketTask.CloseCode = .invalid
    
    func resume() {
        didResume = true
    }
    
    func cancel(with closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        self.closeCode = closeCode
        didCancel = true
        state = .canceling
    }
    
    func send(_ message: WebSocketMessage) async throws {
        sentMessages.append(message)
    }
    
    func receive() async throws -> WebSocketMessage {
        switch receiveResult {
        case .success(let message):
            return message
        case .failure(let error):
            throw error
        case .none:
            throw WebSocketError.taskDisconnected
        }
    }
}
