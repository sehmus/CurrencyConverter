//
//  Currency.swift
//  CurrencyConverter
//
//  Created by Sehmus Gokce on 19.09.2019.
//  Copyright © 2019 Sehmus GOKCE. All rights reserved.
//

import UIKit

public struct Currency: Codable {
    let name : String
    let description : String
    let value : Double?
}
