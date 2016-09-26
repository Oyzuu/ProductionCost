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
    dynamic var supplier: Supplier?
    
    // MARK: Methods
    
    func createDerivedComponent() {
        let subMaterial = Material()
        
        subMaterial.name          = "\(self.name)_"
        subMaterial.price         = self.price / self.quantity
        subMaterial.isSubMaterial = true
        subMaterial.category      = self.category
        subMaterial.supplier      = self.supplier
        
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
        subMaterial.supplier      = self.supplier
    }
    
    func asArray(withModifier mod: Double) -> [String] {
        var componentArray = [String]()
        
        componentArray.append(name.stringByReplacingOccurrencesOfString("_", withString: ""))
        componentArray.append("\(quantity * mod)")
        componentArray.append(category)
        
        if let supplier = supplier {
            componentArray.append(supplier.name)
        }
        else {
            componentArray.append("-")
        }
        
        componentArray.append(String(format: "%.2f $", price * mod))
        
        return componentArray
    }
}
