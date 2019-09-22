//
//  CurrencyConverterTests.swift
//  CurrencyConverterTests
//
//  Created by Sehmus GOKCE on 19.09.2019.
//  Copyright © 2019 Sehmus GOKCE. All rights reserved.
//

import XCTest
@testable import CurrencyConverter

class CurrencyConverterTests: XCTestCase {

    override func setUp() {
    }

    override func tearDown() {

    }

    func testGetSymbolsAsync() {
        let promise = XCTestExpectation(description: "Success Status")
        CurrencyService.getSymbols { (model, error) in
            guard error == nil else {
                XCTFail("Error: \(error ?? "Error!")")
                return
            }
            guard model != nil else {
                XCTFail("Error: model is nil")
                return
            }
            if model!.success {
                promise.fulfill()
            }
        }
        
        wait(for: [promise], timeout: 10.0)
    }
    
    func testGetCurrenciesAsync() {
        let promise = XCTestExpectation(description: "Success Status")
        CurrencyService.getLatestCurrencies(baseCurrency: "TRY") { (model, error) in
            guard error == nil else {
                XCTFail("Error: \(error ?? "Error!")")
                return
            }
            guard model != nil else {
                XCTFail("Error: model is nil")
                return
            }
            if model!.success {
                promise.fulfill()
            }
        }
        
        wait(for: [promise], timeout: 10.0)
    }
    
    func testCalculateCurrency() {
        let currencyConversionVM = CurrencyConversionViewModel()
        currencyConversionVM.conversionCurrency = Currency(name: "USD", description: ".", value: 5.0)
        let calculatedAmount = currencyConversionVM.calculateConversionCurrencyRate(baseCurrencyAmount: 10)
        XCTAssertGreaterThan(calculatedAmount, 0)
        XCTAssertEqual(calculatedAmount, 50.0)
        
        
    }
    func testInitialBaseCurrencyInConversion() {
        let currencyConversionVM = CurrencyConversionViewModel()
        currencyConversionVM.baseCurrency = Currency(name: "TST", description: ".", value: nil)
        guard let initialValue = currencyConversionVM.baseCurrency?.value else {
            return XCTFail("initial currency value is nil !")
        }
        XCTAssertEqual(0, initialValue)
        
        
    }
    
    func testResetCurrenciesValues() {
        let currenciesVM = CurrenciesViewModel()
        currenciesVM.baseCurrency = Currency(name: "TST", description: ".", value: nil)
        currenciesVM.isSymbolMode = false
        currenciesVM.symbols.append(Currency(name: "TST", description: ".", value: 1.0))
        currenciesVM.currencies.append(Currency(name: "TST2", description: ".", value: 1.2))
        currenciesVM.resetValues()
        
        XCTAssertEqual(0, currenciesVM.currencies.count)
        XCTAssertEqual(0, currenciesVM.symbols.count)
        XCTAssertTrue(currenciesVM.isSymbolMode)
        XCTAssertNil(currenciesVM.baseCurrency)
        
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
