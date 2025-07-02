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
    
    init() {
        self.connector = .init()
        self.service = WebSocketService(webSocketConnector: connector, config: .init(url: URL(string: "wss://test")!))
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
        
        await service.connect()
        
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
        
        await service.connect()
        
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
        
        #expect(connector.task.closeCode == .internalServerError)
    }
    
    @Test func testConnectResumesTask() async {
        await service.connect()
        #expect(connector.task.didResume == true)
    }
    
    @Test func testDisconnectCancelsTask() async {
        await service.connect()
        await service.disconnect()
        
        #expect(connector.task.closeCode == .normalClosure)
    }
    
    @Test func testSendStringMessage() async throws {
        await service.connect()
        
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
        await service.connect()
        
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
    
    @Test func sendSendWhileDisconnected() async throws {
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
}
