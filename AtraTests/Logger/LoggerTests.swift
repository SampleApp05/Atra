//
//  LoggerTests.swift
//  Atra
//
//  Created by Daniel Velikov on 4.07.25.
//

import Foundation
import Testing
@testable import Atra

struct LoggerTests {
    @Test
    func testAddEventAndFetchLogs() async {
        let logger = Logger()
        let timestamp = Date()
        let source = "TestSource"
        let message = "Test Message"
        
        await logger.log(timestamp: timestamp, source: source, variant: .info, message: message)
        let logs = await logger.logs(for: source)
        
        #expect(logs.count == 1)
        
        #expect(logs.first?.timestamp == timestamp)
        #expect(logs.first?.source == source)
        #expect(logs.first?.message == message)
        #expect(logs.first?.variant == .info)
        #expect(logs.first?.data == nil)
    }

    @Test
    func testLogWithEncodableData() async throws {
        let logger = Logger()
        let source = "TestSource"
        let message = "With Data Message"
        
        struct TestData: Codable, Equatable { let value: Int }
        let data = TestData(value: 42)
        
        await logger.log(
            timestamp: Date(),
            source: "TestSource",
            variant: .warning,
            message: message,
            data: data
        )
        
        let logs = await logger.logs(for: source)
        #expect(logs.count == 1)
        
        let logData = logs.first!.data!
        
        let decoded = try JSONDecoder().decode(TestData.self, from: logData)
        #expect(decoded == data)
    }

    @Test
    func testPruneLogsIfNeeded() async {
        let logger = Logger()
        let source = "PruneSource"
        
        let maxCount = 1000
        for i in 0..<(maxCount + 10) {
            let message = "Event \(i)"
            await logger.log(timestamp: .init(), source: source, variant: .info, message: message)
        }
        
        let logs = await logger.logs(for: source)
        #expect(logs.count == maxCount)
    }

    @Test
    func testLogsFilteringByVariant() async {
        let logger = Logger()
        let source = "FilterSource"
        
        await logger.log(timestamp: .init(), source: source, variant: .info, message: "Info")
        await logger.log(timestamp: .init(), source: source, variant: .critical, message: "Error")

        let errorLogs = await logger.logs(for: source, by: .critical)
        
        #expect(errorLogs.count == 1)
        #expect(errorLogs.first?.variant == .critical)
    }
}
