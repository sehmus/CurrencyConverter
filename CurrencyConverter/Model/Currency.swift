//
//  Currency.swift
//  CurrencyConverter
//
//  Copyright © 2019 Sehmus GOKCE. All rights reserved.
//

import UIKit

public struct Currency: Codable {
    let name : String
    let description : String?
    var value : Double?
}
