//
//  BaseViewController.swift
//  CurrencyConverter
//
//  Copyright © 2019 Sehmus GOKCE. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class BaseViewController: UIViewController {
    
    
    var disposeBag = DisposeBag()
    
    var viewModel : BaseViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.checkLoading()
        self.checkError()
        
    }
    
    func checkLoading() {
        guard let viewModel = self.viewModel else { return }
        
        viewModel.isLoading.subscribe(onNext: { value in
            if value {
                self.showAllIndicators()
            }
            else
            {
                self.hideAllIndicators()
            }
            }).disposed(by: disposeBag)
    }
    
    func checkError() {
        self.viewModel?.errorMessage.observeOn(MainScheduler.instance).subscribe(onNext: { message in
            guard let msg = message else{
                ViewUtil.displayErrorMessage(vc: self)
                return
            }
            
            ViewUtil.displayErrorMessage(vc: self, message: msg)
            }).disposed(by: disposeBag)
    }
    
    func hideAllIndicators() {
        ViewUtil.hideLoadingView()
    }
    
    func showAllIndicators() {
        ViewUtil.showLoadingView()
    }
    
}
