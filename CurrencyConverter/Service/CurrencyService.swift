//
//  CurrencyService.swift
//  CurrencyConverter
//
//  Created by Sehmus Gokce on 20.09.2019.
//  Copyright © 2019 Sehmus GOKCE. All rights reserved.
//

import Foundation
import Alamofire
import RxSwift

public class CurrencyService : NSObject {
    
    
    /**
     Gets Currencies related to Selected Currency.
     
     - Parameters:
     - baseCurrency: The base currency selected by user.
     - completionHandler: Callback for getting model or error.

     */
    public static func getLatestMockCurrencies(symbols : [Currency] ) -> Observable<[Currency]> {

        let observable = Observable<[Currency]>.create { obs  in
            var currencies = [Currency]()
            for i in 0...symbols.count-1 {
                currencies.append(Currency(name: symbols[i].name, description: symbols[i].description, value: Double.random(in: 0...100)))
            }
            
            obs.onNext(currencies)
            return Disposables.create()
        }
        
        return observable
    }
    
    /**
     Gets Currencies related to Selected Currency.
     
     - Parameters:
     - baseCurrency: The base currency selected by user.
     - completionHandler: Callback for getting model or error.

     */
    public static func getLatestCurrencies(baseCurrency : String, completionHandler: @escaping (LatestCurrencyResultModel?, String?) -> Void) {
        var parameters : [String:Any] = [:]
        parameters["access_key"] = Constants.Service.accessKey
        parameters["base"] = baseCurrency
        
        
        Alamofire.request(Constants.Service.baseUrl + Constants.Service.latestCurrencies,
                          method: .post,
                          parameters: parameters,
                          encoding: URLEncoding(destination: .queryString)).validate(statusCode: 200..<300).responseData { response in
                            switch response.result{
                            case .success:
                                let decoder = JSONDecoder()
                                let ratesData = try? decoder.decode(LatestCurrencyResultModel.self, from: response.result.value!)
                                completionHandler(ratesData, nil)
                                break
                            case .failure(let error):
                                completionHandler(nil, error.localizedDescription)
                                break
                            }
        }
    }
    
    /**
     Gets Symbols for selecting initially.
     
     - Parameters:
     - completionHandler: Callback for getting model or error.
     
     */
    public static func getSymbols(completionHandler: @escaping (SymbolsResultModel?, String?) -> Void) {
        var parameters : [String:Any] = [:]
        parameters["access_key"] = Constants.Service.accessKey
        Alamofire.request(Constants.Service.baseUrl + Constants.Service.symbols,
                          method: .post,
                          parameters: parameters,
                          encoding: URLEncoding(destination: .queryString)).validate(statusCode: 200..<300).responseData { response in
                            switch response.result{
                            case .success:
                                let decoder = JSONDecoder()
                                let symbolsData = try? decoder.decode(SymbolsResultModel.self, from: response.result.value!)
                                guard let symbols = symbolsData else{
                                    completionHandler(nil, nil)
                                    return
                                }
                                completionHandler(symbols, nil)
                                break
                            case .failure(let error):
                                completionHandler(nil, error.localizedDescription)
                                break
                            }
        }
    }
}
