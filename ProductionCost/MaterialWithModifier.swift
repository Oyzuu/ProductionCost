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
    
    dynamic var material: Material?
    dynamic var modifier   = 1.0
    dynamic var usageCount = 0
    
}
