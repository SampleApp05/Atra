//
//  Coordinator.swift
//  Atra
//
//  Created by Daniel Velikov on 19.06.25.
//

import SwiftUI

protocol Coordinator: Observable, AnyObject {
    associatedtype Flow: Hashable
    associatedtype RootView: View
    associatedtype Content: View
    
    var containerView: RootView { get }
    
    func navigate(to flow: Flow)
    @ViewBuilder func content(for flow: Flow) -> Content
}
