//
//  NetworkConnector.swift
//  Atra
//
//  Created by Daniel Velikov on 23.06.25.
//

import Foundation

enum NetworkError: Error{
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case statusCode(Int)
    case decodingFailed(Error)
    case retryLimitReached
    case taskCancelled
}

protocol NetworkConnector {
    func execute(request: URLRequest) async throws -> (Data, URLResponse)
}
