//
//  CoinValueFormatterTests.swift
//  Atra
//
//  Created by Daniel Velikov on 22.08.25.
//

import Testing
import Foundation

@testable import Atra

struct CoinValueFormatterTests {
    let sut: ValueFormatter
    
    var placeholder: String { sut.placeholder }
    
    init() {
        self.sut = CoinValueFormatter()
    }
    
    @Test
    func testFormatPrice() {
        let value = 100_000.12345
        let expectedValue = "$100,000.12345"
        
        #expect(sut.formatPrice(value) == expectedValue)
    }
    
    @Test
    func testFormatPriceInvalidValue() {
        let value = Double.infinity
        
        #expect(sut.formatPrice(value) == placeholder)
    }
    
    @Test
    func testFormatPriceFractionDigitLimit() {
        let value = 100.123456780001
        let expectedValue = "$100.12345678"
        
        #expect(sut.formatPrice(value) == expectedValue)
    }
    
    @Test
    func testFormatPositivePriceChangeValue() {
        let value = 12.5
        let expectedValue = "+12,5"
        
        #expect(sut.formatPriceChange(value) == expectedValue)
    }
    
    @Test
    func testFormatPositivePriceChangeValueFractionDigitLimit() {
        let value = 12.1234111
        let expectedValue = "+12,1234"
        
        #expect(sut.formatPriceChange(value) == expectedValue)
    }
    
    @Test
    func testFormatNegativePriceChangeValue() {
        let value: Double = -12.5
        let expectedValue = "-12,5"
        
        #expect(sut.formatPriceChange(value) == expectedValue)
    }
    
    @Test
    func testFormatPriceChangeInvalidValue() {
        let value = -Double.infinity
        
        #expect(sut.formatPriceChange(value) == placeholder)
    }
    
    @Test
    func testFormatNegativePriceChangeValueFractionDigitLimit() {
        let value: Double = -12.1234111
        let expectedValue = "-12,1234"
        
        #expect(sut.formatPriceChange(value) == expectedValue)
    }
    
    @Test
    func testFormatPositivePriceChangePercentage() {
        let value = 12.5
        let expectedValue = "12,5%"
        
        #expect(sut.formatPercentage(value) == expectedValue)
    }
    
    @Test
    func testFormatPositivePriceChangePercentageFractionDigitLimit() {
        let value = 12.1234111
        let expectedValue = "12,1234%"
        
        #expect(sut.formatPercentage(value) == expectedValue)
    }
    
    @Test
    func testFormatNegativePriceChangePercentage() {
        let value: Double = -12.5
        let expectedValue = "-12,5%"
        
        #expect(sut.formatPercentage(value) == expectedValue)
    }
    
    @Test
    func testFormatNegativePriceChangePercentageFractionDigitLimit() {
        let value: Double = -12.1234111
        let expectedValue = "-12,1234%"
        
        #expect(sut.formatPercentage(value) == expectedValue)
    }
    
    @Test
    func testFormatPriceChangePercentageInvalidValue() {
        let value = Double.infinity
        #expect(sut.formatPercentage(value) == placeholder)
    }
}
