//
//  SupplierListController.swift
//  ProductionCost
//
//  Created by BT-Training on 19/09/16.
//  Copyright © 2016 BT-Training. All rights reserved.
//

import UIKit
import RealmSwift

class SupplierListController: UITableViewController {
    
    // MARK: Properties
    
    let results = try! Realm().objects(Supplier.self).sorted("name")
    
    // MARK: Overrides

    override func viewDidLoad() {
        super.viewDidLoad()
        
        nibRegistration(onTableView: tableView, forIdentifiers: "SupplierListCell", "AddSupplierCell")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        view.backgroundColor = AppColors.white
        
        tableView.rowHeight = 70
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EditSupplier" {
            guard let navControl = segue.destinationViewController as? UINavigationController,
                supplierForm = navControl.viewControllers[0] as? SupplierFormController  else {
                    return
            }
            
            supplierForm.supplierToEdit = (sender as! Supplier)
        }
    }
    
}

// MARK: EXT - Table view data source

extension SupplierListController {
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if results.count == 0 {
            return 1
        }
        
        return results.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if results.count == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier(
                "AddSupplierCell", forIndexPath: indexPath)
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier(
            "SupplierListCell", forIndexPath: indexPath) as! SupplierListCell
        
        let supplier = results[indexPath.row]
        
        cell.name.text    = supplier.name
        cell.address.text = supplier.address
        cell.setAlternativeBackground(forEvenIndexPath: indexPath)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            
            let supplier = results[indexPath.row]
            let realm = try! Realm()
            try! realm.write {
                realm.delete(supplier)
            }
            
            transition(onView: tableView, withDuration: 0.3) {
                self.tableView.reloadData()
            }
        }
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        guard results.count != 0 else {
            return false
        }
        
        return true
    }
    
}

// MARK: Table view delegate

extension SupplierListController {
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if results.count == 0 {
            performSegueWithIdentifier("AddSupplier", sender: nil)
        }
        else {
            performSegueWithIdentifier("EditSupplier", sender: results[indexPath.row])
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
}
