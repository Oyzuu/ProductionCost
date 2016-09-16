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
            totalPriceLabel.text         = String(format: "%.2f", productToEdit.price)
        }
        else {
            product = Product()
            product.name = generateRandomString(ofSize: 10)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        view.backgroundColor         = AppColors.whiteLight
        tableView.backgroundColor    = AppColors.white
        imageView.layer.cornerRadius = imageView.frame.size.height / 2
        
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
    
}

// MARK : Table view delegate

extension ProductDetailsController: UITableViewDelegate {
    
}

// MARK: MaterialPickerDelegate

extension ProductDetailsController: MaterialPickerDelegate {
    
    func materialPicker(didPick material: Material) {
        let product = self.productToEdit == nil ? self.product : productToEdit
        
        try! Realm().write {
            product!.components.append(material)
        }
        
        // TODO: place this in updateUI later
        
        totalPriceLabel.text         = String(format: "%.2f $", product!.price)
        numberOfComponentsLabel.text = numberOfComponentsAsString(forProduct: product!)
        
        tableView.reloadData()
    }
    
}




