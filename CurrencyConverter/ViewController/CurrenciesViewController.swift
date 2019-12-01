//
//  ViewController.swift
//  CurrencyConverter
//
//  Copyright © 2019 Sehmus GOKCE. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class CurrenciesViewController: BaseViewController {
    @IBOutlet weak var lblInformation: UILabel!
    @IBOutlet weak var imgBaseCurrency: UIImageView!
    @IBOutlet weak var lblBaseCurrency: UILabel!
    @IBOutlet weak var viewBaseCurrency: UIView!
    @IBOutlet weak var tblCurrencies: UITableView!
    
    //Pull to refresh Currencies TableView.
    private let refreshControl = UIRefreshControl()
    
    
//    ViewModel of CurrenciesViewController
    lazy var currenciesVieWModel: CurrenciesViewModel = {
        let vm = CurrenciesViewModel()
        vm.delegate = self
        return vm
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "currencies.page.title".localized
        self.lblInformation.text = "currencies.page.lblinformation.base.text".localized
        self.viewModel = self.currenciesVieWModel
        
        self.tblCurrencies.rx.setDelegate(self).disposed(by: disposeBag)
        //self.tblCurrencies.delegate = nil
        
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
        
        
        self.observeSymbolRequest()
        self.observeCurrencyRequest()
        self.observeBaseCurrency()
        self.observeTableViewSelection()
        

    }
    
    func observeSymbolRequest() {

        self.currenciesVieWModel.symbols
            .bind(to: self.tblCurrencies.rx.items(cellIdentifier: CurrencyTableViewCell.className, cellType: CurrencyTableViewCell.self)) { (row, element, cell) in
                
                if self.currenciesVieWModel.isSymbolMode.value {
                    cell.bindCurrencyModel(currency: element)
                }
                else
                {
                    //cell.bindCurrencyModel(currency: currenciesVieWModel.currencies.value[indexPath.row])
                }
        }
        .disposed(by: self.disposeBag)
    }
    
    func observeTableViewSelection() {
        self.tblCurrencies.rx.modelSelected(Currency.self).asDriver(onErrorJustReturn: Currency(name: "", description: "", value: 0)).drive(self.currenciesVieWModel.baseCurrency).disposed(by: disposeBag)
    }
    
    func observeCurrencyRequest() {
        self.currenciesVieWModel.currencies.subscribe(onNext: { currencies in
            self.tblCurrencies.reloadData()
            }).disposed(by: disposeBag)
    }
    
    func observeBaseCurrency() {
        self.currenciesVieWModel.baseCurrency.subscribe(onNext: { currency in
            
            guard let currency = currency else {return}
            
            self.viewBaseCurrency.isHidden = false
            self.lblInformation.isHidden = true
            self.lblBaseCurrency.text = currency.name
            self.imgBaseCurrency.image = UIImage(named: currency.name.lowercased())
            self.deselectSelectedRow()
            self.currenciesVieWModel.getCurrencies(baseCurrency: currency.name)
 
            
            }).disposed(by: disposeBag)
    }
    
    override func hideAllIndicators() {
        super.hideAllIndicators()
        self.refreshControl.endRefreshing()
    }
    
    override func showAllIndicators() {
        super.showAllIndicators()
        self.refreshControl.beginRefreshing()
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
        if currenciesVieWModel.isSymbolMode.value {
            self.currenciesVieWModel.getSymbols()
        }
        else {
            //TODO: Fix this
            //guard let _baseCurrency = self.currenciesVieWModel.baseCurrency else {return}
            //self.currenciesVieWModel.getCurrencies(baseCurrency: _baseCurrency.name)
        }
    }
    
}


extension CurrenciesViewController : CurrencyViewModelDelegate {
    /**
     Resets UI State to Initial
     */
    func resetUIState() {
        //      Allow user to select new currencies for conversion
        self.currenciesVieWModel.resetValues()
        self.currenciesVieWModel.getSymbols()
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
        
        
        //TODO: Fix this
        //guard let _baseCurrency = self.currenciesVieWModel.baseCurrency else { return }
        //vc.ccViewModel.baseCurrency = _baseCurrency
        vc.ccViewModel.conversionCurrency = currency
        self.navigationController?.pushViewController(vc, animated: true)
        
        
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
        
        ViewUtil.displayErrorMessage(vc: self, message: msg)
    }
    
}

extension CurrenciesViewController : UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.CurrenciesTableView.CellHeight
    }

}
