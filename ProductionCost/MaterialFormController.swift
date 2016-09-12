//
//  AddMaterialViewController.swift
//  ProductionCost
//
//  Created by BT-Training on 12/09/16.
//  Copyright © 2016 BT-Training. All rights reserved.
//

import UIKit

// MARK: Delegate protocol

protocol MaterialFormDelegate: class {
    func MaterialForm(controller: MaterialFormController, didSave material: Material)
    func MaterialForm(controller: MaterialFormController, didEdit material: Material)
}

// MARK: Controller class

class MaterialFormController: UITableViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var nameField:     UITextField!
    @IBOutlet weak var priceField:    UITextField!
    @IBOutlet weak var quantityField: UITextField!
    
    // MARK: Properties
    
    weak var delegate: MaterialFormDelegate?
    
    // MARK: Override

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func save(sender: AnyObject) {
        let material = Material()
        material.name     = nameField.text!
        material.price    = stringToDouble(priceField.text!)
        material.quantity = stringToDouble(quantityField.text!)
        
        // TODO: remove after testing
        if material.quantity > 1 {
            material.isPack = true
        }
        
        delegate?.MaterialForm(self, didSave: material)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func stringToDouble(string: String) -> Double {
        return Double(string.stringByReplacingOccurrencesOfString(",", withString: "."))!
    }
    
}
