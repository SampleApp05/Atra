//
//  AppVersionEvaluatorTests.swift
//  Atra
//
//  Created by Daniel Velikov on 3.07.25.
//

import Foundation
import Testing
@testable import Atra

struct AppVersionEvaluatorTests {
    @Test
    func testInvalidBundleVersion() {
        var evaluator = MockAppVersionEvaluator()
        evaluator.bundleVersion = "1.0.v2"
        
        let remoteVersion = AppVersion(version: "1.0.0", variant: .required)
        #expect(evaluator.evaluateAppVersion(against: remoteVersion) == .incompatible)
    }
    
    @Test
    func testInvalidRemoteVersion() {
        var evaluator = MockAppVersionEvaluator()
        evaluator.bundleVersion = "1.0.0"
        
        let remoteVersion = AppVersion(version: "1.0.v2", variant: .required)
        #expect(evaluator.evaluateAppVersion(against: remoteVersion) == .incompatible)
    }
    
    @Test
    func testUpToDateVersion() {
        var evaluator = MockAppVersionEvaluator()
        evaluator.bundleVersion = "1.0.0"
        
        let remoteVersion = AppVersion(version: "1.0.0", variant: .required)
        #expect(evaluator.evaluateAppVersion(against: remoteVersion) == .upToDate)
    }
    
    @Test
    func testPatchVersion() {
        var evaluator = MockAppVersionEvaluator()
        evaluator.bundleVersion = "1.0.0"
        
        let remoteVersion = AppVersion(version: "1.0.1", variant: .suggested)
        #expect(evaluator.evaluateAppVersion(against: remoteVersion) == .updateAvailable)
    }
    
    @Test
    func testMinorVersion() {
        var evaluator = MockAppVersionEvaluator()
        evaluator.bundleVersion = "1.0.0"
        
        let remoteVersion = AppVersion(version: "1.1.0", variant: .recommended)
        #expect(evaluator.evaluateAppVersion(against: remoteVersion) == .outdated)
    }
    
    @Test
    func testMajorVersion() {
        var evaluator = MockAppVersionEvaluator()
        evaluator.bundleVersion = "1.0.0"
        
        let remoteVersion = AppVersion(version: "2.0.0", variant: .required)
        #expect(evaluator.evaluateAppVersion(against: remoteVersion) == .incompatible)
    }
}
