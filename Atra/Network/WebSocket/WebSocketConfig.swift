//
//  WebSocketConfig.swift
//  Atra
//
//  Created by Daniel Velikov on 14.07.25.
//

import Foundation

struct WebSocketConfig: Decodable, Equatable{
    let urlPath: String
    let headers: [String: String]
    let protocols: [String]
    
    init(urlPath: String = "", headers: [String: String] = [:], protocols: [String] = []) {
        self.urlPath = urlPath
        self.headers = headers
        self.protocols = protocols
    }
}
