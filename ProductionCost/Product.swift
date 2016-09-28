//
//  Product.swift
//  ProductionCost
//
//  Created by BT-Training on 15/09/16.
//  Copyright © 2016 BT-Training. All rights reserved.
//

import Foundation
import RealmSwift

class Product: Object {
    
    // MARK: Properties
    
    dynamic var name = ""
    let components   = List<MaterialWithModifier>()
    
    var price: Double {
        var sum = 0.0
        
        for component in components {
            sum += component.material!.price * component.modifier
        }
        
        return sum
    }
    
    var suppliersCount: Int {
        var count = 0
        
        for component in components {
            if component.material?.supplier != nil {
                count += 1
            }
        }
        
        return count
    }
    
}
