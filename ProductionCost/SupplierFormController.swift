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

class SupplierFormController: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var addressField: UITextField!
    @IBOutlet weak var locationButton: UIButton!
    
    // MARK: Properties
    
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        location  = nil
        placemark = nil
    }
    
    // MARK: Methods
    
    @IBAction func save(sender: AnyObject) {
        let supplier     = Supplier()
        supplier.name    = nameField.text!
        supplier.address = addressField.text!
        
        
        let realm = try! Realm()
        try! realm.write {
            realm.add(supplier)
        }
        
        HUD.flash(.LabeledSuccess(title: nil, subtitle: "Saved"), delay: 0.3) { result in
            self.manager.delegate = nil
            self.navigationController?.popViewControllerAnimated(true)
        }
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
        }
        
        alert.addAction(cancelAction)
        alert.addAction(validateAction)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
}

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
