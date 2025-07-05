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

actor WebSocketService: WebSocketClient, Loggable {
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
            
            log(variant: .critical, message: "WebSocket task is nil. Cannot handle messages.")
            return
        }
        
        while true {
            do {
                let message = try await webSocketTask.receive()
                
                log(variant: .info, message: "Received message: \(message)")
                continuation.yield(message)
            } catch {
                continuation.finish(throwing: WebSocketError.socketError(error))
                
                log(variant: .critical, message: "WebSocket task disconnected with error: \(error.localizedDescription)")
                disconnect(with: .internalServerError)
            }
        }
    }
    
    // MARK: - Public
    func connect() {
        webSocketTask = webSocketConnector.webSocketTask(for: config.url, protocols: config.protocols)
        webSocketTask?.resume()
        
        log(variant: .info, message: "WebSocket task started for URL: \(config.url)")
    }
    
    func disconnect(with code: URLSessionWebSocketTask.CloseCode = .normalClosure) {
        webSocketTask?.cancel(with: code, reason: nil)
        log(variant: .info, message: "WebSocket task disconnected with code: \(code.rawValue)")
    }
    
    func send(_ message: WebSocketMessage) async throws {
        guard let webSocketTask, webSocketTask.closeCode == .invalid else {
            throw WebSocketError.taskDisconnected
        }
        
        try await webSocketTask.send(message)
        log(variant: .info, message: "WebSocket message sent: \(message)")
    }
}
