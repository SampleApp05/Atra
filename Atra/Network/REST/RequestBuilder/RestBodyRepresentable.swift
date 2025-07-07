//
//  RestBodyRepresentable.swift
//  Atra
//
//  Created by Daniel Velikov on 24.06.25.
//

import Foundation

protocol RestBodyRepresentable: Encodable {
    func asRequestBody() throws -> Data
}

extension RestBodyRepresentable {
    func asRequestBody() throws -> Data {
        return try JSONEncoder().encode(self)
    }
}
