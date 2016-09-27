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
import FontAwesome_swift
import UITextField_Shake_Swift

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
    @IBOutlet weak var supplierLabel: UILabel!
    
    @IBOutlet weak var nameWarning:     UIView!
    @IBOutlet weak var priceWarning:    UIView!
    @IBOutlet weak var quantityWarning: UIView!
    
    // MARK: Properties
    
    weak var delegate:  MaterialFormDelegate?
    var materialToEdit: Material?
    
    var isUnit                          = false
    var derivedComponentWillExistAtSave = false
    var hasErrors                       = false
    
    var componentSupplier: Supplier?
    
    // MARK: Override

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if materialToEdit == nil {
            nameField.becomeFirstResponder()
        }
        
        if isUnit {
            quantityField.text = "1"
        }
        
        if let materialToEdit = self.materialToEdit {
            title               = "Edit component"
            isUnit              = !materialToEdit.isPack
            quantityCell.hidden = isUnit
            
            nameField.text     = materialToEdit.name
            priceField.text    = String(format: "%.2f", materialToEdit.price)
            quantityField.text = String(materialToEdit.quantity)
            categoryLabel.text = materialToEdit.category
            
            if let supplierName = materialToEdit.supplier?.name {
                supplierLabel.text = supplierName
            }
            
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
        if segue.identifier == "CategoryPicker" {
            guard let destination = segue.destinationViewController as? CategoriesPickerController else {
                return
            }
            
            destination.delegate = self
        }
        
        if segue.identifier == "SupplierPicker" {
            guard let destination = segue.destinationViewController as? SupplierPickerController else {
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
        view.endEditing(true)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func save(sender: AnyObject) {
        view.endEditing(true)
        guard checkMandatoryFields() else {
            HUD.flash(.LabeledError(title: nil, subtitle: "Empty fields"), delay: 1) { result in
                self.shake(textFields: self.nameField, self.priceField, self.quantityField)
            }
            hasErrors = true
            return
        }
        
        hasErrors = false
        var hudMessage = ""
        defer {
            HUD.flash(.LabeledSuccess(title: nil, subtitle: hudMessage), delay: 0.5) { result in
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        
        if let materialToEdit = self.materialToEdit {
            let realm = try! Realm()
            
            try! realm.write() {
                materialToEdit.name     = nameField.text!.trim()
                materialToEdit.price    = stringToDouble(priceField.text!.trim())
                materialToEdit.quantity = stringToDouble(quantityField.text!.trim())
                materialToEdit.category = categoryLabel.text!.trim()
                materialToEdit.supplier = componentSupplier
                
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
            material.name     = nameField.text!.trim()
            material.price    = stringToDouble(priceField.text!.trim())
            material.quantity = stringToDouble(quantityField.text!.trim())
            material.isPack   = !isUnit
            material.category = categoryLabel.text!.trim()
            material.supplier = componentSupplier
            
            if derivedComponentSwitch.on {
                material.createDerivedComponent()
            }
            
            hudMessage = "Saved"
            
            delegate?.MaterialForm(didFinish: material)
        }
    }
    
    private func checkMandatoryFields() -> Bool {
        // TODO: Listen to fields to hide warning
        
        if nameField.text?.trim() != "" && priceField.text?.trim() != "" && quantityField.text?.trim() != "" {
            return true
        }
        
        if nameField.text?.trim() == "" {
            nameWarning.hidden = false
        }
        
        if priceField.text?.trim() == "" {
            priceWarning.hidden = false
        }
        
        if quantityField.text?.trim() == "" {
            quantityWarning.hidden = false
        }
        
        return false
    }
    
    private func shake(textFields fields: UITextField...) {
        for field in fields {
            if field.text == "" {
                field.shake()
            }
        }
    }
    
    @IBAction func addDerivedComponent(sender: AnyObject) {
        derivedComponentWillExistAtSave = !derivedComponentWillExistAtSave
        refreshDerivedComponentCell()
    }
    
    private func refreshDerivedComponentCell() {
        
        if derivedComponentWillExistAtSave {
            
            transition(onView: derivedComponentLabel, withDuration: 0.3) {
                self.derivedComponentLabel.text =  "\(self.materialToEdit!.name) per unit"
            }
            
            derivedComponentButton.setTitle("Remove", forState: .Normal)
        }
        else {
            
            transition(onView: derivedComponentLabel, withDuration: 0.3) {
                self.derivedComponentLabel.text = "No derived component"
            }
            
            derivedComponentButton.setTitle("Create", forState: .Normal)
        }
    }
    
}

// MARK: EXT - Table view delegate

extension MaterialFormController {
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        super.tableView(tableView, heightForRowAtIndexPath: indexPath)
        
        // Hide Quantity and sub material cell if material to add / edit is an unit
        if isUnit && (indexPath == NSIndexPath(forRow: 2, inSection: 0) ||
                      indexPath == NSIndexPath(forRow: 3, inSection: 0) ||
                      indexPath == NSIndexPath(forRow: 4, inSection: 0)) {
            return 0
        }
        else if materialToEdit != nil && indexPath == NSIndexPath(forRow: 3, inSection: 0) {
            return 0
        }
        else if materialToEdit == nil && indexPath == NSIndexPath(forRow: 4, inSection: 0) {
            return 0
        }
        
        return 44 // Default height for static cells
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

// MARK: EXT - Category picker delegate

extension MaterialFormController: CategoryPickerDelegate {
    
    func categoryPickerDelegate(didFinish categoryName: String) {
        categoryLabel.text = categoryName
    }
    
}

// MARK: EXT - Supplier picker delegate

extension MaterialFormController: SupplierPickerDelegate {
    
    func supplierPickerDelegate(didPick supplier: Supplier) {
        componentSupplier  = supplier
        supplierLabel.text = supplier.name
    }
    
}

// MARK: EXT - Text field delegate

extension MaterialFormController: UITextFieldDelegate {
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        guard hasErrors else {
            return true
        }
        
        guard textField.text!.isEmpty || (textField.text!.characters.count == 1 && string == "") else {
            return true
        }
        
        print("textfield is empty ? : \(string == "")")
        
        switch textField.tag {
        case 1:
            transition(onView: nameWarning, withDuration: 0.5) {
                self.nameWarning.hidden = string != ""
            }
        case 2:
            transition(onView: priceWarning, withDuration: 0.5) {
                self.priceWarning.hidden = string != ""
            }
        case 3:
            transition(onView: quantityWarning, withDuration: 0.5) {
                self.quantityWarning.hidden = string != ""
            }
            
        default: break
        }
        
        return true
    }
}






