//
//  ProductDetailsMaterialPickerController.swift
//  ProductionCost
//
//  Created by BT-Training on 15/09/16.
//  Copyright © 2016 BT-Training. All rights reserved.
//

import UIKit
import RealmSwift

// MARK: Protocol for delegate

protocol MaterialPickerDelegate: class {
    func materialPicker(didPick material: Material)
}

class ProductDetailsMaterialPickerController: UITableViewController {
    
    // MARK: Properties
    
    var dataModel = [Material]()
    var results: Results<Material>?
    var delegate: MaterialPickerDelegate?
    
    // MARK: Overrides

    override func viewDidLoad() {
        super.viewDidLoad()
        
        results = try! Realm().objects(Material.self)
        updateDataModel()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Methods
    
    private func updateDataModel() {
        guard let results = self.results else {
            return
        }
        
        dataModel = []
        for result in results {
            dataModel.append(result)
        }
    }

}

// MARK: EXT- Table view data source

extension ProductDetailsMaterialPickerController {

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataModel.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ProductDetailsMaterialPickerCell", forIndexPath: indexPath)
        let material = dataModel[indexPath.row]
        var text = ""
        text += material.isPack        ? "pack:" : ""
        text += material.isSubMaterial ? "sub:"  : ""
        text += material.name.stringByReplacingOccurrencesOfString("_", withString: "")
        
        cell.textLabel?.text = text
        cell.detailTextLabel!.text = String(format: "%.2f $", material.price)
        
        return cell
    }
    
}

// MARK: EXT - Table view delegate

extension ProductDetailsMaterialPickerController {
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        delegate?.materialPicker(didPick: dataModel[indexPath.row])
        navigationController?.popViewControllerAnimated(true)
    }
    
}
