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
    
    // MARK: Realm properties
    
    dynamic var name             = ""
    dynamic var address: String? = nil
    let         latitude         = RealmOptional<Double>()
    let         longitude        = RealmOptional<Double>()
    
    // MARK: MKAnnotation properties
    
    var coordinate: CLLocationCoordinate2D {
        guard let latitude = self.latitude.value, let longitude = self.longitude.value else {
            return CLLocationCoordinate2D()
        }
        
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
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