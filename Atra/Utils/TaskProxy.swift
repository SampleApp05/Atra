//
//  TaskProxy.swift
//  Atra
//
//  Created by Daniel Velikov on 8.08.25.
//

import Foundation

protocol Taskable: Actor {
    func task(for id: AnyHashable) -> VoidTask?
    func startTask(with id: AnyHashable, operation: VoidTask)
    func cancelTask(with id: AnyHashable)
    func cancelAllTasks()
}

actor TaskProxy: Taskable {
    private var tasks: [AnyHashable: VoidTask] = [:]
    
    func task(for id: AnyHashable) -> VoidTask? {
        tasks[id]
    }
    
    func startTask(with id: AnyHashable, operation: VoidTask) {
        cancelTask(with: id)
        
        tasks[id] = operation
    }
    
    func cancelTask(with id: AnyHashable) {
        tasks[id]?.cancel()
        tasks.removeValue(forKey: id)
    }
    
    func cancelAllTasks() {
        tasks.values.forEach {
            $0.cancel()
        }
        
        tasks.removeAll()
    }
}
