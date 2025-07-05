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
    let logger: Logger = Logger()
    
    var body: some Scene {
        WindowGroup {
            LoggerContext.$current.withValue(logger) {
                ContentView(configService: delegate.configService)
            }
        }
    }
}
