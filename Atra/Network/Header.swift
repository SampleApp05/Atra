//
//  Header.swift
//  Atra
//
//  Created by Daniel Velikov on 7.07.25.
//

import Foundation

struct Header {
    enum Variant: String {
        case authorization = "Authorization"
    }
    
    let key: String
    let value: String
    
    init(key: String, value: String) {
        self.key = key
        self.value = value
    }
    
    init(variant: Variant, value: String) {
        self.key = variant.rawValue
        self.value = value
    }
}
