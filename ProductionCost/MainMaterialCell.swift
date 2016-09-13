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
        let selectionView = UIView()
        selectionView.backgroundColor = AppColors.raspberry25
        self.selectedBackgroundView = selectionView
        
        self.nameLabel.text  = material.name
        self.priceLabel.text = String(format: "%.2f $", material.price)
        
        if material.isSubMaterial {
            self.nameLabel.text        = material.name.stringByReplacingOccurrencesOfString("sub_", withString: "")
            self.informationLabel.text = "per unit"
        }
        
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
    
    func setAlternativeBackground(forEvenIndexPath indexPath: NSIndexPath) {
        if indexPath.row % 2 == 0 {
            self.backgroundColor = AppColors.white50
        }
    }

}
