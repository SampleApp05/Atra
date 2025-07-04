//
//  MockConfigService.swift
//  Atra
//
//  Created by Daniel Velikov on 4.07.25.
//

@testable import Atra

final class MockConfigService: ConfigService {
    var fetchCalled = false
    var fetchShouldThrow = false
    var fetchValueResponses: [AppConfigKey: Any] = [:]
    
    func configure() {
        
    }
    
    func fetch() async throws {
        fetchCalled = true
        if fetchShouldThrow { throw ConfigServiceError.fetchFailed(nil) }
    }
    
    func fetchValue<T>(for key: AppConfigKey) throws -> T {
        if let value = fetchValueResponses[key] as? T {
            return value
        }
        throw ConfigServiceError.fetchFailed(nil)
    }
    
    var updateStream: AsyncThrowingStream<Set<String>, Error> {
        AsyncThrowingStream { _ in }
    }
}
