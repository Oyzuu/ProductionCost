//
//  ProductCell.swift
//  ProductionCost
//
//  Created by BT-Training on 15/09/16.
//  Copyright © 2016 BT-Training. All rights reserved.
//

import UIKit

class ProductCell: UITableViewCell {
    
    // MARK: Outlets

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var numberOfComponentsLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var customImage: UIImageView!
    
    // MARK: Overrides

    override func awakeFromNib() {
        super.awakeFromNib()
        
        customImage.layer.cornerRadius = customImage.frame.size.height / 2
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
