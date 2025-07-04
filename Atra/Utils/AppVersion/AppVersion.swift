//
//  AppVersion.swift
//  Atra
//
//  Created by Daniel Velikov on 3.07.25.
//

import Foundation

struct AppVersion: Codable {
    let version: String
    let variant: AppVersionVariant
}

enum AppVersionState {
    case upToDate
    case updateAvailable
    case outdated
    case incompatible
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
