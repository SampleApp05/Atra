//
//  ErrorData.swift
//  Atra
//
//  Created by Daniel Velikov on 6.08.25.
//

import Foundation

struct ErrorData: Codable {
    let code: Int
    let message: String
    let action: String? // potentially move to enum
    let requestID: String?
    let timestamp: String
    let severity: String // move to enum
}
