//
//  MockNetworkConnector.swift
//  Atra
//
//  Created by Daniel Velikov on 25.06.25.
//

import Foundation

final class MockNetworkConnector: NetworkConnector {
    var result: Result<Data, Error>?
    var httpResponse: HTTPURLResponse?
    var resultSequence: [Result<Data, Error>] = []
    
    func execute(request: URLRequest) async throws -> (Data, URLResponse) {
        if let httpResponse = httpResponse {
            return (Data(), httpResponse)
        }
        
        let resultToReturn: Result<Data, Error>
        
        if resultSequence.isEmpty == false {
            resultToReturn = resultSequence.removeFirst()
        } else if let result = result {
            resultToReturn = result
        } else {
            fatalError("No result set")
        }
        
        switch resultToReturn {
        case .success(let data):
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (data, response)
        case .failure(let error):
            throw error
        }
    }
}
