//
//  NavigationStackCoordinator.swift
//  Atra
//
//  Created by Daniel Velikov on 19.06.25.
//

import SwiftUI

protocol NavigationStackCoordinator: Coordinator {
    var path: [Flow] { get set }
    
    func start(with stack: [Flow])
    func goBack(to flow: Flow?)
}

extension NavigationStackCoordinator {
    func start(with stack: [Flow] = []) {
        self.path = stack
    }
    
    func navigate(to flow: Flow) {
        path.append(flow)
    }
    
    func goBack(to flow: Flow? = nil) {
        guard let target = flow else {
            _ = path.popLast() // could be empty, which is fine
            return
        }
        
        guard let index = path.firstIndex(of: target) else {
            preconditionFailure("Flow \(target) not found in data source.")
        }
        
        let range = index + 1..<path.endIndex
        guard range.count > 0 else {
            preconditionFailure("Cannot go back to flow \(target) as it is the last in the stack.")
        }
        
        path.removeSubrange(range)
    }
}
