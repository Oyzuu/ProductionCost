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
    
    @IBOutlet weak var navigationBar: UINavigationBar!
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
        
        tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 49, right: 0)
        tableView.rowHeight    = 60
        
        nibRegistration(forIdentifiers: ProductCellIdentifiers.AddProductCell)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        updateDataModel()
        
        tableView.backgroundColor = AppColors.white50
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "AddProductSegue" {
            // TODO: fill this
            print("to add product")
        }
    }
    
    // MARK: Methods
    
    private func nibRegistration(forIdentifiers identifiers: String...) {
        for identifier in identifiers {
            let cellNib = UINib(nibName: identifier, bundle: nil)
            tableView.registerNib(cellNib, forCellReuseIdentifier: identifier)
        }
    }
    
    @IBAction func searchProducts(sender: AnyObject) {
        
    }
    
    @IBAction func addProduct(sender: AnyObject) {
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

// MARK: EXT - Navigation bar delegate

extension ProductListController: UINavigationBarDelegate {
    
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .TopAttached
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
        let identifier = ProductCellIdentifiers.AddProductCell
        
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! AddProductCell
        
        return cell
    }
    
}

// MARK: EXT - Tableview delegate

extension ProductListController:UITableViewDelegate {
    
    
    
}
