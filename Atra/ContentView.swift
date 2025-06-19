//
//  ContentView.swift
//  Atra
//
//  Created by Daniel Velikov on 19.06.25.
//

import SwiftUI

struct ContentView: View {
    @State var coordinator = AppCoordinator()
    
    var body: some View {
        coordinator.containerView
    }
}

#Preview {
    ContentView()
}
