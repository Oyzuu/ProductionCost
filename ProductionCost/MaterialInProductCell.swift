//
//  MaterialInProductCell.swift
//  ProductionCost
//
//  Created by BT-Training on 16/09/16.
//  Copyright © 2016 BT-Training. All rights reserved.
//

import UIKit

class MaterialInProductCell: UITableViewCell {
    
    // MARK: Outlets
    
    @IBOutlet weak var nameLabel:     UILabel!
    @IBOutlet weak var priceLabel:    UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var typeLabel:     UILabel!
    
    // MARK: Overrides

    override func awakeFromNib() {
        super.awakeFromNib()
        
        let selectionView             = UIView(frame: CGRect.zero)
        selectionView.backgroundColor = AppColors.raspberry25
        self.selectedBackgroundView   = selectionView
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func prepare(material: Material, modifier: Double, indexPath: NSIndexPath) -> MaterialInProductCell {
        let text = material.name.stringByReplacingOccurrencesOfString("_", withString: "")
        
        quantityLabel.text = Material.formattedQuantity(forModifier: modifier)
        nameLabel.text  = text
        priceLabel.text = String(format: "%.2f $", material.price * modifier)
        
        if material.isPack {
            typeLabel.text = modifier > 1 ? "packs" : "pack"
        }
        else {
            typeLabel.text = modifier > 1 ? "units" : "unit"
        }
        
        setAlternativeBackground(forEvenIndexPath: indexPath)
        
        return self
    }
    
    func setAlternativeBackground(forEvenIndexPath indexPath: NSIndexPath) {
        if indexPath.row % 2 == 0 {
            self.backgroundColor = AppColors.whiteLight
        }
        else {
            self.backgroundColor = AppColors.white
        }
    }

}
