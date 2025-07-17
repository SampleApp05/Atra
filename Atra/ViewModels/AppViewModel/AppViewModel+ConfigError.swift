//
//  AppViewModel+ConfigError.swift
//  Atra
//
//  Created by Daniel Velikov on 4.07.25.
//

import Foundation

extension AppViewModel {
    enum ConfigError: LocalizedError {
        case invalidAppVersion
        case invalidWebSocketConfig
    }
}
