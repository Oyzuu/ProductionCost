//
//  SupplierFormController.swift
//  ProductionCost
//
//  Created by BT-Training on 19/09/16.
//  Copyright © 2016 BT-Training. All rights reserved.
//

import UIKit
import RealmSwift
import PKHUD
import CoreLocation
import MapKit

class SupplierFormController: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var nameField:      UITextField!
    @IBOutlet weak var addressField:   UITextField!
    @IBOutlet weak var locationButton: UIButton!
    @IBOutlet weak var mapView:        MKMapView!
    
    // MARK: Properties
    
    var supplierToEdit: Supplier?
    
    let manager = CLLocationManager()
    var location: CLLocation?
    var isGettingLocation = false
    
    let geocoder = CLGeocoder()
    var placemark: CLPlacemark?
    var isReverseGeocoding = false
    var lastGeocodingError: NSError?
    
    // MARK: Overrides

    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager.desiredAccuracy = 10
        manager.delegate = self
        
        if let supplierToEdit = self.supplierToEdit {
            title             = "Edit supplier"
            nameField.text    = supplierToEdit.name
            addressField.text = supplierToEdit.address
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let supplierToEdit = self.supplierToEdit,
            latitude  = supplierToEdit.latitude.value,
            longitude = supplierToEdit.longitude.value {
            showSupplier(withLatitude: latitude, andLongitude: longitude)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        location  = nil
        placemark = nil
    }
    
    // MARK: Methods
    
    @IBAction func save(sender: AnyObject) {
        var hudMessage = ""
        
        defer {
            HUD.flash(.LabeledSuccess(title: nil, subtitle: hudMessage), delay: 0.3) { result in
                self.manager.delegate = nil
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        
        if let supplierToEdit = self.supplierToEdit {
            let realm = try! Realm()
            try! realm.write {
                supplierToEdit.name            = nameField.text!
                supplierToEdit.address         = addressField.text!
                
                if let location = self.location {
                    supplierToEdit.latitude.value  = location.coordinate.latitude
                    supplierToEdit.longitude.value = location.coordinate.longitude
                }
            }
            
            hudMessage = "Edited"
        }
        else {
            let supplier             = Supplier()
            supplier.name            = nameField.text!
            supplier.address         = addressField.text!
            supplier.latitude.value  = location?.coordinate.latitude
            supplier.longitude.value = location?.coordinate.longitude
            
            let realm = try! Realm()
            try! realm.write {
                realm.add(supplier)
            }
            
            hudMessage = "Saved"
        }
    }
    
    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func getLocation(sender: AnyObject) {
        if CLLocationManager.authorizationStatus() == .NotDetermined {
            manager.requestWhenInUseAuthorization()
            
        }
        else if CLLocationManager.authorizationStatus() == .Denied {
            let alert = UIAlertController(title: "Location services disabled",
                                          message: "Please enable locations services for this app",
                                          preferredStyle: .Alert)
            let okAction = UIAlertAction(title: "Ok", style: .Default, handler: nil)
            alert.addAction(okAction)
            presentViewController(alert, animated: true) {
                return
            }
        }
        
        isGettingLocation = true
        manager.startUpdatingLocation()
    }
    
    private func stringFromPlacemark(placemark: CLPlacemark) -> String {
        var firstLine  = ""
        
        if let streetNumber = placemark.subThoroughfare {
            firstLine += streetNumber + ", "
        }
        
        if let streetName = placemark.thoroughfare {
            firstLine += streetName
        }
        
        
        
        var secondLine = ""
        
        if let postalCode = placemark.postalCode {
            secondLine += postalCode + " "
        }
        
        if let city = placemark.locality {
            secondLine += city
        }
        
        return firstLine + "\n" + secondLine
    }
    
    func presentValidation(forLocation location: CLLocation) {
        print("Present validation")
        var message = ""
        if let placemark = self.placemark {
            message = stringFromPlacemark(placemark)
        }
        else {
            message = "error getting address"
        }
        
        let alert = UIAlertController(title: "Is this correct ?",
                                      message: message,
                                      preferredStyle: .Alert)
        
        let cancelAction   = UIAlertAction(title: "No",  style: .Cancel) {
            action in
            self.location  = nil
            self.placemark = nil
            self.isGettingLocation = false
        }
        
        let validateAction = UIAlertAction(title: "Yes", style: .Default) {
            action in
            self.addressField.text! = message
            self.showSupplier(withLatitude: location.coordinate.latitude,
                              andLongitude: location.coordinate.longitude)
            self.location = location
        }
        
        alert.addAction(cancelAction)
        alert.addAction(validateAction)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func showSupplier(withLatitude latitude: Double, andLongitude longitude: Double) {
        // TODO: Make this safe
        let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let region = MKCoordinateRegionMakeWithDistance(center, 1000, 1000)
        mapView.setRegion(region, animated: true)
    }
    
}

// MARK: Location manager delegate

extension SupplierFormController: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse && isGettingLocation {
            manager.startUpdatingLocation()
            print("manager started from didChangeAuthStatus")
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last!
        print(newLocation)
        
        if newLocation.horizontalAccuracy <= manager.desiredAccuracy {
            manager.stopUpdatingLocation()
            print("Manager stopped updating location")
            isGettingLocation = false
            
            geocoder.reverseGeocodeLocation(newLocation) {
                placemarks, error in
                self.isReverseGeocoding = true
                print("isReverseGeocoding = true")
                
                self.lastGeocodingError = error
                
                if error == nil, let nonEmptyPlacemarks = placemarks where !nonEmptyPlacemarks.isEmpty {
                    self.placemark = nonEmptyPlacemarks.last!
                    print("Got placemark !")
                    self.presentValidation(forLocation: newLocation)
                }
                else {
                    self.placemark = nil
                    HUD.flash(.LabeledError(title: nil, subtitle: "No address found"), delay: 0.5)
                }
                
                self.isReverseGeocoding = false
                print("isReverseGeocoding = false")
            }
        }
    }
}
