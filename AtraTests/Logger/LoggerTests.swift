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
        
        let event = LogEvent(
            timestamp: timestamp,
            source: "TestSource",
            variant: .info,
            message: "Test message",
            data: nil
        )
        await logger.addEvent(event)
        let logs = await logger.logs(for: "TestSource")
        
        #expect(logs.count == 1)
        
        #expect(logs.first?.timestamp == timestamp)
        #expect(logs.first?.source == "TestSource")
        #expect(logs.first?.message == "Test message")
        #expect(logs.first?.variant == .info)
        #expect(logs.first?.data == nil)
    }

    @Test
    func testLogWithEncodableData() async throws {
        let logger = Logger()
        struct TestData: Codable, Equatable { let value: Int }
        let data = TestData(value: 42)
        
        await logger.log(
            timestamp: Date(),
            source: "TestSource",
            variant: .warning,
            message: "With data",
            data: data
        )
        
        let logs = await logger.logs(for: "TestSource")
        #expect(logs.count == 1)
        
        let logData = logs.first!.data!
        
        let decoded = try JSONDecoder().decode(TestData.self, from: logData)
        #expect(decoded == data)
    }

    @Test
    func testPruneLogsIfNeeded() async {
        let logger = Logger()
        
        let maxCount = 1000
        for i in 0..<(maxCount + 10) {
            let event = LogEvent(
                timestamp: Date(),
                source: "PruneSource",
                variant: .info,
                message: "Event \(i)",
                data: nil
            )
            await logger.addEvent(event)
        }
        let logs = await logger.logs(for: "PruneSource")
        #expect(logs.count == maxCount)
    }

    @Test
    func testLogsFilteringByVariant() async {
        let logger = Logger()
        
        let infoEvent = LogEvent(
            timestamp: Date(),
            source: "FilterSource",
            variant: .info,
            message: "Info",
            data: nil
        )
        
        let errorEvent = LogEvent(
            timestamp: Date(),
            source: "FilterSource",
            variant: .critical,
            message: "Error",
            data: nil
        )
        await logger.addEvent(infoEvent)
        await logger.addEvent(errorEvent)
        let errorLogs = await logger.logs(for: "FilterSource", by: .critical)
        
        #expect(errorLogs.count == 1)
        #expect(errorLogs.first?.variant == .critical)
    }
}
