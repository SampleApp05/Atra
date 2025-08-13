//
//  WebSocketService.swift
//  Atra
//
//  Created by Daniel Velikov on 1.07.25.
//

import SwiftUI
import AsyncAlgorithms

enum WebSocketError: LocalizedError {
    case invalidURL
    case couldNotConnect
    case taskDisconnected
    case unsupportedMessageFormat
    case invalidSubscribeMessage
    case unsupportedMessage
    case connectionClosed(Error?)
}

actor WebSocketService: WebSocketClient, Loggable {
    private(set) var receiveTask: VoidTask? = nil
    private(set) var webSocketTask: WebSocketTask?
    private(set) var channel: WebSocketChannel = .init()
    private(set) var connector: WebSocketConnector
    
    var isConnected: Bool { webSocketTask?.state == .running }
    
    init(connector: WebSocketConnector) {
        self.connector = connector
    }
    
    // MARK: - Private
    private func buildRequest(urlPath: String, headers: [String: String]) throws -> URLRequest {
        guard urlPath.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false, let url = URL(string: urlPath) else {
            throw WebSocketError.invalidURL
        }
        
        var request = URLRequest(url: url)
        headers.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }
        
        return request
    }
    
    // MARK: - Public
    func connect(with config: WebSocketConfig) throws {
        let request = try buildRequest(urlPath: config.urlPath, headers: config.headers)
        
        webSocketTask = connector.webSocketTask(for: request)
        webSocketTask?.resume()
        
        guard isConnected else {
            throw WebSocketError.couldNotConnect
        }
    }
    
    func send(_ message: WebSocketMessage) async throws {
        guard let webSocketTask, webSocketTask.closeCode == .invalid else {
            throw WebSocketError.taskDisconnected
        }
        
        try await webSocketTask.send(message)
    }
    
    func subscribe<T: SocketSubsribeMessage>(with message: T) async throws {
        let jsonData = try JSONEncoder().encode(message)
        
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            throw WebSocketError.invalidSubscribeMessage
        }
        
        try await send(.string(jsonString))
    }
    
    func establishConnection<T: SocketSubsribeMessage>(with config: WebSocketConfig, subsribeMessage: T) async throws {
        try connect(with: config)
        try await subscribe(with: subsribeMessage)
    }
    
    // MARK: - Message Handling
    func startReceiving() throws  {
        guard let webSocketTask, webSocketTask.closeCode == .invalid else {
            throw WebSocketError.taskDisconnected
        }
        
        stopReceiving() // Ensure any previous task is stopped
        
        receiveTask = Task {
            await handleSocketMessage()
        }
    }
    
    func stopReceiving() {
        guard receiveTask != nil else { return }
        
        receiveTask?.cancel()
        receiveTask = nil
        
        channel.finish()
        channel = .init()
    }
    
    func disconnect(with code: URLSessionWebSocketTask.CloseCode = .normalClosure) {
        webSocketTask?.cancel(with: code, reason: nil)
        stopReceiving()
    }
    
    func handleSocketMessage() async {
        guard let task =  webSocketTask else { return }
        
        while true {
            do {
                let message = try await task.receive()
                await channel.send(.success(message))
            } catch {
                await channel.send(.failure(error))
                disconnect(with: .normalClosure)
                break
            }
        }
    }
}
