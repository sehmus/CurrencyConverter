//
//  Constants.swift
//  CurrencyConverter
//
//  Copyright © 2019 Sehmus GOKCE. All rights reserved.
//

import Foundation
import UIKit

public struct Constants {
    public struct Service {
        public static var baseUrl = "http://data.fixer.io/api"
        public static var latestCurrencies = "/latest"
        public static var symbols = "/symbols"
        public static var accessKey : String = "1774364f4b8dd657bfab2edfce774864"
        
        public static var flagBaseUrl : String = "https://restcountries.eu/rest/v2/alpha/"
    }
    
    public struct Color {
        public static let NavBarDefaultColor    = UIColor(rgb: 0xFE5067)
        public static let NavBarDefaultTextColor = UIColor(rgb: 0xFFFFFF)
        public static let NavBarDefaultButtonColor = UIColor(rgb: 0xFFFFFF)
        
        
        static let IndicatorViewBackground = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
        
    }
    
    public struct Font {
        public static let NavBarDefaultFont    = UIFont.systemFont(ofSize: 20, weight: .medium)
        
    }
    
    public struct CurrenciesTableView {
        public static let CellHeight : CGFloat = 80
    }
    
    public struct CurrencyConversion {
        public static let BaseCurrencyInitialValue : Double = 0.0
    }
}
