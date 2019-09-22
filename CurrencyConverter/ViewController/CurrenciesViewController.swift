//
//  ViewController.swift
//  CurrencyConverter
//
//  Created by Sehmus GOKCE on 19.09.2019.
//  Copyright © 2019 Sehmus GOKCE. All rights reserved.
//

import UIKit

class CurrenciesViewController: BaseViewController {
    @IBOutlet weak var lblInformation: UILabel!
    @IBOutlet weak var imgBaseCurrency: UIImageView!
    @IBOutlet weak var lblBaseCurrency: UILabel!
    @IBOutlet weak var viewBaseCurrency: UIView!
    @IBOutlet weak var tblCurrencies: UITableView!
    
    //Pull to refresh Currencies TableView.
    private let refreshControl = UIRefreshControl()
    
    
//    ViewModel of CurrenciesViewController
    lazy var viewModel: CurrenciesViewModel = {
        let vm = CurrenciesViewModel()
        vm.delegate = self
        return vm
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "currencies.page.title".localized
        self.lblInformation.text = "currencies.page.lblinformation.base.text".localized
        
//      Register Custom Table View Cell
        tblCurrencies.register(UINib(nibName: CurrencyTableViewCell.className, bundle: Bundle(for: CurrencyTableViewCell.self)), forCellReuseIdentifier: CurrencyTableViewCell.className)
        
        //Defining refresh control of the tableview.
        tblCurrencies.refreshControl = refreshControl
        
        // Configure Refresh Control
        refreshControl.addTarget(self, action: #selector(refreshCurrencies(_:)), for: .valueChanged)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.resetUIState()

    }
    
    /**
     Deselects selected row of the tableview.
     */
    func deselectSelectedRow(){
        guard let selectedItem = tblCurrencies.indexPathForSelectedRow else {return}
        tblCurrencies.deselectRow(at: selectedItem, animated: true)
    }
    
    /**
     Reload currencies.
     */
    @objc private func refreshCurrencies(_ sender: Any) {
        if viewModel.isSymbolMode {
            self.viewModel.getSymbols()
        }
        else {
            guard let _baseCurrency = self.viewModel.baseCurrency else {return}
            self.viewModel.getCurrencies(baseCurrency: _baseCurrency.name)
        }
    }
    
}


extension CurrenciesViewController : CurrencyViewModelDelegate {
    /**
     Hides indicators on the view which is visible.
     */
    func hideIndicators() {
        self.refreshControl.endRefreshing()
        ViewUtil.hideLoadingView()
    }
    
    
    /**
     Resets UI State to Initial
     */
    func resetUIState() {
        //      Allow user to select new currencies for conversion
        self.viewModel.resetValues()
        self.viewModel.getSymbols()
        self.viewBaseCurrency.isHidden = true
        self.lblInformation.isHidden = false
        self.tblCurrencies.reloadData()
    }
    
    /**
     This method is called when conversion currency selected by user.
     
     - Parameters:
     - currency: The selected currency by the user.
     
     */
    func conversionCurrencySelected(currency: Currency) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: CurrencyConversionViewController.className) as! CurrencyConversionViewController
        
        guard let _baseCurrency = self.viewModel.baseCurrency else { return }
        vc.viewModel.baseCurrency = _baseCurrency
        vc.viewModel.conversionCurrency = currency
        self.navigationController?.pushViewController(vc, animated: true)
        
        
    }
    
    /**
     Called when currencies called successfully.
     */
    func getLatestCurrenciesRequestCompleted() {
        tblCurrencies.reloadData()
    }
    
    /**
     Called when base currency selected by the user.
     
     - Parameters:
     - currency: Selected base currency by user.
     */
    func baseCurrencySelected(currency: Currency) {
        viewBaseCurrency.isHidden = false
        lblInformation.isHidden = true
        lblBaseCurrency.text = currency.name
        imgBaseCurrency.image = UIImage(named: currency.name.lowercased())
        self.deselectSelectedRow()
        self.viewModel.getCurrencies(baseCurrency: currency.name)
        
    }
    
    /**
     Appropriate method for showing error message when request finished with error.
     
     - Parameters:
     - message: String for showing user.
     
     */
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
