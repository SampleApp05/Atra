//
//  AppDelegate.swift
//  Atra
//
//  Created by Daniel Velikov on 23.06.25.
//

import SwiftUI

extension Notification.Name {
    static let versionUpdated = Notification.Name("versionUpdated")
    static let watchlistAPIKeyUpdated = Notification.Name("watchlistAPIKeyUpdated")
}

class AppDelegate: NSObject, UIApplicationDelegate {
    let configService: ConfigService = FirebaseConfigService()
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        configService.configure()
        return true
    }
}

