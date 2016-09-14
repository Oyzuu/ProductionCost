//
//  AddMaterialViewController.swift
//  ProductionCost
//
//  Created by BT-Training on 12/09/16.
//  Copyright © 2016 BT-Training. All rights reserved.
//

import UIKit
import RealmSwift
import PKHUD

// MARK: Delegate protocol

protocol MaterialFormDelegate: class {
    func MaterialForm(didFinish material: Material?)
}

// MARK: Controller class

class MaterialFormController: UITableViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var nameField:     UITextField!
    @IBOutlet weak var priceField:    UITextField!
    @IBOutlet weak var quantityField: UITextField!
    @IBOutlet weak var quantityCell:  UITableViewCell!
    
    @IBOutlet weak var derivedComponentSwitch: UISwitch!
    @IBOutlet weak var derivedComponentLabel:  UILabel!
    @IBOutlet weak var derivedComponentButton: UIButton!
   
    @IBOutlet weak var categoryLabel: UILabel!
    
    // MARK: Properties
    
    weak var delegate: MaterialFormDelegate?
    var isUnit = false
    var materialToEdit: Material?
    var derivedComponentWillExistAtSave = false
    
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
            categoryLabel.text = materialToEdit.category
            
            if materialToEdit.subMaterial != nil {
                derivedComponentWillExistAtSave = true
            }
            
            refreshDerivedComponentCell()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        derivedComponentSwitch.onTintColor = AppColors.naples
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "CategoryPickerSegue" {
            guard let destination = segue.destinationViewController as? CategoriesPickerController else {
                return
            }
            
            destination.delegate = self
        }
        
    }
    
    // MARK: Methods

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func save(sender: AnyObject) {
        var hudMessage = ""
        defer {
            HUD.flash(.LabeledSuccess(title: nil, subtitle: hudMessage), delay: 1) { result in
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        
        if let materialToEdit = self.materialToEdit {
            let realm = try! Realm()
            
            try! realm.write() {
                materialToEdit.name     = nameField.text!
                materialToEdit.price    = stringToDouble(priceField.text!)
                materialToEdit.quantity = stringToDouble(quantityField.text!)
                materialToEdit.category = categoryLabel.text!
                
                if derivedComponentWillExistAtSave && materialToEdit.subMaterial == nil {
                    materialToEdit.createDerivedComponent()
                }
                else if !derivedComponentWillExistAtSave && materialToEdit.subMaterial != nil {
                    let copyOfSubmaterial = materialToEdit.subMaterial
                    materialToEdit.subMaterial = nil
                    realm.delete(copyOfSubmaterial!)
                }
                else {
                    materialToEdit.updateDerivedComponent()
                }
            }
            
            hudMessage = "Edited"
            
            delegate?.MaterialForm(didFinish: nil)
        }
        else {
            let material = Material()
            material.name     = nameField.text!
            material.price    = stringToDouble(priceField.text!)
            material.quantity = isUnit ? 1 : stringToDouble(quantityField.text!)
            material.isPack   = !isUnit
            material.category = categoryLabel.text!
            
            if derivedComponentSwitch.on {
                material.createDerivedComponent()
            }
            
            hudMessage = "Saved"
            
            delegate?.MaterialForm(didFinish: material)
        }
    }
    
    @IBAction func addDerivedComponent(sender: AnyObject) {
        derivedComponentWillExistAtSave = !derivedComponentWillExistAtSave
        refreshDerivedComponentCell()
    }
    
    private func refreshDerivedComponentCell() {
        
        if derivedComponentWillExistAtSave {
            
            transtion(onView: derivedComponentLabel, withDuration: 0.3) {
                self.derivedComponentLabel.text =  "\(self.materialToEdit!.name) per unit"
            }
            
            derivedComponentButton.setTitle("Remove", forState: .Normal)
        }
        else {
            
            transtion(onView: derivedComponentLabel, withDuration: 0.3) {
                self.derivedComponentLabel.text = "No derived component"
            }
            
            derivedComponentButton.setTitle("Create", forState: .Normal)
        }
    }
    
    func stringToDouble(string: String) -> Double {
        return Double(string.stringByReplacingOccurrencesOfString(",", withString: "."))!
    }
    
}

// MARK: EXT - Table view delegate

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

// MARK: EXT - Categories picker controller delegate

extension MaterialFormController: CategoriesDelegate {
    
    func categoriesDelegate(didFinish categoryName: String) {
        categoryLabel.text = categoryName
    }
    
}
