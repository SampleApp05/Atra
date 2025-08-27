//
//  NumberFormatter+Helper.swift
//  Atra
//
//  Created by Daniel Velikov on 22.08.25.
//

import Foundation

extension NumberFormatter {
    static let currencyFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_US")
        formatter.maximumFractionDigits = 8
        
        return formatter
    }()
    
    static let priceChangeFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.positivePrefix = "+"
        formatter.negativePrefix = "-"
        formatter.maximumFractionDigits = 4
        
        return formatter
    }()
    
    static let percentageFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 4
        formatter.positiveSuffix = "%"
        formatter.negativeSuffix = "%"
        
        return formatter
    }()
}
