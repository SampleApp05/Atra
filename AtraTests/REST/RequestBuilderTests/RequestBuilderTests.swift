//
//  RequestBuilderTests.swift
//  Atra
//
//  Created by Daniel Velikov on 25.06.25.
//

import Foundation
import Testing
@testable import Atra

struct DummyBody: RestBodyRepresentable {
    func asRequestBody() throws -> Data {
        return Data([0x01, 0x02, 0x03])
    }
}

struct FailingBody: RestBodyRepresentable {
    struct DummyError: Error {}
    func asRequestBody() throws -> Data {
        throw DummyError()
    }
}

struct RequestBuilderTests {
    @Test
    func testBuildGETRequest_Success() throws {
        let url = URL(string: "https://example.com")!
        let params = ["foo": "bar", "baz": "qux"]
        let method = HTTPMethod.get(params: params)
        let request = try RequestBuilder.build(with: url, method: method)
        let components = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)
        let queryItems = components?.queryItems?.reduce(into: [String: String]()) { $0[$1.name] = $1.value }
        #expect(queryItems == params)
        #expect(request.httpMethod == "GET")
    }

    @Test
    func testBuildGETRequest_InvalidURL_Throws() {
        let invalidURL = URL(string: "httfsp://[invalid-url]")!
        let method = HTTPMethod.get()
        
        #expect {
            _ = try RequestBuilder.build(with: invalidURL, method: method)
        } throws: { (error) in
            guard let requestError = error as? RequestBuilder.RequestError,
                  case .invalidURL = requestError else {
                return false }
            return true
        }
    }

    @Test
    func testBuildWithBody_Success() throws {
        let url = URL(string: "https://example.com")!
        let body = DummyBody()
        let method = HTTPMethod.post(body: body)
        let request = try RequestBuilder.build(with: url, method: method)
        #expect(request.httpMethod == "POST")
        #expect(request.value(forHTTPHeaderField: "Content-Type") == "application/json")
        
        let requestBody = try body.asRequestBody()
        #expect(request.httpBody == requestBody)
    }

    @Test
    func testBuildWithBody_EncodingFails_Throws() {
        let url = URL(string: "https://example.com")!
        let body = FailingBody()
        let method = HTTPMethod.post(body: body)
        
        #expect {
            _ = try RequestBuilder.build(with: url, method: method)
        } throws: { (error) in
            guard let requestError = error as? RequestBuilder.RequestError,
                  case .encodingFailed = requestError else {
                return false }
            return true
        }
    }
}
