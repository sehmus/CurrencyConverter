//
//  CurrencyConversionViewModel.swift
//  CurrencyConverter
//
//  Created by Sehmus GOKCE on 21.09.2019.
//  Copyright © 2019 Sehmus GOKCE. All rights reserved.
//

import Foundation

public class CurrencyConversionViewModel {
    var baseCurrency : Currency? {
        didSet {
            self.baseCurrency?.value = 0.0
        }
    }
    var conversionCurrency : Currency?
}

extension CurrencyConversionViewModel {
    
    /**
     Calculates the currency to be converted
     
     - Parameters:
     - baseCurrencyAmount: amount of the base currency
     
     - Returns: calculated currency amount of to be converted.
     */
    func calculateConversionCurrencyRate(baseCurrencyAmount : Double) -> Double{
        
        guard let _conversionCurrency = self.conversionCurrency else {
            return 0.0
        }
        let amount : Double  = baseCurrencyAmount * _conversionCurrency.value!
        return amount

    }
}




