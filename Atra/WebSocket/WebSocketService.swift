//
//  WebSocketService.swift
//  Atra
//
//  Created by Daniel Velikov on 1.07.25.
//

import Foundation

enum WebSocketError: LocalizedError {
    case taskDisconnected
    case socketError(Error)
}

actor WebSocketService: WebSocketClient {
    struct Config {
        let url: URL
        let protocols: [String]
        
        init(url: URL, protocols: [String] = []) {
            self.url = url
            self.protocols = protocols
        }
    }
    
    private let webSocketConnector: WebSocketConnector
    private let config: Config
    
    private(set) var webSocketTask: WebSocketTask?
    
    private lazy var messageStream: WebSocketStream = AsyncThrowingStream { (continuation) in
        Task {
            await handleSocketMessage(continuation: continuation)
        }
    }
    
    var stream: WebSocketStream { messageStream }
    
    init(
        webSocketConnector: WebSocketConnector,
        config: Config
    ) {
        self.webSocketConnector = webSocketConnector
        self.config = config
    }
    
    // MARK: - Private
    func handleSocketMessage(continuation: WebSocketStream.Continuation) async {
        guard let webSocketTask else {
            continuation.finish(throwing: WebSocketError.taskDisconnected)
            return
        }
        
        while true {
            do {
                let message = try await webSocketTask.receive()
                continuation.yield(message)
            } catch {
                
                print("WebSocket error: \(error.localizedDescription)")
                continuation.finish(throwing: WebSocketError.socketError(error))
                
                disconnect(with: .internalServerError)
            }
        }
    }
    
    // MARK: - Public
    func connect() {
        webSocketTask = webSocketConnector.webSocketTask(for: config.url, protocols: config.protocols)
        webSocketTask?.resume()
    }
    
    func disconnect(with code: URLSessionWebSocketTask.CloseCode = .normalClosure) {
        webSocketTask?.cancel(with: code, reason: nil)
    }
    
    func send(_ message: WebSocketMessage) async throws {
        guard let webSocketTask, webSocketTask.closeCode == .invalid else {
            throw WebSocketError.taskDisconnected
        }
        
        try await webSocketTask.send(message)
    }
}
