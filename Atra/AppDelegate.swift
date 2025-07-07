//
//  AppDelegate.swift
//  Atra
//
//  Created by Daniel Velikov on 23.06.25.
//

import SwiftUI

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
