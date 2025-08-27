//
//  ValueFormatter.swift
//  Atra
//
//  Created by Daniel Velikov on 22.08.25.
//

import Foundation

protocol ValueFormatter {
    var placeholder: String { get }
    
    func formatPrice(_ value: Double) -> String
    func formatPriceChange(_ value: Double?) -> String
    func formatPercentage(_ value: Double?) -> String
}
