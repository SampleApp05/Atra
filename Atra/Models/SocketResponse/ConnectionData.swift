//
//  ConnectionData.swift
//  Atra
//
//  Created by Daniel Velikov on 6.08.25.
//

import Foundation

struct ConnectionData: Codable {
    let message: String
    let serverTime: String
    let lastUpdated: String?
    let nextUpdate: String
    let authMethod: String
}
