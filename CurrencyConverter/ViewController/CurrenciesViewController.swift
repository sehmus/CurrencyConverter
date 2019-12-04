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
    private var compositeDisposable = CompositeDisposable()
    
    var currencyRequestObservable : Observable<[Currency]>?
    var lastTableBindDisposable : Disposable?
    
    
//    ViewModel of CurrenciesViewController
    lazy var currenciesVieWModel: CurrenciesViewModel = {
        let vm = CurrenciesViewModel()
        vm.delegate = self
        return vm
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.currenciesVieWModel.informationText.asObservable().bind(to: lblInformation.rx.text).disposed(by: disposeBag)
        self.viewModel = self.currenciesVieWModel
        
        self.tblCurrencies.rx.setDelegate(self).disposed(by: disposeBag)
        
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
        self.observeConversionCurrency()
        self.observeTableViewSelection()
        

    }
    
    func bindTableView(observable: Observable<[Currency]>)
    {
        if let lastTableBindDisposable = self.lastTableBindDisposable
        {
            lastTableBindDisposable.dispose()
        }
        lastTableBindDisposable = observable.bind(to: self.tblCurrencies.rx.items(cellIdentifier: CurrencyTableViewCell.className, cellType: CurrencyTableViewCell.self)) { (row, element, cell) in
                cell.bindCurrencyModel(currency: element)
        }
    }
    
    
    func observeSymbolRequest() {

        self.currenciesVieWModel.symbols.observeOn(MainScheduler.instance).subscribe(onNext: { _ in
            self.bindTableView(observable: self.currenciesVieWModel.symbols.asObservable())
            }).disposed(by: disposeBag)
    }
    
    func observeCurrencyRequest() {
        self.currenciesVieWModel.currencies.observeOn(MainScheduler.instance).subscribe(onNext: { _ in
            self.bindTableView(observable: self.currenciesVieWModel.currencies.asObservable())
            }).disposed(by: disposeBag)
    }
    
    func observeTableViewSelection() {
        let symbolObservable =  self.tblCurrencies.rx.modelSelected(Currency.self).filter { _ -> Bool in
            self.currenciesVieWModel.isSymbolMode.value == true
        }
        
        let currencyObservable =  self.tblCurrencies.rx.modelSelected(Currency.self).filter { _ -> Bool in
            self.currenciesVieWModel.isSymbolMode.value == false
        }

        symbolObservable.asDriver(onErrorJustReturn: Currency(name: "", description: "", value: 0)).drive(self.currenciesVieWModel.baseCurrency).disposed(by: disposeBag)
        currencyObservable.asDriver(onErrorJustReturn: Currency(name: "", description: "", value: 0)).drive(self.currenciesVieWModel.conversionCurrency).disposed(by: disposeBag)
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
    
    
    func observeConversionCurrency() {
        self.currenciesVieWModel.conversionCurrency.observeOn(MainScheduler.instance).subscribe(onNext: { currency in
               
            let vc = self.storyboard?.instantiateViewController(withIdentifier: CurrencyConversionViewController.className) as! CurrencyConversionViewController
            vc.ccViewModel.baseCurrency = currency
            vc.ccViewModel.conversionCurrency = currency
            self.navigationController?.pushViewController(vc, animated: true)
               
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
    
}


extension CurrenciesViewController : CurrencyViewModelDelegate {

    
    /**
     This method is called when conversion currency selected by user.
     
     - Parameters:
     - currency: The selected currency by the user.
     
     */
    func conversionCurrencySelected(currency: Currency) {
        
        
        
    }
    
}

extension CurrenciesViewController : UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.CurrenciesTableView.CellHeight
    }

}
