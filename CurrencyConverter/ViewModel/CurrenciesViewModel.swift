//
//  CurrenciesViewModel.swift
//  CurrencyConverter
//
//  Copyright © 2019 Sehmus GOKCE. All rights reserved.
//

import Foundation

protocol CurrencyViewModelDelegate {
    /**
     Symbol request completed delegate method.
     */
    func getSymbolRequestCompleted()
    /**
     Latest currencies completed delegate method.
     */
    func getLatestCurrenciesRequestCompleted()
    /**
     This method is called when any request has an error.
     
     - Parameters:
     - message: The message for showing to user.

     */
    func requestErrorReturned(message : String?)
    /**
     The method which is called when base currency selected.
     
     - Parameters:
     - currency: The selected currency by the user.
     
     */
    func baseCurrencySelected(currency : Currency)
    /**
     The method which is called when conversion currency selected.
     
     - Parameters:
     - currency: The selected currency by the user.
     
     */
    func conversionCurrencySelected(currency : Currency)
    
    func resetUIState()
    /**
     Hides every indicator on the screen.
     */
    func hideIndicators()
    
    
}

public class CurrenciesViewModel {
    /// Currencies to be converted.
    var currencies = [Currency]()
    /// Currencies for selecting first.
    var symbols = [Currency]()
    /// Delegate for ViewController
    var delegate: CurrencyViewModelDelegate?
    ///Selected base currency
    var baseCurrency : Currency?
    /// First selection mode or not.
    var isSymbolMode : Bool = true
}

extension CurrenciesViewModel {
    
    /**
     Resets the values of the page to Initial state.
     
     */
    func resetValues() {
        self.currencies = [Currency]()
        self.symbols = [Currency]()
        self.baseCurrency = nil
        self.isSymbolMode = true
    }
    /**
     Gets the symbols of the currencies.
     
     */
    func getSymbols() {

        ViewUtil.showLoadingView()
        guard let _delegate = delegate else {
            return
        }
        CurrencyService.getSymbols { (model, error) in
            _delegate.hideIndicators()
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
    /**
     Gets currencies related to first selected currency for conversion.
     
     - Parameters:
     - baseCurrency: The first selected currency from the user.
     
     - Returns: A beautiful, brand-new bicycle,
     custom-built just for you.
     */
    func getCurrencies(baseCurrency : String) {
        ViewUtil.showLoadingView()
        guard let _delegate = delegate else {
            return
        }
        
        CurrencyService.getLatestCurrencies(baseCurrency: baseCurrency) { (model, error) in
            _delegate.hideIndicators()
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
    
    /**
     The method that handles selection of the currencies by the user.
     
     - Parameters:
     - row: selected row  number by the user.
     
     */
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
            _delegate.conversionCurrencySelected(currency: currencies[row])
        }
    }
}
