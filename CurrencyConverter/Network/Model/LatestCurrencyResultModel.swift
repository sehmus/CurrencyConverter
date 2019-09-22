//
//  LatestCurrencyResultModel.swift
//  CurrencyConverter
//
//  Copyright © 2019 Sehmus GOKCE. All rights reserved.
//

import Foundation

public struct LatestCurrencyResultModel: Codable {
    let success: Bool
    let timestamp: Int
    let base, date: String
    let rates: [String: Double]
}
