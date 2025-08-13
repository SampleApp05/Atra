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
        self.service = WebSocketService(connector: connector)
    }
    
    @Test func testTaskDisconnectedError() async throws {
        await #expect {
            try await service.startReceiving()
            for try await message in await service.channel {
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
        let mockMessage = "{\"event\":\"status\",\"data\":{\"lastUpdated\":null,\"nextUpdate\":\"123\",\"isLoading\":true}}"
        connector.task.receiveResult = .success(.string(mockMessage))
        
        try await service.establishConnection(with: webSocketConfig, subsribeMessage: SubscribeMessage())
        try await service.startReceiving()
        
        for try await message in await service.channel {
            print("Message: \(message)")
            
            guard case .success(let receivedMessage) = message else {
                throw URLError(.unknown) // throw some error so the test fails if the message result is not success
            }
            
            switch receivedMessage {
            case .string(let data):
                #expect(data == mockMessage)
            default:
                throw URLError(.unknown) // throw some error so the test fails if the message != mockMessage
            }
            
            break
        }
    }
    
    @Test func testSocketReceiveFailure() async throws {
        let mockError = URLError(.unknown)
        connector.task.receiveResult = .failure(mockError)
        
        try await service.connect(with: webSocketConfig)
        try await service.startReceiving()
        
        for try await message in await service.channel {
            guard case .failure(let error) = message else {
                throw URLError(.unknown) // throw some error so the test fails if the message is not a failure
            }
            
            let isExpectedError: Bool = {
                guard let error = error as? URLError, error == mockError else {
                    return false
                }
                return true
            }()
            
            #expect(isExpectedError == true)
            break
        }
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
