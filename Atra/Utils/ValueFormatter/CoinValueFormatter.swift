//
//  CoinValueFormatter.swift
//  Atra
//
//  Created by Daniel Velikov on 22.08.25.
//

import Foundation

struct CoinValueFormatter: ValueFormatter {
    let placeholder: String = "???"
    
    private let priceFormatter: NumberFormatter = .currencyFormatter
    private let priceChangeFormatter: NumberFormatter = .priceChangeFormatter
    private let percentageFormatter: NumberFormatter = .percentageFormatter
    
    func formatPrice(_ value: Double) -> String {
        guard value.isFinite else { return placeholder }
        return priceFormatter.string(from: NSNumber(value: value)) ?? placeholder
    }
    
    func formatPriceChange(_ value: Double?) -> String {
        guard let value = value, value.isFinite else { return placeholder }
        return priceChangeFormatter.string(from: NSNumber(value: value)) ?? placeholder
    }
    
    func formatPercentage(_ value: Double?) -> String {
        guard let value = value, value.isFinite else { return placeholder }
        return percentageFormatter.string(from: NSNumber(value: value)) ?? placeholder
    }
}
