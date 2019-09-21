//
//  CurrencyService.swift
//  CurrencyConverter
//
//  Created by Sehmus Gokce on 20.09.2019.
//  Copyright © 2019 Sehmus GOKCE. All rights reserved.
//

import Foundation
import Alamofire

public class CurrencyService : NSObject {
    public static func getLatestCurrencies(baseCurrency : String, completionHandler: @escaping (LatestCurrencyResultModel?, String?) -> Void) {
        //Prepare Parameters for Service Call
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
    
    
    public static func getSymbols(completionHandler: @escaping (SymbolsResultModel?, String?) -> Void) {
        //Prepare Parameters for Service Call
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
