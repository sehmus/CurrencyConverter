//
//  SymbolsResultModel.swift
//  CurrencyConverter
//
//  Created by Sehmus Gokce on 20.09.2019.
//  Copyright © 2019 Sehmus GOKCE. All rights reserved.
//

import Foundation

struct SymbolsResultModel: Codable {
    let success: Bool
    let symbols: [String: String]
}
