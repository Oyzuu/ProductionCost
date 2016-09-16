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

class ProductDetailsController: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var totalBackgroundView: UIView!
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var addMaterialButton: UIButton!
    @IBOutlet weak var numberOfComponentsLabel: UILabel!
    
    // MARk: Properties
    
    var productToEdit: Product?
    var product: Product!
    
    // MARK: Overrides

    override func viewDidLoad() {
        super.viewDidLoad()
        
        nibRegistration(onTableView: tableView, forIdentifiers: "MaterialInProductCell")
        
        if let productToEdit = self.productToEdit {
            productNameLabel.text        = productToEdit.name
            numberOfComponentsLabel.text = numberOfComponentsAsString(forProduct: productToEdit)
            totalPriceLabel.text         = String(format: "%.2f $", productToEdit.price)
        }
        else {
            product                      = Product()
            product.name                 = generateRandomString(ofSize: 10)
            productNameLabel.text        = product.name
            numberOfComponentsLabel.text = "No components"
            totalPriceLabel.text         = "0 $"
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        view.backgroundColor                = AppColors.whiteLight
        imageView.layer.cornerRadius        = imageView.frame.size.height / 2
        totalBackgroundView.backgroundColor = AppColors.white
        tableView.backgroundColor           = AppColors.white
        
        tableView.rowHeight = 50 
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func willMoveToParentViewController(parent: UIViewController?) {
        guard parent == nil else {
            return
            
        }
        
        if self.productToEdit != nil {
            return
        }
        
        realm(saveProduct: product)
        HUD.flash(.LabeledSuccess(title: nil, subtitle: "Saved !"), delay: 0.5)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ProductDetailsMaterialPicker" {
            if let controller = segue.destinationViewController as? ProductDetailsMaterialPickerController {
                controller.delegate = self
            }
        }
    }
    
    // MARK: Methods
    
    @IBAction func addMaterial() {
        print("add material")
    }
    
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
        let product = productToEdit == nil ? self.product : productToEdit
        
        transition(onView: totalPriceLabel, withDuration: 0.3) {
            self.totalPriceLabel.text = String(format: "%.2f $", product.price)
        }
        
        transition(onView: numberOfComponentsLabel, withDuration: 0.3) {
            self.numberOfComponentsLabel.text = self.numberOfComponentsAsString(forProduct: product)
        }
        
        transition(onView: tableView, withDuration: 0.3) {
            self.tableView.reloadData()
        }
    }
    
}

// MARK: Table view data source

extension ProductDetailsController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let productToEdit = self.productToEdit {
            return productToEdit.components.count
        }
        return product.components.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(
            "MaterialInProductCell", forIndexPath: indexPath) as! MaterialInProductCell
        
        var material: Material!
        
        if let productToEdit = self.productToEdit {
            material = productToEdit.components[indexPath.row]
        }
        else {
            material = product.components[indexPath.row]
        }
        
        let text = material.name.stringByReplacingOccurrencesOfString("_", withString: "")
        
        cell.quantityLabel.text = String(material.quantity)
        cell.nameLabel.text = text
        cell.priceLabel.text = String(format: "%.2f $", material.price)
        
        return cell
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
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
}

// MARK: MaterialPickerDelegate

extension ProductDetailsController: MaterialPickerDelegate {
    
    func materialPicker(didPick material: Material) {
        let product = self.productToEdit == nil ? self.product : productToEdit
        
        try! Realm().write {
            product!.components.append(material)
        }
        
        // TODO: place this in updateUI later
        
        updateUI()
        
        tableView.scrollToNearestSelectedRowAtScrollPosition(.Bottom, animated: true)
    }
    
}




