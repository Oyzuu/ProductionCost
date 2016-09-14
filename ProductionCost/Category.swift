//
//  Category.swift
//  ProductionCost
//
//  Created by BT-Training on 14/09/16.
//  Copyright © 2016 BT-Training. All rights reserved.
//

import Foundation

enum Category: String {
    case food                  = "Food"
    case homeSupplies          = "Home supplies"
    case officeSupplies        = "Office supplies"
    case constructionMaterials = "Construction materials"
    case diySupplies           = "DIY supplies"
    case electronics           = "Electronics"
    case transport             = "Transport"
    case hourlyRate            = "Hourly rate"
    case noCategory            = "No category"
    case miscellaneous         = "Miscellaneous"
    
    static let values = [
        noCategory.rawValue,
        food.rawValue,
        homeSupplies.rawValue,
        officeSupplies.rawValue,
        constructionMaterials.rawValue,
        diySupplies.rawValue,
        electronics.rawValue,
        transport.rawValue,
        hourlyRate.rawValue,
        miscellaneous.rawValue
    ]
}
