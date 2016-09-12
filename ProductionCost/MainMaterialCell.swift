//
//  MainMaterialCell.swift
//  ProductionCost
//
//  Created by BT-Training on 12/09/16.
//  Copyright © 2016 BT-Training. All rights reserved.
//

import UIKit

class MainMaterialCell: UITableViewCell {
    
    // MARK: Outlets

    @IBOutlet weak var nameLabel:        UILabel!
    @IBOutlet weak var informationLabel: UILabel!
    @IBOutlet weak var priceLabel:       UILabel!
    
    // MARK: Overrides
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: Methods
    
    func prepare(withMaterial material: Material) {
        self.nameLabel.text = material.name
        self.priceLabel.text = "\(material.price) $"
        
        if !material.isPack {
            return
        }
        
        var splitResult = "\(material.quantity)".characters.split(".")
        
        if splitResult[1].count == 1 && splitResult[1].contains("0") {
            self.informationLabel.text = "by \(Int(material.quantity))"
        }
        else {
            self.informationLabel.text = "by \(material.quantity)"
        }
    }

}
