//
//  ViewController.swift
//  CurrencyConverter
//
//  Created by Sehmus GOKCE on 19.09.2019.
//  Copyright © 2019 Sehmus GOKCE. All rights reserved.
//

import UIKit

class CurrenciesViewController: UIViewController {
    @IBOutlet weak var lblInformation: UILabel!
    @IBOutlet weak var imgBaseCurrency: UIImageView!
    @IBOutlet weak var lblBaseCurrency: UILabel!
    @IBOutlet weak var viewBaseCurrency: UIView!
    @IBOutlet weak var tblCurrencies: UITableView!
    
    
    lazy var viewModel: CurrenciesViewModel = {
        let vm = CurrenciesViewModel()
        vm.delegate = self
        return vm
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblCurrencies.register(UINib(nibName: CurrencyTableViewCell.className, bundle: Bundle(for: CurrencyTableViewCell.self)), forCellReuseIdentifier: CurrencyTableViewCell.className)
        self.viewModel.getSymbols()
        self.viewBaseCurrency.isHidden = true
        self.lblInformation.isHidden = false
    
    }
    
    
    func deselectSelectedRow(){
        guard let selectedItem = tblCurrencies.indexPathForSelectedRow else {return}
        tblCurrencies.deselectRow(at: selectedItem, animated: true)
    }
}

extension CurrenciesViewController : CurrencyViewModelDelegate {
    func conversionCurrencySelected(currency: Currency) {
        
    }
    
    func getLatestCurrenciesRequestCompleted() {
        tblCurrencies.reloadData()
    }
    
    func baseCurrencySelected(currency: Currency) {
        viewBaseCurrency.isHidden = false
        lblInformation.isHidden = true
        lblBaseCurrency.text = currency.name
        imgBaseCurrency.image = UIImage(named: currency.name.lowercased())
        self.deselectSelectedRow()
        self.viewModel.getCurrencies(baseCurrency: currency.name)
        
        
        
    }
    
    func requestErrorReturned(message: String?) {
        guard let msg = message else{
            ViewUtil.displayErrorMessage(vc: self)
            return
        }
    }
    func getSymbolRequestCompleted() {
        tblCurrencies.reloadData()
    }
}

extension CurrenciesViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if viewModel.isSymbolMode {
            return viewModel.symbols.count
        }
        else
        {
            return viewModel.currencies.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblCurrencies.dequeueReusableCell(withIdentifier: CurrencyTableViewCell.className) as! CurrencyTableViewCell
        
        if viewModel.isSymbolMode {
             cell.bindCurrencyModel(currency: viewModel.symbols[indexPath.row])
        }
        else
        {
             cell.bindCurrencyModel(currency: viewModel.currencies[indexPath.row])
        }
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.userPressedTheSymbol(row: indexPath.row)
    }
    
}
