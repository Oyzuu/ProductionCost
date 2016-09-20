//
//  ProductListController.swift
//  ProductionCost
//
//  Created by BT-Training on 15/09/16.
//  Copyright © 2016 BT-Training. All rights reserved.
//

import UIKit
import RealmSwift

// MARK: Cell indentifiers constants

struct ProductCellIdentifiers {
    static let ProductCell    = "ProductCell"
    static let AddProductCell = "AddProductCell"
}

class ProductListController: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var tableView:     UITableView!
    
    // MARK: Properties
    
    var dataModel = [Product]()
    var results: Results<Product>?
    
    // MARK: Overrides

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let realm = try! Realm()
        results   = realm.objects(Product.self).sorted("name")
        
        updateDataModel()
        
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 49, right: 0)
        tableView.rowHeight    = 80
        
        nibRegistration(onTableView: tableView, forIdentifiers:
            ProductCellIdentifiers.AddProductCell,
            ProductCellIdentifiers.ProductCell)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        updateDataModel()
        tableView.reloadData()
        
        tableView.backgroundColor = AppColors.white50
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ProductDetails" {
            guard let controller = segue.destinationViewController as? ProductDetailsController else {
                return
            }
            
            if let productToEdit = sender as? Product {
                controller.productToEdit = productToEdit
                print("with product : \(productToEdit.name)")
            }
            else {
                print("without product")
            }
        }
    }
    
    // MARK: Methods
    
    @IBAction func addProduct(sender: AnyObject) {
        performSegueWithIdentifier("ProductDetails", sender: sender)
    }
    
    private func updateDataModel() {
        guard let results = self.results else {
            return
        }
        
        dataModel = []
        for result in results {
            dataModel.append(result)
        }
    }
    
    private func realm(saveProduct product: Product) {
        let realm = try! Realm()
        
        try! realm.write {
            realm.add(product)
        }
    }
    
}

// MARK: EXT - Table view data source

extension ProductListController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if dataModel.count == 0 {
            return 1
        }
        
        return dataModel.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        if dataModel.count == 0 {
            let identifier = ProductCellIdentifiers.AddProductCell
            let cell = tableView.dequeueReusableCellWithIdentifier(
                identifier, forIndexPath: indexPath)
            
            return cell
        }
        
        let identifier = ProductCellIdentifiers.ProductCell
        let product = dataModel[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier(
            identifier, forIndexPath: indexPath) as! ProductCell
        
        cell.nameLabel.text  = product.name
        cell.priceLabel.text = String(format: "%.2f $", product.price)
        
        let numberOfComponents            = product.components.count
        var numberOfComponentsText        = "\(numberOfComponents)"
        numberOfComponentsText           += numberOfComponents > 1 ? " components" : " component"
        cell.numberOfComponentsLabel.text = numberOfComponentsText
        
        return cell
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        guard dataModel.count > 0 else {
            return
        }
        
        if editingStyle == .Delete {
            let product = dataModel[indexPath.row]
            
            let realm = try! Realm()
            try! realm.write {
                realm.delete(product)
            }
            
            updateDataModel()
            
            transition(onView: tableView, withDuration: 0.3){
                self.tableView.reloadData()
            }
        }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if dataModel.count == 0 {
            return false
        }
        
        return true
    }
    
}

// MARK: EXT - Tableview delegate

extension ProductListController:UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if dataModel.count == 0 {
            addProduct(self)
        }
        else {
            addProduct(dataModel[indexPath.row])
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
}
