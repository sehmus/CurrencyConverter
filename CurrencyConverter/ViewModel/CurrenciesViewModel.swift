//
//  CurrenciesViewModel.swift
//  CurrencyConverter
//
//  Created by Sehmus Gokce on 19.09.2019.
//  Copyright © 2019 Sehmus GOKCE. All rights reserved.
//

import Foundation

protocol CurrencyViewModelDelegate {
    func requestCompleted()
}

class CurrenciesViewModel {
    var currencies = [Currency]()
    var delegate: CurrencyViewModelDelegate?
}
