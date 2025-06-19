//
//  URLSession+Helper.swift
//  Atra
//
//  Created by Daniel Velikov on 23.06.25.
//

import Foundation

extension URLSession: NetworkConnector {
    func execute(request: URLRequest) async throws -> (Data, URLResponse) {
        try await data(for: request)
    }
}
