//
//  FirebaseConfigServiceTests.swift
//  Atra
//
//  Created by Daniel Velikov on 2.07.25.
//

import Foundation
import Testing
@testable import Atra

struct FirebaseConfigServiceTests {
    let fetcher: MockFirebaseFetcher
    let service: FirebaseConfigService
    
    init() {
        self.fetcher = MockFirebaseFetcher()
        service = FirebaseConfigService(fetcher: fetcher)
    }
    
    @Test
    func testConfigureSetsSettings() {
        let mockFetcher = MockFirebaseFetcher()
        let service = FirebaseConfigService(fetcher: mockFetcher)
        service.configure()
        #expect(mockFetcher.configSettings.minimumFetchInterval == 3600)
    }

    @Test
    func testFetchSuccess() async throws {
        fetcher.applyUpdatesResult = (true, nil)
        try await service.fetch()
    }
    
    @Test
    func testFetchFailed() async {
        let mockError = URLError(.badURL)
        
        fetcher.fetchResult = .failure(mockError)
        
        await #expect {
            try await service.fetch()
        } throws: { error in
            guard let configError = error as? ConfigServiceError,
                  case .fetchFailed(let thrownError) = configError,
                  (thrownError as? URLError) == mockError
            else {
                return false
            }
            return true
        }
    }

    @Test
    func testFetchValueSuccess() throws {
        let key = AppConfigKey.version
        let value = "1.0.0"
        
        let data = try! JSONEncoder().encode(value)
        fetcher.setValue(data, forKey: key.rawValue)
        
        let result: String = try service.fetchValue(for: key)
        #expect(result == value)
    }
    
    @Test
    func testFetchValueFailure() {
        let key = AppConfigKey.version
        let value = "1"
        
        let data = try! JSONEncoder().encode(value)
        fetcher.setValue(data, forKey: key.rawValue)
        
        #expect {
            let _: Int = try service.fetchValue(for: key)
        } throws: { error in
            guard let configError = error as? ConfigServiceError,
                  case .decodingFailed(let key, _) = configError,
                  key == AppConfigKey.version else {
                return false
            }
            return true
        }
    }
    
    @Test
    func testUpdateListenerSuccess() async throws {
        let expectedResult = MockRemoteConfigUpdate()
        let expectedMessage: Set<String> = ["version"]
        
        expectedResult.keys = expectedMessage
        
        fetcher.updateResult = (expectedResult, nil)
        
        for try await message in service.updateStream {
            #expect(message == expectedMessage)
            break
        }
    }
    
    @Test
    func testUpdateListenerFailure() async {
        let expectedError = URLError(.unknown)
        fetcher.updateResult = (nil, expectedError)
        
        await #expect {
            for try await message in service.updateStream {
                print("Message: \(message)")
            }
        } throws: { (error) in
            guard let configError = error as? ConfigServiceError,
                    case .updateFailed(let thrownError) = configError,
                  (thrownError as? URLError) == expectedError else {
                return false
            }
            return true
        }
    }
}
