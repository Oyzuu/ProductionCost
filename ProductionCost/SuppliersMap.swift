//
//  SuppliersMap.swift
//  ProductionCost
//
//  Created by BT-Training on 26/09/16.
//  Copyright © 2016 BT-Training. All rights reserved.
//

import UIKit
import MapKit

class SuppliersMap: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    
    // MARK: Properties
    
    var product: Product!
    
    // MARK: Overrides

    override func viewDidLoad() {
        super.viewDidLoad()
        
        for component in product.components {
            guard let supplier = component.material?.supplier else {
                continue
            }
            
            mapView.addAnnotation(supplier)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        showLocations()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Methods
    
    @IBAction func cancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func showUser() {
        let center = mapView.userLocation.coordinate
        let region = MKCoordinateRegionMakeWithDistance(center, 1000, 1000)
        mapView.setRegion(region, animated: true)
    }
    
    func showLocations() {
        mapView.setRegion(regionForAnnotations(mapView.annotations), animated: true)
    }
    
    func regionForAnnotations(annotations: [MKAnnotation]) -> MKCoordinateRegion {
        var region = MKCoordinateRegion()
        
        switch annotations.count {
        case 0:
            region = MKCoordinateRegionMakeWithDistance(mapView.userLocation.coordinate, 1000, 1000)
        case 1:
            region = MKCoordinateRegionMakeWithDistance(annotations[0].coordinate, 1000, 1000)
        default :
            var topLeft     = CLLocationCoordinate2D(latitude: -90, longitude:  180)
            var bottomRight = CLLocationCoordinate2D(latitude:  90, longitude: -180)
            
            for annotation in annotations {
                topLeft.latitude      = max(topLeft.latitude,      annotation.coordinate.latitude)
                topLeft.longitude     = min(topLeft.longitude,     annotation.coordinate.longitude)
                bottomRight.latitude  = min(bottomRight.latitude,  annotation.coordinate.latitude)
                bottomRight.longitude = max(bottomRight.longitude, annotation.coordinate.longitude)
                
                let centerLatitude  = topLeft.latitude  - (topLeft.latitude  - bottomRight.latitude)  / 2
                let centerLongitude = topLeft.longitude - (topLeft.longitude - bottomRight.longitude) / 2
                
                let center = CLLocationCoordinate2D(latitude: centerLatitude, longitude: centerLongitude)
                
                let extraSpace = 1.5
                let span = MKCoordinateSpan(
                    latitudeDelta:  extraSpace * abs(topLeft.latitude  - bottomRight.latitude),
                    longitudeDelta: extraSpace * abs(topLeft.longitude - bottomRight.longitude))
                
                region = MKCoordinateRegion(center: center, span: span)
            }
        }
        
        return mapView.regionThatFits(region)
    }
    
}

// MARK: EXT - Table view delegate

extension SuppliersMap: MKMapViewDelegate {
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let identifier = "Location"
        var annotationView =
            mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as! MKPinAnnotationView!
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            
            annotationView.enabled        = true
            annotationView.animatesDrop   = false
            annotationView.pinTintColor   = AppColors.raspberry
            annotationView.canShowCallout = true
        }
        else {
            annotationView.annotation = annotation
        }
        
        return annotationView
    }
    
}
