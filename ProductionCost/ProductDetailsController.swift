//
//  ProductFormController.swift
//  ProductionCost
//
//  Created by BT-Training on 15/09/16.
//  Copyright © 2016 BT-Training. All rights reserved.
//

import UIKit
import RealmSwift
import PKHUD
import LTMorphingLabel

class ProductDetailsController: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var totalBackgroundView: UIView!
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var numberOfComponentsLabel: UILabel!
    @IBOutlet weak var exportButton: UIButton!
    
    // MARk: Properties
    
    var productToEdit: Product?
    var product: Product!
    var isANewProduct = false
    
    // MARK: Overrides

    override func viewDidLoad() {
        super.viewDidLoad()
        
        nibRegistration(onTableView: tableView, forIdentifiers:
            "MaterialInProductCell", "AddSomethingCell")
        
        (numberOfComponentsLabel as! LTMorphingLabel).morphingEffect = .Evaporate
        (totalPriceLabel         as! LTMorphingLabel).morphingEffect = .Evaporate
        
        if let productToEdit = self.productToEdit {
            productNameLabel.text        = productToEdit.name
            numberOfComponentsLabel.text = numberOfComponentsAsString(forProduct: productToEdit)
            totalPriceLabel.text         = String(format: "%.2f $", productToEdit.price)
        }
        else {
            product                      = Product()
            numberOfComponentsLabel.text = "No components"
            totalPriceLabel.text         = "0 $"
            performSegueWithIdentifier("ProductNameEditionNA", sender: nil)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        view.backgroundColor                = AppColors.whiteLight
        imageView.layer.cornerRadius        = imageView.frame.size.height / 2
        totalBackgroundView.backgroundColor = AppColors.white
        tableView.backgroundColor           = AppColors.white
        
        tableView.rowHeight = 50
        
        updateUI()
        bottomScroll()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func willMoveToParentViewController(parent: UIViewController?) {
        guard parent == nil else {
            return
        }
        
        if self.productToEdit != nil || isANewProduct {
            return
        }
        
        // TODO: Should verify field completion
        
        product.name = productNameLabel.text!
        realm(saveProduct: product)
        HUD.flash(.LabeledSuccess(title: nil, subtitle: product.name + " has been saved"),
                  delay: 0.5)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ProductComponentPicker" {
            if let controller = segue.destinationViewController as? ProductDetailsMaterialPickerController {
                controller.delegate = self
            }
        }
        
        if segue.identifier == "ExportModal" {
            if let controller = segue.destinationViewController as? ExportModal {
                controller.productToExport = getActiveProduct()
            }
        }
        
        if segue.identifier == "ProductNameEdition" {
            if let controller = segue.destinationViewController as? ProductNameEditionController {
                controller.nameToEdit = getActiveProduct().name
                controller.delegate   = self
            }
        }
        
        if segue.identifier == "ProductNameEditionNA" {
            if let controller = segue.destinationViewController as? ProductNameEditionController {
                controller.nameToEdit = getActiveProduct().name
                controller.delegate   = self
            }
        }
    }
    
    // MARK: Methods
    
    private func realm(saveProduct product: Product) {
        let realm = try! Realm()
        
        try! realm.write {
            realm.add(product)
        }
    }
    
    private func numberOfComponentsAsString(forProduct product: Product) -> String {
        let numberOfComponents       = product.components.count
        var numberOfComponentsText   = "\(numberOfComponents)"
        numberOfComponentsText      += numberOfComponents > 1 ? " components" : " component"
        
        return numberOfComponentsText
    }
    
    private func updateUI() {
        let product = getActiveProduct()
        
        totalPriceLabel.text         = String(format: "%.2f $", product.price)
        numberOfComponentsLabel.text = self.numberOfComponentsAsString(forProduct: product)
        
        transition(onView: tableView, withDuration: 0.3) {
            self.tableView.reloadData()
        }
    }
    
    private func bottomScroll() {
        tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: getActiveProduct().components.count, inSection: 0),
                                         atScrollPosition: .Bottom, animated: true)
    }
    
    private func getActiveProduct() -> Product {
        let product = productToEdit == nil ? self.product : productToEdit
        
        return product
    }
    
}

// MARK: Table view data source

extension ProductDetailsController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getActiveProduct().components.count + 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let product = getActiveProduct()
        
        let count = product.components.count
        //(count > 0 && indexPath.row == count)
        if count == 0 || (count > 0 && indexPath.row == count) {
            let cell = tableView.dequeueReusableCellWithIdentifier(
                "AddSomethingCell", forIndexPath: indexPath) as! AddSomethingCell
            cell.addLabel.hidden   = count != 0
            cell.addAwesome.hidden = count == 0
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier(
                "MaterialInProductCell", forIndexPath: indexPath) as! MaterialInProductCell
            
            let material = getActiveProduct().components[indexPath.row].material!
            let modifier = getActiveProduct().components[indexPath.row].modifier
            
            let text = material.name.stringByReplacingOccurrencesOfString("_", withString: "")
            
            if material.quantity * modifier % 1 == 0 {
                cell.quantityLabel.text = String(format: "%.0f",material.quantity * modifier)
            }
            else {
                switch material.quantity * modifier {
                case 0.25: cell.quantityLabel.text = "1/4"
                case 0.50: cell.quantityLabel.text = "1/2"
                case 0.75: cell.quantityLabel.text = "3/4"
                default:   cell.quantityLabel.text = String(material.quantity * modifier)
                }
            }
            
            cell.nameLabel.text  = text
            cell.priceLabel.text = String(format: "%.2f $", material.price * modifier)
            
            cell.setAlternativeBackground(forEvenIndexPath: indexPath)
            
            return cell
        }
        
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            
            try! Realm().write {
                if let productToEdit = self.productToEdit {
                    productToEdit.components.removeAtIndex(indexPath.row)
                }
                else {
                    product.components.removeAtIndex(indexPath.row)
                }
            }
            
            updateUI()
        }
    }
    
}

// MARK: Table view delegate

extension ProductDetailsController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if tableView.cellForRowAtIndexPath(indexPath)?.reuseIdentifier == "AddSomethingCell" {
            return false
        }
        
        return true
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tableView.cellForRowAtIndexPath(indexPath)?.reuseIdentifier == "AddSomethingCell" {
            performSegueWithIdentifier("ProductComponentPicker", sender: nil)
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
}

// MARK: EXT - MaterialPickerDelegate

extension ProductDetailsController: MaterialPickerDelegate {
    
    func materialPicker(didPick material: Material, withQuantity quantity: Double) {
        let product = getActiveProduct()
        
        // TODO: Uncomment these to implement reference counting on unique MaterialWithModifier
        
//        let results = try! Realm().objects(MaterialWithModifier.self)
//            .filter("material = %@ AND modifier = %@", material, quantity)
        
        try! Realm().write {
            var materialWithModifier: MaterialWithModifier
//            
//            if results.count > 0 {
//                materialWithModifier = results.first!
//            }
//            else {
                materialWithModifier = MaterialWithModifier()
                materialWithModifier.material = material
                materialWithModifier.modifier = quantity
//            }
            
            product.components.append(materialWithModifier)
        }
        
        updateUI()
        bottomScroll()
    }
    
}

// MARK: EXT - ProductNameEditionDelegate

extension ProductDetailsController: ProductNameEditionDelegate {
    
    func productNameEditionDelegate(didCancel controller: ProductNameEditionController) {
        dismissViewControllerAnimated(true, completion: nil)
        
        if isANewProduct {
            navigationController?.popViewControllerAnimated(true)
        }
    }
    
    func productNameEditionDelegate(didFinishEditing name: String) {
        productNameLabel.text = name
        isANewProduct = false
        
        if let productToEdit = self.productToEdit {
            try! Realm().write {
                productToEdit.name = name
            }
        }
    }
    
}




