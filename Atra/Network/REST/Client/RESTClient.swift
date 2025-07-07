//
//  RESTClient.swift
//  Atra
//
//  Created by Daniel Velikov on 23.06.25.
//

import Foundation

struct RESTResponse<T: Codable>: Codable {
    let status: Int
    let message: String?
    let data: T?
}

enum RESTError: LocalizedError {
    case missingData
    case internalAPI(code: Int, message: String?)
    
    var errorDescription: String? {
        switch self {
        case .missingData:
            return "Response data is missing"
        case .internalAPI(_, let message):
            return message
        }
    }
}

final class RESTClient: Loggable {
    private static let successStatusRange: Set<Int> = Set(200...299)
    
    private let connector: NetworkConnector
    
    init(connector: NetworkConnector) {
        self.connector = connector
    }
    
    // MARK: - Private
    private func decodeResponse<T: Codable>(data: Data) throws -> T {
        let apiResponse = try JSONDecoder().decode(RESTResponse<T>.self, from: data)
        
        guard Self.successStatusRange.contains(apiResponse.status) else {
            throw RESTError.internalAPI(code: apiResponse.status, message: apiResponse.message)
        }
        
        guard let responseData = apiResponse.data else {
            throw RESTError.missingData
        }
        
        return responseData
    }
    
    private func shouldRetry(for error: Error, errorCodes: Set<Int>) -> Bool {
        guard let networkError = error as? NetworkError else {
            return false
        }
        
        let errorCode: Int?
        
        switch networkError {
        case .statusCode(let code):
            errorCode = code
        case .requestFailed(let error as URLError):
            errorCode = error.code.rawValue
        case .requestFailed(let error as RESTError):
            switch error {
            case .internalAPI(let code, _):
                errorCode = code
            default:
                errorCode = nil
            }
        default:
            errorCode = nil
        }
        
        guard let code = errorCode else {
            return false
        }
        
        return errorCodes.contains(code)
    }
    
    // MARK: - Public
    func execute<T: Codable>(request: URLRequest) async throws -> T {
        let (data, response): (Data, URLResponse)
        
        do {
            (data, response) = try await connector.execute(request: request)
        } catch {
            log(variant: .requestFailure, message: "Network request failed for URL: \(request.url?.absoluteString ?? "Unknown URL") with error: \(error.localizedDescription)")
            throw NetworkError.requestFailed(error)
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            log(variant: .requestFailure, message: "Invalid response type for URL: \(request.url?.absoluteString ?? "Unknown URL")")
            throw NetworkError.invalidResponse
        }
        
        guard Self.successStatusRange.contains(httpResponse.statusCode) else {
            log(variant: .requestFailure, message: "Request failed with status code \(httpResponse.statusCode) for URL: \(request.url?.absoluteString ?? "Unknown URL")")
            throw NetworkError.statusCode(httpResponse.statusCode)
        }
        
        let networkResponse: T
        do {
            networkResponse = try decodeResponse(data: data)
        } catch {
            log(variant: .requestFailure, message: "Failed to decode response for URL: \(request.url?.absoluteString ?? "Unknown URL") with error: \(error.localizedDescription)")
            throw NetworkError.decodingFailed(error)
        }
        
        return networkResponse
    }
    
    func executeWithRetry<T: Codable>(
        request: URLRequest,
        retryConfig: RetryConfig = .standard
    ) async throws -> T {
        var retryAttempts = 0;
        var delay = retryConfig.delay
        
        while retryAttempts < retryConfig.maxRetries {
            do {
                return try await execute(request: request)
            } catch {
                retryAttempts += 1
                
                guard shouldRetry(for: error, errorCodes: retryConfig.retryableStatusCodes) else {
                    throw error
                }
                
                do {
                    try await Task.sleep(nanoseconds: delay.inNanoSeconds)
                } catch {
                    log(variant: .warning, message: "Task cancelled during retry delay for request: \(request.url?.absoluteString ?? "Unknown URL")")
                    throw NetworkError.taskCancelled
                }
                
                delay = delay * 2
            }
        }
        
        log(variant: .critical, message: "Retry limit reached for request: \(request.url?.absoluteString ?? "Unknown URL") after \(retryAttempts) attempts.")
        throw NetworkError.retryLimitReached
    }
}
