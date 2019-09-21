//
//  CurrencyConversionViewModel.swift
//  CurrencyConverter
//
//  Created by Sehmus GOKCE on 21.09.2019.
//  Copyright © 2019 Sehmus GOKCE. All rights reserved.
//

import Foundation
protocol CurrencyConversionDelegate {

    
}

public class CurrencyConversionViewModel {
    var currencies = [Currency]()
    var symbols = [Currency]()
    var delegate: CurrencyViewModelDelegate?
    var baseCurrency : Currency?
    var isSymbolMode : Bool = true
}
