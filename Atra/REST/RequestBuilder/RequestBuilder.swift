//
//  RequestBuilder.swift
//  Atra
//
//  Created by Daniel Velikov on 24.06.25.
//

import Foundation

struct RequestBuilder {
    // MARK: - Errors
    enum RequestError: Error {
        case invalidURL
        case failedToBuildGetParams
        case encodingFailed(Error)
    }
    
    private init() {}
    
    // MARK: - Private
    private static func validateURL(_ url: URL) throws {
        guard let scheme = url.scheme, ["http", "https"].contains(scheme.lowercased()),
              let host = url.host, host.isEmpty == false else {
            throw RequestError.invalidURL
        }
    }
        
    private static func buildGET(_ url: URL, params: [String: String]) throws -> URLRequest {
        try validateURL(url)
        
        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            throw RequestError.invalidURL
        }
        
        components.queryItems = params.map { URLQueryItem(name: $0.key, value: $0.value) }
        
        guard let finalURL = components.url else {
            throw RequestError.failedToBuildGetParams
        }
        
        return URLRequest(url: finalURL)
    }
    
    private static func buildWithBody(_ url: URL, body: RestBodyRepresentable?) throws -> URLRequest {
        try validateURL(url)
        
        var request = URLRequest(url: url)
        do {
            if let body = body {
                request.httpBody = try body.asRequestBody()
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
        } catch {
            throw RequestError.encodingFailed(error)
        }
        
        return request
    }
    
    // MARK: - Public
    static func build(
        with url: URL,
        method: HTTPMethod,
        headers: [String: String] = [:],
    ) throws -> URLRequest {
        var request: URLRequest
        
        switch method {
        case .get(let params):
            request = try buildGET(url, params: params)
        case .post(let body), .put(let body), .patch(let body), .delete(let body):
            request = try buildWithBody(url, body: body)
        }
        
        request.httpMethod = method.name
        headers.forEach {
            request.setValue($0.value, forHTTPHeaderField: $0.key)
        }
        
        return request
    }
}
