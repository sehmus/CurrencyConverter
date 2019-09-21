//
//  CurrenciesViewModel.swift
//  CurrencyConverter
//
//  Created by Sehmus Gokce on 19.09.2019.
//  Copyright © 2019 Sehmus GOKCE. All rights reserved.
//

import Foundation

protocol CurrencyViewModelDelegate {
    func getSymbolRequestCompleted()
    func getLatestCurrenciesRequestCompleted()
    func requestErrorReturned(message : String?)
    func baseCurrencySelected(currency : Currency)
    func conversionCurrencySelected(currency : Currency)
    
}

public class CurrenciesViewModel {
    var currencies = [Currency]()
    var symbols = [Currency]()
    var delegate: CurrencyViewModelDelegate?
    var baseCurrency : Currency?
    var isSymbolMode : Bool = true
}

extension CurrenciesViewModel {
    func getSymbols() {

        guard let _delegate = delegate else {
            return
        }
        CurrencyService.getSymbols { (model, error) in
            ViewUtil.hideLoadingView()
            guard model != nil else {
                _delegate.requestErrorReturned(message: nil)
                return
            }
            
            guard let resultSymbols = model?.symbols else {
                return _delegate.requestErrorReturned(message: nil)
                
            }
            
            self.symbols.removeAll()
            for (name, description) in resultSymbols {
                let createdSymbol = Currency(name: name, description: description, value: nil)
                self.symbols.append(createdSymbol)
            }
            _delegate.getSymbolRequestCompleted()
        }

    }
    
    func getCurrencies(baseCurrency : String) {
        
        guard let _delegate = delegate else {
            return
        }
        
        CurrencyService.getLatestCurrencies(baseCurrency: baseCurrency) { (model, error) in
            ViewUtil.hideLoadingView()
            guard model != nil else {
                _delegate.requestErrorReturned(message: nil)
                return
            }
            guard let resultRates = model?.rates else {
                return _delegate.requestErrorReturned(message: nil)
                
            }
            self.currencies.removeAll()
            for (name, rate) in resultRates {
                let createdSymbol = Currency(name: name, description: nil, value: rate)
                self.currencies.append(createdSymbol)
            }
            _delegate.getLatestCurrenciesRequestCompleted()
        }
        
    }
    
    
    func userPressedTheSymbol(row : Int) {
        guard let _delegate = delegate else {
            return
        }
        if self.isSymbolMode {
            self.baseCurrency = symbols[row]
            _delegate.baseCurrencySelected(currency: symbols[row])
            self.isSymbolMode = false
        }
        else
        {
            _delegate.conversionCurrencySelected(currency: symbols[row])
        }
        
        
    }
}
