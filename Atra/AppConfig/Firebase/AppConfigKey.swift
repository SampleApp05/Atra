//
//  AppConfigKey.swift
//  Atra
//
//  Created by Daniel Velikov on 2.07.25.
//

import Foundation

enum AppConfigKey: String {
    case version
    case watchlistAPIKey = "watchlist_api_key"
    
    var notificationName: Notification.Name {
        switch self {
        case .version:
            return .versionUpdated
        case .watchlistAPIKey:
            return .watchlistAPIKeyUpdated
        }
    }
}
