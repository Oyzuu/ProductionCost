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

    @IBOutlet weak var iconImageView:    UIImageView!
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

}
