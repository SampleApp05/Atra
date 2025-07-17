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
    case socketError(Error)
    case unsupportedMessageFormat
    case invalidSubscribeMessage
}

actor WebSocketService: WebSocketClient, Loggable {
    private var receiveTask: Task<Void, Never>? = nil
    
    private let webSocketConnector: WebSocketConnector
    private(set) var webSocketTask: WebSocketTask?
    private(set) var channel: WebSocketChannel = .init()
    
    var isConnected: Bool { webSocketTask?.state == .running }
    
    init(webSocketConnector: WebSocketConnector) {
        self.webSocketConnector = webSocketConnector
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
    func startReceiving() {
        stopReceivingIfNeeded() // Ensure any previous task is stopped
        
        receiveTask = Task {
            await handleSocketMessage()
        }
    }
    
    func stopReceivingIfNeeded() {
        guard receiveTask != nil else { return }
        
        receiveTask?.cancel()
        receiveTask = nil
        
        channel.finish()
        channel = .init()
    }
    
    func handleSocketMessage() async {
        guard let webSocketTask else {
            log(variant: .critical, message: "WebSocket task is nil. Cannot handle messages.")
            return
        }
        
        while true {
            do {
                let message = try await webSocketTask.receive()
                print("message: \(message)")
                log(variant: .info, message: "Received WebSocket message")
                await channel.send(message)
            } catch {
                log(variant: .critical, message: "WebSocket task disconnected with error: \(error.localizedDescription)")
                print("WebSocket task disconnected with error: \(error)")
                break
                //disconnect(with: .internalServerError)
            }
        }
    }
    
    func connect(with config: WebSocketConfig) throws {
        let request = try buildRequest(urlPath: config.urlPath, headers: config.headers)
        
        webSocketTask = webSocketConnector.webSocketTask(for: request)
        webSocketTask?.resume()
        
        guard isConnected else {
            throw WebSocketError.couldNotConnect
        }
        
        startReceiving()
        
        log(variant: .info, message: "WebSocket task started for URL: \(config.urlPath)")
    }
    
    func disconnect(with code: URLSessionWebSocketTask.CloseCode = .normalClosure) {
        webSocketTask?.cancel(with: code, reason: nil)
        stopReceivingIfNeeded()
        
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
