//
//  CurrencyConversionViewController.swift
//  CurrencyConverter
//
//  Copyright © 2019 Sehmus GOKCE. All rights reserved.
//

import UIKit

class CurrencyConversionViewController: BaseViewController {

    
    @IBOutlet weak var lblBaseCurrency: UILabel!
    @IBOutlet weak var lblConversionCurrency: UILabel!
    @IBOutlet weak var tfBaseCurrency: CurrencyTextField!
    @IBOutlet weak var lblConversionCurrencyAmount: UILabel!
    
    
    lazy var viewModel: CurrencyConversionViewModel = {
        let vm = CurrencyConversionViewModel()
        return vm
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "currencyconversion.page.title".localized
        
        self.tfBaseCurrency.delegate = self
        
        guard let _baseCurrency = self.viewModel.baseCurrency else {return}
        guard let _conversionCurrency = self.viewModel.conversionCurrency else {return}
        
        self.tfBaseCurrency.setAmount(amount: Decimal(_baseCurrency.value!))
        self.lblBaseCurrency.text = _baseCurrency.name
        self.lblConversionCurrency.text = _conversionCurrency.name
        
        tfBaseCurrency.textfield.becomeFirstResponder()

    }

}

extension CurrencyConversionViewController : CurrencyTextFieldDelegate {
    func currencyTextFieldTextChanged(value: Double, currencyField: CurrencyTextField) {
        let calculatedAmount = self.viewModel.calculateConversionCurrencyRate(baseCurrencyAmount: value)
        lblConversionCurrencyAmount.text = String.init(format: "%.2lf", calculatedAmount)
    }
    
    
}

