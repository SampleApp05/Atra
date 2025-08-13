////
////  AppViewModelTests.swift
////  Atra
////
////  Created by Daniel Velikov on 4.07.25.
////
//
//
//import Testing
//@testable import Atra
//
//struct AppViewModelTests {
//    let configService: MockConfigService
//    let webSocketClient: WebSocketClient
//    let viewModel: AppViewModel
//    
//    init() {
//        configService = MockConfigService()
//        webSocketClient = WebSocketService(connector: MockWebSocketConnector())
//        viewModel = AppViewModel(configService: configService, socketClient: webSocketClient)
//    }
//    
//    @Test
//    func testFetchRemoteConfigSuccess() async {
//        let webSocketConfig = WebSocketConfig(
//            urlPath: "wss://example.com/socket",
//            headers: ["Auth": "Token"],
//            protocols: []
//        )
//        
//        configService.fetchValueResponses[.version] = AppVersion(version: "1.0.0", variant: .recommended)
//        configService.fetchValueResponses[.webSocketConfig] = webSocketConfig
//        
//        await viewModel.fetchRemoteConfig()
//        
//        #expect(viewModel.requestState == .success)
//        #expect(viewModel.configIsValid)
//        #expect(viewModel.appConfig.webSocketConfig == webSocketConfig)
//    }
//    
//    @Test
//    func testFetchRemoteConfigFailure() async {
//        configService.fetchShouldThrow = true
//        
//        await viewModel.fetchRemoteConfig()
//        
//        #expect(viewModel.requestState == .failure)
//        #expect(viewModel.configIsValid == false)
//    }
//    
//    @Test
//    func testHandleInvalidWebSocketConfig() {
//        configService.fetchValueResponses[.webSocketConfig] = WebSocketConfig(urlPath: "")
//        
//        viewModel.handleWebSocketConfigUpdate()
//        
//        #expect(viewModel.configIsValid == false)
//    }
//    
//    @Test
//    func testHandleConfigUpdateUnsupportedKey() {
//        // Should not throw or crash
//        viewModel.handleConfigUpdate(for: ["unsupported_key"])
//        #expect(true) // If we reach here, test passes
//    }
//    
//    @Test
//    func testShouldHandleWebSocketConfigUpdate() async throws {
//        let oldConfig = WebSocketConfig(urlPath: "old")
//        let newConfig = WebSocketConfig(urlPath: "new")
//        
//        configService.fetchValueResponses[.version] = AppVersion(version: "1.0.0", variant: .recommended)
//        configService.fetchValueResponses[.webSocketConfig] = oldConfig
//        
//        await viewModel.fetchRemoteConfig()
//        
//        #expect(viewModel.appConfig.webSocketConfig == oldConfig)
//        #expect(viewModel.configIsValid == true)
//        
//        configService.fetchValueResponses[.webSocketConfig] = newConfig
//        
//        viewModel.handleConfigUpdate(for: [AppConfigKey.webSocketConfig.rawValue])
//        
//        #expect(viewModel.appConfig.webSocketConfig == newConfig)
//        #expect(viewModel.configIsValid == true)
//    }
//}
