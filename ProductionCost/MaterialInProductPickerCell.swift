//
//  MaterialInProductPickerCell.swift
//  ProductionCost
//
//  Created by BT-Training on 16/09/16.
//  Copyright © 2016 BT-Training. All rights reserved.
//

import UIKit

class MaterialInProductPickerCell: UITableViewCell {
    
    // MARK: Outlets

    @IBOutlet weak var nameLabel:  UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var indicator:  UIImageView!
    
    // MARK: Overrides
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let selectionView             = UIView(frame: CGRect.zero)
        selectionView.backgroundColor = AppColors.raspberry25
        self.selectedBackgroundView   = selectionView
        indicator.layer.cornerRadius  = indicator.frame.size.height / 2
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // MARK: Methods
    
    func setAlternativeBackground(forEvenIndexPath indexPath: NSIndexPath) {
        if indexPath.row % 2 == 0 {
            self.backgroundColor = AppColors.whiteLight
        }
        else {
            self.backgroundColor = AppColors.white
        }
    }

}
