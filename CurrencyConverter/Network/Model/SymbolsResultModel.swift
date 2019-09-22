//
//  SymbolsResultModel.swift
//  CurrencyConverter
//
//  Copyright © 2019 Sehmus GOKCE. All rights reserved.
//

import Foundation

public struct SymbolsResultModel: Codable {
    let success: Bool
    let symbols: [String: String]
}
