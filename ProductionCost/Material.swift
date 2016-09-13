//
//  Material.swift
//  ProductionCost
//
//  Created by BT-Training on 12/09/16.
//  Copyright © 2016 BT-Training. All rights reserved.
//

import Foundation
import RealmSwift

class Material: Object {
    
    // MARK: properties
    
    dynamic var name             = ""
    dynamic var isPack           = false
    dynamic var subMaterial: Material?
    dynamic var quantity: Double = 1.0
    dynamic var isSubMaterial    = false
    dynamic var price: Double    = 0.0
    
// Specify properties to ignore (Realm won't persist these)
    
//  override static func ignoredProperties() -> [String] {
//    return []
//  }
    
    // MARK: Methods
    
    static func createSubMaterial(fromMaterial parent: Material) -> Material {
        let subMaterial = Material()
        
        subMaterial.name          = "from \(parent.name)"
        subMaterial.price         = parent.price / parent.quantity
        subMaterial.isSubMaterial = true
        
        return subMaterial
    }
}
