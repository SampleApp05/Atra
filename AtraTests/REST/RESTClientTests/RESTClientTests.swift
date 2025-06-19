//
//  RESTClientTests.swift
//  Atra
//
//  Created by Daniel Velikov on 25.06.25.
//

import Testing
import Foundation
@testable import Atra

struct TestData: Codable, Equatable {
    let value: String
}

struct RESTClientTests {
    let mockConnector: MockNetworkConnector
    let client: RESTClient

    init() {
        mockConnector = MockNetworkConnector()
        client = RESTClient(connector: mockConnector)
    }

    @Test
    func testExecute_SuccessfulResponse_ReturnsDecodedData() async throws {
        let expected = TestData(value: "hello")
        let response = RESTResponse(status: 200, message: nil, data: expected)
        mockConnector.result = .success(try! JSONEncoder().encode(response))

        let request = URLRequest(url: URL(string: "https://test.com")!)
        let result: TestData = try await client.execute(request: request)

        #expect(result.value == expected.value)
    }

    @Test
    func testExecute_InvalidStatusCode_ThrowsStatusCodeError() async {
        mockConnector.httpResponse = HTTPURLResponse(url: URL(string: "https://test.com")!, statusCode: 404, httpVersion: nil, headerFields: nil)!

        let request = URLRequest(url: URL(string: "https://test.com")!)
        await #expect {
            _ = try await client.execute(request: request) as TestData
        } throws: { (error) in
            guard let networkError = error as? NetworkError,
                  case .statusCode(404) = networkError else {
                return false }
            return true
        }
    }

    @Test
    func testExecuteWithRetry_RetriesOnRetryableError() async throws {
        mockConnector.resultSequence = [
            .failure(URLError(.notConnectedToInternet)),
            .success(try! JSONEncoder().encode(RESTResponse(status: 200, message: nil, data: TestData(value: "ok"))))
        ]
        
        print(mockConnector.resultSequence)

        let request = URLRequest(url: URL(string: "https://test.com")!)
        let result: TestData = try await client.executeWithRetry(request: request, retryConfig: .standard)
        #expect(result.value == "ok")
    }
}
