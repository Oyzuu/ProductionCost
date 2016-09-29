//
//  ModifiedMaterial.swift
//  ProductionCost
//
//  Created by BT-Training on 22/09/16.
//  Copyright © 2016 BT-Training. All rights reserved.
//

import Foundation
import RealmSwift

class MaterialWithModifier: Object {
    
    // MARK: Realm properties
    
    dynamic var material: Material?
    dynamic var modifier   = 1.0
    
}
