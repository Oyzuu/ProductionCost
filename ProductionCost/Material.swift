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
    dynamic var quantity: Double = 1.0
    dynamic var price:    Double = 0.0
    dynamic var isSubMaterial    = false
    dynamic var isPack           = false
    dynamic var subMaterial: Material?
    
    dynamic var category = "No category"
    
// Specify properties to ignore (Realm won't persist these)
    
//  override static func ignoredProperties() -> [String] {
//    return []
//  }
    
    // MARK: Methods
    
    func createDerivedComponent() {
        let subMaterial = Material()
        
        subMaterial.name          = "\(self.name)_"
        subMaterial.price         = self.price / self.quantity
        subMaterial.isSubMaterial = true
        subMaterial.category      = self.category
        
        self.subMaterial = subMaterial
    }
    
    func updateDerivedComponent() {
        guard let subMaterial = self.subMaterial else {
            return
        }
        
        subMaterial.name          = "\(self.name)_"
        subMaterial.price         = self.price / self.quantity
        subMaterial.isSubMaterial = true
        subMaterial.category      = self.category
    }
}
