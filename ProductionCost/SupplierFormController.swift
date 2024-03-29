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
import SkyFloatingLabelTextField

class SupplierFormController: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var nameField:         UITextField!
    @IBOutlet weak var addressField:      UITextField!
    @IBOutlet weak var locationButton:    UIButton!
    @IBOutlet weak var mapView:           MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: Properties
    
    var supplierToEdit: Supplier?
    
    let manager = CLLocationManager()
    var location: CLLocation?
    var isGettingLocation = false
    
    let geocoder = CLGeocoder()
    var placemark: CLPlacemark?
    var isReverseGeocoding = false
    var lastGeocodingError: NSError?
    
    var mapViewForeground: UIView?
    
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let supplierToEdit = self.supplierToEdit,
            latitude  = supplierToEdit.latitude.value,
            longitude = supplierToEdit.longitude.value {
            showSupplier(withLatitude: latitude, andLongitude: longitude)
        }
        else {
            mapViewForeground = createColoredSubview(forView: mapView, withColor: AppColors.raspberry50)
            mapView.addSubview(mapViewForeground!)
        }
        
        locationButton.withRoundedBorders()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        location  = nil
        placemark = nil
    }
    
    // MARK: Methods
    
    @IBAction func save(sender: AnyObject) {
        view.endEditing(true)
        
        guard nameField.text?.trim() != "" else {
            (nameField as! SkyFloatingLabelTextField).errorMessage = "Name required"
            HUD.flash(.LabeledError(title: nil, subtitle: "Name required"), delay: 1) {
                result in
                self.nameField.shake()
            }
            return
        }
        
        guard addressField.text?.trim() != "" else {
            if let mapViewBlurredForeground = self.mapViewForeground {
                transition(onView: self.mapView, withDuration: 0.5) {
                    mapViewBlurredForeground.hidden = false
                }
            }
            
            let alert = UIAlertController(title: "Empty address field",
                                          message: "No address for this supplier. Continue ?",
                                          preferredStyle: .Alert)
            let noAction  = UIAlertAction(title: "No",  style: .Cancel, handler: nil)
            let yesAction = UIAlertAction(title: "Yes", style: .Default) { action in
                dispatch_after(500, dispatch_get_main_queue()) {
                    self.saveSupplier()
                }
            }
            
            alert.addAction(noAction)
            alert.addAction(yesAction)
            presentViewController(alert, animated: true, completion: nil)
            
            return
        }
        
        saveSupplier()
        
//        if location != nil {
//            saveSnapshot()
//        }
    }
    
    private func saveSupplier() {
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
                
                if addressField.text?.trim() != "", let location = self.location {
                    supplierToEdit.latitude.value  = location.coordinate.latitude
                    supplierToEdit.longitude.value = location.coordinate.longitude
                }
                else if addressField.text?.trim() != supplierToEdit.address {
                    supplierToEdit.latitude.value  = nil
                    supplierToEdit.longitude.value = nil
                }
                
                supplierToEdit.name    = nameField.text!
                supplierToEdit.address = addressField.text!
            }
            
            hudMessage = "Edited"
        }
        else {
            let supplier             = Supplier()
            supplier.name            = nameField.text!
            supplier.address         = addressField.text!
            
            if addressField.text?.trim() != "", let location = self.location {
                supplier.latitude.value  = location.coordinate.latitude
                supplier.longitude.value = location.coordinate.longitude
            }
            
            let realm = try! Realm()
            try! realm.write {
                realm.add(supplier)
            }
            
            hudMessage = "Saved"
        }
    }
    
    private func saveSnapshot() {
        let options = MKMapSnapshotOptions()
        options.region = mapView.region
        options.size   =
            CGSize(width: mapView.frame.size.width / 2, height: mapView.frame.size.height / 2)
        options.scale  = UIScreen.mainScreen().scale
        
        let snapShotter = MKMapSnapshotter(options: options)
        snapShotter.startWithCompletionHandler { snapshot, error in
            guard snapshot != nil else {
                return
            }
            
            if error != nil {
                print(error)
            }
            
            if let data = UIImagePNGRepresentation(snapshot!.image) {
                let filename = self.nameField.text!
                    .stringByReplacingOccurrencesOfString(" ", withString: "") + ".png"
                let filepath = getDocumentsDirectory() + filename
                
                do {
                    try data.writeToFile(filepath, options: .DataWritingAtomic)
                }
                catch {
                    print(error)
                }
            }
        }
    }
    
    @IBAction func cancel(sender: AnyObject) {
        view.endEditing(true)
        dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func getLocation(sender: AnyObject) {
        view.endEditing(true)
        
        if CLLocationManager.authorizationStatus() == .NotDetermined {
            manager.requestWhenInUseAuthorization()
            return
            
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
        updateLocationButton()
    }
    
    private func updateLocationButton() {
        if isGettingLocation || isReverseGeocoding {
            locationButton.setTitle("Getting location...", forState: .Normal)
            activityIndicator.startAnimating()
        }
        else {
            locationButton.setTitle("Get location", forState: .Normal)
            activityIndicator.stopAnimating()
        }
        
    }
    
    private func stringFromPlacemark(placemark: CLPlacemark) -> String {
        var firstLine  = ""
        
        if let streetNumber = placemark.subThoroughfare {
            firstLine += streetNumber + " "
            print("street number : \(streetNumber)")
        }
        
        if let streetName = placemark.thoroughfare {
            firstLine += streetName
            print("street name : \(streetName)")
        }
        
        var secondLine = ""
        
        if let postalCode = placemark.postalCode {
            secondLine += postalCode + " "
            print("postal code : \(postalCode)")
        }
        
        if let city = placemark.locality {
            secondLine += city
            print("city : \(city)")
        }
        
        return firstLine + " \n" + secondLine
    }
    
    func presentValidation(forLocation location: CLLocation) {
        var message = ""
        if let placemark = self.placemark {
            message = stringFromPlacemark(placemark)
            showSupplier(withLatitude: location.coordinate.latitude,
                         andLongitude: location.coordinate.longitude)
            if let mapViewForeground = self.mapViewForeground {
                transition(onView: mapView, withDuration: 0.5) {
                    mapViewForeground.hidden = true
                }
            }
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
            guard let mapViewBlurredForeground = self.mapViewForeground else {
                return
            }
            
            transition(onView: self.mapView, withDuration: 0.5) {
                mapViewBlurredForeground.hidden = false
            }
        }
        
        let validateAction = UIAlertAction(title: "Yes", style: .Default) {
            action in
            self.addressField.text! = message
            print(message)
            self.location = location
        }
        
        alert.addAction(cancelAction)
        alert.addAction(validateAction)
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func showSupplier(withLatitude latitude: Double, andLongitude longitude: Double) {
        let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let region = MKCoordinateRegionMakeWithDistance(center, 500, 500)
        mapView.setRegion(region, animated: true)
        mapView.addAnnotation(CLLocation(latitude: latitude, longitude: longitude))
    }
    
}

// MARK: EXT - Location manager delegate

extension SupplierFormController: CLLocationManagerDelegate {
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse && isGettingLocation {
            manager.startUpdatingLocation()
            print("manager started from didChangeAuthStatus")
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation    = locations.last!
        let lastUpdateDate = newLocation.timestamp
        let howRecent      = lastUpdateDate.timeIntervalSinceNow
        
        if newLocation.horizontalAccuracy <= manager.desiredAccuracy && abs(howRecent) < 2 {
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
                self.updateLocationButton()
            }
        }
    }
}

// MARK: EXT - Text field delegate

extension SupplierFormController: UITextFieldDelegate {
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let textField = (textField as! SkyFloatingLabelTextField)
        
        guard textField.hasErrorMessage else {
            return true
        }
        
        transition(onView: textField, withDuration: 0.5) {
            textField.errorMessage = ""
        }
        
        return true
    }
    
}

// MARK: EXT - Map View delegate

extension SupplierFormController: MKMapViewDelegate {
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let identifier = "Location"
        var annotationView =
            mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as! MKPinAnnotationView!
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation,
                                                 reuseIdentifier: "Location")
        
            annotationView.enabled      = true
            annotationView.animatesDrop = true
            annotationView.pinTintColor = AppColors.raspberry
        }
        else {
            annotationView.annotation = annotation
        }
        
        return annotationView
    }
    
}

// MARK: EXT - CLLocation to implement MKAnnotation

extension CLLocation: MKAnnotation {}
