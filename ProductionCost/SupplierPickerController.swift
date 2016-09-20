//
//  SupplierPickerController.swift
//  ProductionCost
//
//  Created by BT-Training on 19/09/16.
//  Copyright © 2016 BT-Training. All rights reserved.
//

import UIKit
import RealmSwift

protocol SupplierPickerDelegate: class {
    func supplierPickerDelegate(didPick supplier: Supplier)
}

class SupplierPickerController: UITableViewController {
    
    // MARK: Properties
    
    var delegate: SupplierPickerDelegate?
    let results = try! Realm().objects(Supplier.self).sorted("name")
    
    // MARK: Overrides

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.tableFooterView = UIView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

// MARK: table view data source

extension SupplierPickerController {
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SupplierPickerCell", forIndexPath: indexPath)
        
        cell.textLabel?.text       = results[indexPath.row].name
        cell.detailTextLabel?.text = results[indexPath.row].address
        
        return cell
    }
    
}

// MARK: Table view delegate

extension SupplierPickerController {
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        delegate?.supplierPickerDelegate(didPick: results[indexPath.row])
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        navigationController?.popViewControllerAnimated(true)
    }
    
}
