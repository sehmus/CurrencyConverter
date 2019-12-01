//
//  BaseViewModel.swift
//  CurrencyConverter
//
//  Created by Sehmus Gokce on 30.11.2019.
//  Copyright © 2019 Sehmus GOKCE. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

public class BaseViewModel {
    var title : BehaviorRelay<String>?
    var isLoading = BehaviorRelay<Bool>(value: false)
    var errorMessage = PublishSubject<String?>()
}
