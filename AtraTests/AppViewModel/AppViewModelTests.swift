//
//  AppViewModelTests.swift
//  Atra
//
//  Created by Daniel Velikov on 4.07.25.
//


import Testing
@testable import Atra

struct AppViewModelTests {
    let service: MockConfigService
    let viewModel: AppViewModel
    
    init() {
        service = MockConfigService()
        viewModel = AppViewModel(configService: service)
    }
    
    @Test
    func testFetchRemoteConfigSuccess() async {
        service.fetchValueResponses[.version] = AppVersion(version: "1.0.0", variant: .recommended)
        service.fetchValueResponses[.watchlistAPIKey] = "test-key"
        
        await viewModel.fetchRemoteConfig()
        
        #expect(viewModel.requestState == .success)
        #expect(viewModel.configIsValid)
        #expect(viewModel.watchlistApiKey == "test-key")
    }
    
    @Test
    func testFetchRemoteConfigFailure() async {
        service.fetchShouldThrow = true
        
        await viewModel.fetchRemoteConfig()
        
        #expect(viewModel.requestState == .failure)
        #expect(viewModel.configIsValid == false)
    }
    
    @Test
    func testHandleApiKeyUpdateInvalidKey() {
        service.fetchValueResponses[.watchlistAPIKey] = ""
        
        viewModel.handleApiKeyUpdate()
        
        #expect(viewModel.configIsValid == false)
    }
    
    @Test
    func testHandleConfigUpdateUnsupportedKey() {
        // Should not throw or crash
        viewModel.handleConfigUpdate(for: ["unsupported_key"])
        #expect(true) // If we reach here, test passes
    }
    
    @Test
    func testShouldHandleAPIKeyUpdate() async throws {
        service.fetchValueResponses[.version] = AppVersion(version: "1.0.0", variant: .recommended) // intial fetch requires valid value
        
        let oldKey = "old-test-key"
        let newKey = "new-test-key"
        service.fetchValueResponses[.watchlistAPIKey] = oldKey
        await viewModel.fetchRemoteConfig()
        
        #expect(viewModel.watchlistApiKey == oldKey)
        
        service.fetchValueResponses[.watchlistAPIKey] = newKey
        
        viewModel.handleConfigUpdate(for: [AppConfigKey.watchlistAPIKey.rawValue])
        
        #expect(viewModel.watchlistApiKey == newKey)
        #expect(viewModel.configIsValid == true)
    }
}
