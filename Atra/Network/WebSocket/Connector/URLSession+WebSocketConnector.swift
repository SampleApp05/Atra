//
//  URLSession+WebSocketConnector.swift
//  Atra
//
//  Created by Daniel Velikov on 11.08.25.
//

import Foundation

extension URLSession: WebSocketConnector {
    func webSocketTask(for url: URL, protocols: [String] = []) -> WebSocketTask {
        webSocketTask(with: url, protocols: protocols)
    }
    
    func webSocketTask(for request: URLRequest) -> WebSocketTask {
        webSocketTask(with: request)
    }
}
