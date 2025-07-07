//
//  HTTPMethod.swift
//  Atra
//
//  Created by Daniel Velikov on 24.06.25.
//

import Foundation

enum HTTPMethod {
    case get(params: [String: String] = [:])
    case post(body: RestBodyRepresentable? = nil)
    case put(body: RestBodyRepresentable? = nil)
    case patch(body: RestBodyRepresentable? = nil)
    case delete(body: RestBodyRepresentable? = nil)
    
    var name: String {
        switch self {
        case .get:
            return "GET"
        case .post:
            return "POST"
        case .put:
            return "PUT"
        case .patch:
            return "PATCH"
        case .delete:
            return "DELETE"
        }
    }
}
