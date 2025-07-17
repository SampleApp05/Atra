//
//  SubscribeMessage.swift
//  Atra
//
//  Created by Daniel Velikov on 14.07.25.
//

import Foundation

struct SubscribeMessage: Codable {
    let action: String
    
    init(action: String = "subscribe") {
        self.action = action
    }
}
