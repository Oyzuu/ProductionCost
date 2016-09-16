//
//  ProductFormController.swift
//  ProductionCost
//
//  Created by BT-Training on 15/09/16.
//  Copyright © 2016 BT-Training. All rights reserved.
//

import UIKit
import RealmSwift

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
    let product = Product()
    
    // MARK: Overrides

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "ProductDetail"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        view.backgroundColor = AppColors.whiteLight
//        totalBackgroundView.backgroundColor = AppColors.whiteLight
        
        tableView.backgroundColor    = AppColors.white
        imageView.layer.cornerRadius = imageView.frame.size.height / 2
//        addMaterialButton.layer.cornerRadius = addMaterialButton.frame.size.height / 2
        
        tableView.rowHeight = 50
        
        nibRegistration(onTableView: tableView, forIdentifiers: "MaterialInProductCell")
        
        // TODO: FOR TEST ONLY - SHOUD BE REMOVED
        
        if self.productToEdit != nil {
            
        }
        else {
            product.name = generateRandomString(ofSize: 10)
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func willMoveToParentViewController(parent: UIViewController?) {
        if parent == nil {
            print("victory !")
            realm(saveProduct: product)
        }        
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

}

// MARK: Table view data source

extension ProductDetailsController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return product.components.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(
            "MaterialInProductCell", forIndexPath: indexPath) as! MaterialInProductCell
        
        let material = product.components[indexPath.row]
        
        var text = ""
//        text += material.isPack        ? "pack:" : ""
//        text += material.isSubMaterial ? "sub:"  : ""
        text += material.name.stringByReplacingOccurrencesOfString("_", withString: "")
        
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
        try! Realm().write {
            product.components.append(material)
        }
        
        // TODO: place this in updateUI later
        
        totalPriceLabel.text         = String(format: "%.2f $", product.price)
        let numberOfComponents       = product.components.count
        var numberOfComponentsText   = "\(numberOfComponents)"
        numberOfComponentsText      += numberOfComponents > 1 ? " components" : "component"
        numberOfComponentsLabel.text = numberOfComponentsText
        
        tableView.reloadData()
    }
    
}




