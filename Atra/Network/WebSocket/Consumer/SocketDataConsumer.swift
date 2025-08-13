//
//  SocketDataConsumer.swift
//  Atra
//
//  Created by Daniel Velikov on 11.08.25.
//

import Foundation

protocol SocketDataConsumer: AnyObject {
    associatedtype Response: Decodable
    associatedtype Storage: SocketDataStorage
    
    var client: WebSocketClient { get }
    var messageTask: VoidTask? { get }
    var dataStorage: Storage { get }
    
    func connect(with config: WebSocketConfig, subscribeMessage: SocketSubsribeMessage) async
    func disconnect(with code: URLSessionWebSocketTask.CloseCode) async
    func startReceiving()
    
    func handleSocketMessage(_ message: Result<WebSocketMessage, Error>)
    func extractMessageData(from message: WebSocketMessage) throws -> Data
    func handleSocketResponse(_ response: Response)
    func handleSocketConnectionError(_ error: Error)
}
