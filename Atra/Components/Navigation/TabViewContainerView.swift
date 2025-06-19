//
//  TabViewContainerView.swift
//  Atra
//
//  Created by Daniel Velikov on 23.06.25.
//

import SwiftUI

protocol TabViewContentProvider: Coordinator {
    var selectedFlow: Flow { get set }
    var tabs: [Flow] { get }
    
    func start(with initial: AppFlow, tabs: [AppFlow]?)
}

struct TabViewContainerView<T: TabViewContentProvider>: View {
    @Bindable private var provider: T
    
    init(provider: T) {
        self.provider = provider
    }
    
    var body: some View {
        TabView(selection: $provider.selectedFlow) {
            ForEach(provider.tabs, id: \.self) { flow in
                provider.content(for: flow)
                    .tabItem {
                        Text("\(flow)")
                    }
                    .tag(flow)
            }
        }
    }
}
