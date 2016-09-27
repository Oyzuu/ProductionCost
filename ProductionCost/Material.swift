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
    
    /// used only for demo
    func with(name: String, quantity: Double, price: Double, category: String, supplier: Supplier) {
        self.isPack   = true
        self.name     = name
        self.quantity = quantity
        self.price    = price
        self.category = category
        self.supplier = supplier
    }
    
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
    
    func asArray(withModifier mod: Double, forFileType type: String) -> [String] {
        var componentArray = [String]()
        
        if name.characters.count > 18 && type == ".pdf" {
            let shortenedName =
                (name.stringByReplacingOccurrencesOfString("_", withString: "") as NSString)
                    .substringToIndex(14) + "..."
            componentArray.append(shortenedName)
        }
        else {
            componentArray.append(name.stringByReplacingOccurrencesOfString("_", withString: ""))
        }
        
        componentArray.append(Material.formattedQuantity(forMaterial: self, withModifier: mod))
        componentArray.append(category)
        
        if let supplier = supplier {
            if supplier.name.characters.count > 18 && type == ".pdf" {
                let supplierName = supplier.name as NSString
                componentArray.append(supplierName.substringToIndex(15) + "...")
            }
            else {
                componentArray.append(supplier.name)
            }
        }
        else {
            componentArray.append("-")
        }
        
        componentArray.append(String(format: "%.2f $", price * mod))
        
        return componentArray
    }
    
    static func formattedQuantity(forMaterial material: Material, withModifier mod: Double) -> String {
        var quantityText = ""
        if material.quantity * mod % 1 == 0 {
            quantityText = String(format: "%.0f", material.quantity * mod)
        }
        else {
            switch material.quantity * mod {
            case 0.25: quantityText = "1/4"
            case 0.50: quantityText = "1/2"
            case 0.75: quantityText = "3/4"
            default:   quantityText = "\(material.quantity * mod)"
            }
        }
        
        return quantityText
    }
}
