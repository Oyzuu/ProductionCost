//
//  ProductListController.swift
//  ProductionCost
//
//  Created by BT-Training on 15/09/16.
//  Copyright © 2016 BT-Training. All rights reserved.
//

import UIKit
import RealmSwift

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
        
        // tableView init
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Methods
    
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
    
    private func nibRegistration(forIdentifiers identifiers: String...) {
        for identifier in identifiers {
            let cellNib = UINib(nibName: identifier, bundle: nil)
            tableView.registerNib(cellNib, forCellReuseIdentifier: identifier)
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
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ProductCell", forIndexPath: indexPath)
        
        return cell
    }
    
}

// MARK: EXT - Tableview delegate

extension ProductListController:UITableViewDelegate {
    
    
    
}
