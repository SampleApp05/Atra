//
//  WebSocketServiceTests.swift
//  Atra
//
//  Created by Daniel Velikov on 1.07.25.
//

import Testing
import Foundation

@testable import Atra

@MainActor
struct WebSocketServiceTests {
    let connector: MockWebSocketConnector
    let service: WebSocketService
    let webSocketConfig: WebSocketConfig = .init(urlPath: "wss://test", headers: [:], protocols: [])
    
    init() {
        self.connector = .init()
        self.service = WebSocketService(webSocketConnector: connector)
    }
    
    @Test func testTaskDisconnectedError() async throws {
        await #expect {
            for try await message in await service.stream {
                print("Message: \(message)")
            }
        } throws: { (error) in
            print("Error: \(error)")
            guard let error  = error as? WebSocketError,
                  case .taskDisconnected = error else {
                return false
            }
            
            return true
        }
    }
    
    @Test func testSocketReceiveSuccess() async throws {
        let expectedMessage = "Hello Socket"
        connector.task.receiveResult = .success(.string(expectedMessage))
        
        try await service.connect(with: webSocketConfig)
        
        for try await message in await service.stream {
            print("Message: \(message)")
            
            guard case .string(let receivedMessage) = message else {
                throw URLError(.unknown) // throw some error so the test fails if the message is not a string
            }
            
            #expect(receivedMessage == expectedMessage)
            break
        }
    }
    
    @Test func testSocketReceiveFailure() async throws {
        let error = URLError(.unknown)
        connector.task.receiveResult = .failure(error)
        
        try await service.connect(with: webSocketConfig)
        
        await #expect {
            for try await message in await service.stream {
                print("Message: \(message)")
            }
        } throws: { (error) in
            print("Error: \(error)")
            guard let error  = error as? WebSocketError,
                  case .socketError(URLError.unknown) = error else {
                return false
            }
            
            return true
        }
        
        #expect(connector.task.closeCode.rawValue == URLSessionWebSocketTask.CloseCode.internalServerError.rawValue)
    }
    
    @Test func testConnectResumesTask() async throws {
        try await service.connect(with: webSocketConfig)
        #expect(connector.task.didResume == true)
    }
    
    @Test func testDisconnectCancelsTask() async throws {
        try await service.connect(with: webSocketConfig)
        await service.disconnect()
        
        #expect(connector.task.closeCode == .normalClosure)
    }
    
    @Test func testSendStringMessage() async throws {
        try await service.connect(with: webSocketConfig)
        
        let messageValue = "Hello socket"
        
        try await service.send(.string(messageValue))
        
        #expect(connector.task.sentMessages.first != nil)
        #expect(connector.task.sentMessages.count == 1)
        
        let containsMessage: Bool = {
            switch connector.task.sentMessages.first {
            case .some(.string(let value)):
                return value == messageValue
            default:
                return false
            }
        }()
        
        #expect(containsMessage == true)
    }
    
    @Test func testSendDataMessage() async throws {
        try await service.connect(with: webSocketConfig)
        
        let messageValue = "Hello socket"
        let data = Data(messageValue.utf8)
        
        try await service.send(.data(data))
        
        #expect(connector.task.sentMessages.first != nil)
        #expect(connector.task.sentMessages.count == 1)
        
        let containsMessage: Bool = {
            switch connector.task.sentMessages.first {
            case .data(let sentData):
                return sentData == data
            default:
                return false
            }
        }()
        
        #expect(containsMessage == true)
    }
    
    @Test func sendFailWhileDisconnected() async throws {
        await #expect {
            try await service.send(.string("Hello"))
        } throws: { (error) in
            guard let error = error as? WebSocketError,
                  case .taskDisconnected = error else {
                return false
            }
            return true
        }
    }
    
    @Test func reconnectSuccess() async throws {
        try await service.connect(with: webSocketConfig)
        #expect(connector.task.didResume == true)
        
        let newConfig = WebSocketConfig(urlPath: "wss://new-test", headers: [:], protocols: [])
        await service.disconnect()
        
        try await service.connect(with: newConfig)
        #expect(connector.task.didResume == true)
    }
    
    @Test func reconnectFailure() async throws {
        try await service.connect(with: webSocketConfig)
        #expect(connector.task.didResume == true)
        
        let newConfig = WebSocketConfig(urlPath: " ", headers: [:], protocols: [])
        await service.disconnect()
        
        await #expect {
            try await service.connect(with: newConfig)
        } throws: { (error) in
            guard let error = error as? WebSocketError,
                  case .invalidURL = error else {
                return false
            }
            return true
        }
    }
}
