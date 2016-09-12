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
    @IBOutlet weak var quantityCell: UITableViewCell!
    
    // MARK: Properties
    
    weak var delegate: MaterialFormDelegate?
    var materialToEdit: Material?
    var isUnit = true
    
    // MARK: Override

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isUnit {
            quantityCell.hidden = true
        }
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
        material.quantity = isUnit ? 1 : stringToDouble(quantityField.text!)
        material.isPack   = !isUnit
        
        // TODO: Check if item exists in database with exactly same attributes
        
        delegate?.MaterialForm(self, didSave: material)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func stringToDouble(string: String) -> Double {
        return Double(string.stringByReplacingOccurrencesOfString(",", withString: "."))!
    }
    
}


extension MaterialFormController {
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        super.tableView(tableView, heightForRowAtIndexPath: indexPath)
        
        if isUnit && indexPath == NSIndexPath(forRow: 2, inSection: 0) {
            return 0
        }
        
        return 44
    }
}
