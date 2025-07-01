//
//  WebSocketConnector.swift
//  Atra
//
//  Created by Daniel Velikov on 1.07.25.
//

import Foundation

protocol WebSocketConnector {
    func webSocketTask(for url: URL, protocols: [String]) -> WebSocketTask
}

extension URLSession: WebSocketConnector {
    func webSocketTask(for url: URL, protocols: [String] = []) -> WebSocketTask {
        webSocketTask(with: url, protocols: protocols)
    }
}
