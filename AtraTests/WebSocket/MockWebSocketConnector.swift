//
//  MockWebSocketConnector.swift
//  Atra
//
//  Created by Daniel Velikov on 1.07.25.
//

import Foundation
@testable import Atra

struct MockWebSocketConnector: WebSocketConnector {
    let task: MockWebSocketTask
    
    init() {
        self.task = MockWebSocketTask()
    }
    
    func webSocketTask(for url: URL, protocols: [String]) -> WebSocketTask {
        return task
    }
}
