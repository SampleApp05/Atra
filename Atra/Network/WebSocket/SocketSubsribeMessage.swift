//
//  SocketSubsribeMessage.swift
//  Atra
//
//  Created by Daniel Velikov on 14.07.25.
//

import Foundation

protocol SocketSubsribeMessage: Codable {
    var action: String { get }
}

struct SubscribeMessage: SocketSubsribeMessage {
    let action: String
    
    init(action: String = "subscribe") {
        self.action = action
    }
}
