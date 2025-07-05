//
//  LogEvent.swift
//  Atra
//
//  Created by Daniel Velikov on 4.07.25.
//

import Foundation

struct LogEvent {
    let timestamp: Date
    let source: String
    let variant: LogEventVariant
    let message: String
    let data: Data?
}

enum LogEventVariant: String {
    case info
    case warning
    case critical
    case requestMade
    case requestSuccess
    case requestFailure
}
