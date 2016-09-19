//
//  Supplier.swift
//  ProductionCost
//
//  Created by BT-Training on 19/09/16.
//  Copyright © 2016 BT-Training. All rights reserved.
//

import Foundation
import RealmSwift

class Supplier: Object {
    
    dynamic var name             = ""
    let         latitude         = RealmOptional<Double>()
    let         longitude        = RealmOptional<Double>()
    dynamic var address: String? = nil
    
}
