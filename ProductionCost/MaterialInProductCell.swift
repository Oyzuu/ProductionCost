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

}
