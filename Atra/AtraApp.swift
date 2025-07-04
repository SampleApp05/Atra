//
//  AtraApp.swift
//  Atra
//
//  Created by Daniel Velikov on 19.06.25.
//

import SwiftUI

@main
struct AtraApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ContentView(configService: delegate.configService)
        }
    }
}
