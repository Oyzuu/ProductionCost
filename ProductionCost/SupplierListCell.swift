//
//  SupplierListCell.swift
//  ProductionCost
//
//  Created by BT-Training on 19/09/16.
//  Copyright © 2016 BT-Training. All rights reserved.
//

import UIKit

class SupplierListCell: UITableViewCell {
    
    // MARK: Outlets
    
    @IBOutlet weak var name:    UILabel!
    @IBOutlet weak var address: UILabel!
    
    // MARK: Overrides

    override func awakeFromNib() {
        super.awakeFromNib()
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
