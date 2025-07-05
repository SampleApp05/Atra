//
//  Data+Helper.swift
//  Atra
//
//  Created by Daniel Velikov on 4.07.25.
//

import Foundation

extension Data {
    func asJsonString() -> String? {
        do {
            let object = try JSONSerialization.jsonObject(with: self)
            let prettyData = try JSONSerialization.data(
                withJSONObject: object,
                options: [.prettyPrinted, .sortedKeys]
            )
            return String(data: prettyData, encoding: .utf8)
        } catch {
            return nil
        }
    }
}
