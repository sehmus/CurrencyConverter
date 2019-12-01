//
//  CurrenciesViewModel.swift
//  CurrencyConverter
//
//  Copyright © 2019 Sehmus GOKCE. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

protocol CurrencyViewModelDelegate {
    /**
     The method which is called when conversion currency selected.
     
     - Parameters:
     - currency: The selected currency by the user.
     
     */
    func conversionCurrencySelected(currency : Currency)
    
    func resetUIState()
    
    
}

public class CurrenciesViewModel : BaseViewModel {
    /// Currencies to be converted.
    var currencies = BehaviorRelay<[Currency]>(value: [Currency]())
    /// Currencies for selecting first.
    //var symbols = [Currency]()
    var symbols = BehaviorRelay<[Currency]>(value: [Currency]())
    /// Delegate for ViewController
    var delegate: CurrencyViewModelDelegate?
    ///Selected base currency
    var baseCurrency  = PublishSubject<Currency?>()
    /// First selection mode or not.
    //var isSymbolMode : Bool = true
    
    
    var isSymbolMode = BehaviorRelay<Bool>(value: true)
    
    var disposeBag = DisposeBag()
    
    
    override init() {
        super.init()
        
        baseCurrency.subscribe(onNext: { currency in
            self.isSymbolMode.accept(false)
            }).disposed(by: disposeBag)
        
        baseCurrency.flatMap { currency -> Observable<Bool> in
            return (currency != nil) ? Observable.just(false) : Observable.just(true)
            }.bind(to: isSymbolMode).disposed(by: disposeBag)
        
    }
    
}

extension CurrenciesViewModel {
    
    
    /**
     Resets the values of the page to Initial state.
     
     */
    func resetValues() {
        self.currencies.accept([Currency]())
        self.symbols.accept([Currency]())
        self.baseCurrency.onNext(nil)
        self.isSymbolMode.accept(true)
    }
    /**
     Gets the symbols of the currencies.
     
     */
    func getSymbols() {

        self.isLoading.accept(true)
        guard let _delegate = delegate else {
            return
        }
        CurrencyService.getSymbols { (model, error) in
            self.isLoading.accept(false)
            guard model != nil else {
                //_delegate.requestErrorReturned(message: nil)
                self.errorMessage.onNext(nil)
                return
            }
            
            guard let resultSymbols = model?.symbols else {
                //return _delegate.requestErrorReturned(message: nil)
                return self.errorMessage.onNext(nil)
                
            }
            
            var newSymbols = [Currency]()
            for (name, description) in resultSymbols {
                let createdSymbol = Currency(name: name, description: description, value: nil)
                newSymbols.append(createdSymbol)
            }
            self.symbols.accept(newSymbols)
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
        self.isLoading.accept(true)
        guard let _delegate = delegate else {
            return
        }
        
        CurrencyService.getLatestCurrencies(baseCurrency: baseCurrency) { (model, error) in
            self.isLoading.accept(false)
            guard model != nil else {
                self.errorMessage.onNext(nil)
                return
            }
            guard let resultRates = model?.rates else {
                return self.errorMessage.onNext(nil)
                
            }
            var newCurrencies = [Currency]()
            for (name, rate) in resultRates {
                let createdSymbol = Currency(name: name, description: nil, value: rate)
                newCurrencies.append(createdSymbol)
            }
            self.currencies.accept(newCurrencies)
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
        if self.isSymbolMode.value {
            //self.baseCurrency = symbols.value[row]
            //_delegate.baseCurrencySelected(currency: symbols.value[row])
            self.isSymbolMode.accept(false)
        }
        else
        {
            _delegate.conversionCurrencySelected(currency: currencies.value[row])
        }
    }
}
