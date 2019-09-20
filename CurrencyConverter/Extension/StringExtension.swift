//
//  StringExtension.swift
//  CurrencyConverter
//
//  Created by Sehmus GOKCE on 20.09.2019.
//  Copyright © 2019 Sehmus GOKCE. All rights reserved.
//

import Foundation

public extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: nil, bundle: Bundle.main, value: "", comment: "")
    }
    
    static func className(_ aClass: AnyClass) -> String {
        return NSStringFromClass(aClass).components(separatedBy: ".").last!
    }
    
}
