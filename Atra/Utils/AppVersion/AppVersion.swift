//
//  AppVersion.swift
//  Atra
//
//  Created by Daniel Velikov on 3.07.25.
//

import SwiftUI

struct AppVersion: Codable {
    let version: String
    let variant: AppVersionVariant
}

enum AppVersionState {
    case upToDate
    case updateAvailable
    case outdated
    case incompatible
    
    var messageTitle: String { "App Update Available" }
    
    var messageDescription: String {
        switch self {
        case .upToDate:
            return "Your app is up to date." // This case should not trigger a notification
        case .updateAvailable:
            return "A new version of the app is available. Consider updating to access new features."
        case .outdated:
            return "A new version of the app is available. Please update to enjoy the latest features and improvements."
        case .incompatible:
            return "Your app version is incompatible with the server. Please update to continue using the app."
        }
    }
    
    var messsageImage: Image { Image(systemName: self == .incompatible ? "xmark.octagon" : "bell.fill") }
    
    var shouldShowUpdateNotification: Bool {
        switch self {
        case .updateAvailable, .outdated, .incompatible:
            return true
        default:
            return false
        }
    }
    
    var shouldForceUpdate: Bool {
        switch self {
        case .outdated, .incompatible:
            return true
        default:
            return false
        }
    }
}

enum AppVersionVariant: String, Codable {
    case required
    case recommended
    case suggested
}

struct Version: Comparable {
    let major: Int
    let minor: Int
    let patch: Int
    
    
    init?(_ value: String) {
        let componenets = value.split(separator: ".").compactMap { Int($0) }
        guard componenets.count == 3 else { return nil }
        
        major = componenets[0]
        minor = componenets[1]
        patch = componenets[2]
    }
    
    static func < (lhs: Version, rhs: Version) -> Bool {
        if lhs.major != rhs.major {
            return lhs.major < rhs.major
        }
        
        if lhs.minor != rhs.minor {
            return lhs.minor < rhs.minor
        }
        
        return lhs.patch < rhs.patch
    }
}
