//
//  Constants.swift
//  CurrencyConverter
//
//  Created by Sehmus Gokce on 20.09.2019.
//  Copyright © 2019 Sehmus GOKCE. All rights reserved.
//

import Foundation
import UIKit

public struct Constants {
    public struct Service {
        public static var baseUrl = "http://data.fixer.io/api"
        public static var latestCurrencies = "latest"
        public static var symbols = "symbols"
        public static var apiKey : String = "1774364f4b8dd657bfab2edfce774864"
        public static var imageBaseUrl = "http://image.tmdb.org/t/p/w500"
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
    
    public struct MovieCollectionView {
        public static let CellHeight : CGFloat = 150
        public static let CellMargin : CGFloat = 5
    }
    public struct MovieFooterViewCell {
        public static let CellHeight : CGFloat = 50
    }
}
