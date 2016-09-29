//
//  Supplier.swift
//  ProductionCost
//
//  Created by BT-Training on 19/09/16.
//  Copyright © 2016 BT-Training. All rights reserved.
//

import Foundation
import RealmSwift
import MapKit

class Supplier: Object, MKAnnotation {
    
    // MARK: Stored properties
    
    dynamic var name             = ""
    dynamic var address: String? = nil
    let         latitude         = RealmOptional<Double>()
    let         longitude        = RealmOptional<Double>()
    
    // MARK: MKAnnotation properties
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude.value!, longitude: longitude.value!)
    }
    
    var title: String? {
        return name
    }
    
    var subtitle: String? {
        if let address = self.address {
            return address
        }
        
        return "No address"
    }
    
    // MARK: Hash value
    
    override var hashValue: Int {
        var hash = name.characters.count
        
        if let latitude = self.latitude.value {
            hash += abs(Int(latitude))
        }
        
        if let longitude = self.longitude.value {
            hash += abs(Int(longitude))
        }
        
        return hash
    }
    
}