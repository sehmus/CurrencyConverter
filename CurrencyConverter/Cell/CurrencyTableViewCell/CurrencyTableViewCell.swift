//
//  CurrencyTableViewCell.swift
//  CurrencyConverter
//
//  Created by Sehmus GOKCE on 20.09.2019.
//  Copyright © 2019 Sehmus GOKCE. All rights reserved.
//

import UIKit

class CurrencyTableViewCell: UITableViewCell {
    @IBOutlet weak var imgCurrency: UIImageView!
    @IBOutlet weak var lblCurrency: UILabel!
    @IBOutlet weak var lblAmount: UILabel!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    public func bindCurrencyModel(currency : Currency) {
        lblCurrency.text = currency.name
        imgCurrency.image = UIImage(named: currency.name.lowercased())
        
        guard let amount = currency.value else{
            lblAmount.isHidden = true
            return
        }
        lblAmount.text = "\(amount)"
        lblAmount.isHidden = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
}
