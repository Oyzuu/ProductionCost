//
//  AddMaterialViewController.swift
//  ProductionCost
//
//  Created by BT-Training on 12/09/16.
//  Copyright © 2016 BT-Training. All rights reserved.
//

import UIKit
import RealmSwift

// TODO: Fix form to manage Createing / Removing derived components

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
    @IBOutlet weak var quantityCell:  UITableViewCell!
    
    @IBOutlet weak var subSwitch: UISwitch!
    @IBOutlet weak var derivedComponentLabel:  UILabel!
    @IBOutlet weak var derivedComponentButton: UIButton!
    
    // MARK: Properties
    
    weak var delegate: MaterialFormDelegate?
    var materialToEdit: Material?
    var isUnit = false
    
    // MARK: Override

    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameField.becomeFirstResponder()
        
        if let materialToEdit = self.materialToEdit {
            title               = "Edit material"
            isUnit              = !materialToEdit.isPack
            quantityCell.hidden = isUnit
            
            nameField.text     = materialToEdit.name
            priceField.text    = String(format: "%.2f", materialToEdit.price)
            quantityField.text = String(materialToEdit.quantity)
            subSwitch.on       = materialToEdit.subMaterial != nil
            
            guard materialToEdit.subMaterial != nil else {
                return
            }
            
            derivedComponentLabel.text = "\(materialToEdit.name) per unit"
            derivedComponentButton.setTitle("Remove", forState: .Normal)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        subSwitch.onTintColor = AppColors.naples
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
        
        if subSwitch.on {
            material.subMaterial = Material.createSubMaterial(fromMaterial: material)
        }
        
        // TODO: Check if item exists in database with exactly same attributes
        
        delegate?.MaterialForm(self, didSave: material)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func addDerivedComponent(sender: AnyObject) {
        guard let materialToEdit = self.materialToEdit else {
            return
        }
        
        if materialToEdit.subMaterial != nil {
            // TODO: Realm fuckery to fix
            materialToEdit.subMaterial = nil
            
            derivedComponentLabel.text = "No derived component"
            derivedComponentButton.setTitle("Create", forState: .Normal)
        }
        else {
            // TODO: Realm fuckery to fix
            materialToEdit.subMaterial = Material.createSubMaterial(fromMaterial: materialToEdit)
            
            derivedComponentLabel.text =  "\(materialToEdit.name) per unit"
            derivedComponentButton.setTitle("Remove", forState: .Normal)
        }
    }
    
    func stringToDouble(string: String) -> Double {
        return Double(string.stringByReplacingOccurrencesOfString(",", withString: "."))!
    }
    
}

// MARK: Table view delegate

extension MaterialFormController {
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        super.tableView(tableView, heightForRowAtIndexPath: indexPath)
        
        // Hide Quantity and sub material cell if material to add / edit is an unit
        if isUnit && (indexPath == NSIndexPath(forRow: 2, inSection: 0) ||
                      indexPath == NSIndexPath(forRow: 3, inSection: 0)) {
            return 0
        }
        
        return 44 // Default height for static cells
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
