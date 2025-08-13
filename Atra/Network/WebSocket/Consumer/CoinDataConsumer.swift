//
//  CoinDataConsumer.swift
//  Atra
//
//  Created by Daniel Velikov on 11.08.25.
//

import Foundation

@Observable
final class CoinDataConsumer<T: SocketDataStorage>: SocketDataConsumer where T.Element == Coin, T.SubsetID == WatchlistUpdateVariant {
    let client: WebSocketClient
    private(set) var messageTask: VoidTask? = nil
    private(set) var dataStorage: T
    
    init(client: WebSocketClient, dataStorage: T) {
        self.client = client
        self.dataStorage = dataStorage
    }
    
    func connect(with config: WebSocketConfig, subscribeMessage: SocketSubsribeMessage) async{
        do {
            try await client.connect(with: config)
            try await client.subscribe(with: subscribeMessage)
            startReceiving()
        } catch {
            handleSocketConnectionError(error)
        }
    }
    
    func startReceiving() {
        messageTask = Task {
            do {
                try await client.startReceiving()
                
                for await message in await client.channel {
                    handleSocketMessage(message)
                }
            } catch {
                handleSocketConnectionError(error)
            }
        }
    }
    
    func handleSocketResponse(_ response: SocketResponse) {
        switch response {
        case .connection(let data):
            print("Received data: \(data)")
        case .status(let data):
            print("Received status: \(data)")
        case .cacheUpdate(let data):
            dataStorage.updateCache(with: data.data)
        case .watchlistUpdate(let data):
            dataStorage.updateSubset(with: data.variant, data: data.data)
        case .error(let error):
            print("Received error: \(error)")
        }
    }
    
    func disconnect(with code: URLSessionWebSocketTask.CloseCode) async {
        await client.disconnect(with: code)
        messageTask?.cancel()
        messageTask = nil
    }
    
    func extractMessageData(from message: WebSocketMessage) throws -> Data {
        switch message {
        case .data(let data):
            return data
        case .string(let string):
            guard let data = string.data(using: .utf8) else {
                throw WebSocketError.unsupportedMessage
            }
            return data
            
        @unknown default:
            throw WebSocketError.unsupportedMessage
        }
    }
    
    func handleSocketMessage(_ message: Result<WebSocketMessage, Error>) {
        do {
            switch message {
            case .success(let data):
                let messageData = try extractMessageData(from: data)
                let response = try JSONDecoder().decode(SocketResponse.self, from: messageData)
                handleSocketResponse(response)
            case .failure(let error):
                handleSocketConnectionError(error)
            }
        } catch {
            handleSocketConnectionError(error)
        }
    }
    
    func handleSocketConnectionError(_ error: Error) {
        print("Error handling socket connection: \(error.localizedDescription)")
    }
}
