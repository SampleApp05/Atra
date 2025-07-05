//
//  Loggable.swift
//  Atra
//
//  Created by Daniel Velikov on 4.07.25.
//

import Foundation

protocol Loggable {
    func log(variant: LogEventVariant, message: String)
    func log<T: Encodable>(variant: LogEventVariant, message: String, data: T)
}

extension Loggable {
    private var source: String { String(describing: type(of: self)) }
    
    func log(variant: LogEventVariant, message: String) {
        let timestamp = Date()
        
        Task {
            await LoggerContext.current?.log(
                timestamp: timestamp,
                source: source,
                variant: variant,
                message: message
            )
        }
    }
    
    func log<T: Encodable>(variant: LogEventVariant, message: String, data: T) {
        let timestamp = Date()
        
        Task {
            await LoggerContext.current?.log(
                timestamp: timestamp,
                source: source,
                variant: variant,
                message: message,
                data: data
            )
        }
    }
}
