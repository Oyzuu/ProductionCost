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
    
    // used only on SuppliersMap thus need to exclude suppliers without coordinate
    var suppliersCount: Int {
        var count = 0
        
        for component in components {
            guard let supplier = component.material?.supplier else {
                print("no supplier")
                continue
            }
            
            if supplier.coordinate.latitude != 0 &&  supplier.coordinate.longitude != 0 {
                count += 1
                print("found supplier coordinate")
            }
            else {
                print("empty supplier coordinate")
            }
        }
        
        return count
    }
    
}
