//
//  AppVersionEvaluator.swift
//  Atra
//
//  Created by Daniel Velikov on 3.07.25.
//

import Foundation

protocol VersionEvaluator {
    func fetchBundleVersion() -> String
    func evaluateAppVersion(against remoteVersion: AppVersion) -> AppVersionState
}

extension VersionEvaluator {
    func evaluateAppVersion(against remoteVersion: AppVersion) -> AppVersionState {
        let localVersion = fetchBundleVersion()
        
        guard let local = Version(localVersion),
              let remote = Version(remoteVersion.version) else {
            return .incompatible // If we cannot parse the version, consider it incompatible
        }
        
        guard local < remote else { return .upToDate }
        
        switch remoteVersion.variant {
        case .required:
            return .incompatible // Required version changes are incompatible
        case .recommended:
            return .outdated // Recommended version changes are considered outdated
        case .suggested:
            return .updateAvailable // Suggested version changes are considered updates
        }
    }
}

struct AppVersionEvaluator: VersionEvaluator {
    func fetchBundleVersion() -> String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
}
