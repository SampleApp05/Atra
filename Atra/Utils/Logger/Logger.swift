//
//  Logger.swift
//  Atra
//
//  Created by Daniel Velikov on 4.07.25.
//

import Foundation

enum LoggerContext {
    @TaskLocal static var current: Logger?
}

actor Logger {
    typealias FilterClosure = @Sendable (LogEvent) -> Bool
    
    private let maxEventCount = 1000
    private var logs: [LogEvent] = []
    private var sourceLogs: [String: [LogEvent]] = [:]
    
    private func pruneLogsIfNeeded(source: String) {
        if logs.count >= maxEventCount {
            logs.removeFirst(logs.count - maxEventCount + 1)
        }
        
        if let count = sourceLogs[source]?.count, count >= maxEventCount {
            sourceLogs[source]?.removeFirst(count - maxEventCount + 1)
        }
    }
    
    private func fetchLogs(for source: String?) -> [LogEvent] {
        guard let source else { return logs }
        return sourceLogs[source] ?? []
    }
    
    func addEvent(_ event: LogEvent) {
        pruneLogsIfNeeded(source: event.source)
        logs.append(event)
        sourceLogs[event.source, default: []].append(event)
    }
    
    func log<T: Encodable>(
        timestamp: Date = .init(),
        source: String,
        variant: LogEventVariant,
        message: String,
        data: T? = nil
    ) {
#if DEBUG
        do {
            let encodedData = try data.map { try JSONEncoder().encode($0) }
            let event = LogEvent(
                timestamp: timestamp,
                source: source,
                variant: variant,
                message: message,
                data: encodedData
            )
            addEvent(event)
        } catch {
            print("⚠️ Failed to encode log data: \(error)")
        }
#endif
    }
    
    func logs(for source: String? = nil, preconditions: [FilterClosure] = []) -> [LogEvent] {
        var result = fetchLogs(for: source)
        for condition in preconditions {
            result = result.filter(condition)
        }
        return result.sorted { $0.timestamp > $1.timestamp }
    }
    
    func logs(for source: String? = nil, by variant: LogEventVariant) -> [LogEvent] {
        logs(for: source, preconditions: [{ $0.variant == variant }])
    }
    
    func clear() {
        logs.removeAll()
        sourceLogs.removeAll()
    }
}
