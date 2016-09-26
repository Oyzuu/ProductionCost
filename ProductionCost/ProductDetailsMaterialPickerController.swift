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
    func materialPicker(didPick material: Material, withQuantity quantity: Double)
}

class ProductDetailsMaterialPickerController: UITableViewController {
    
    // MARK: Properties
    
    var dataModel = [Material]()
    var results: Results<Material>?
    var delegate: MaterialPickerDelegate?
    
    // MARK: Overrides

    override func viewDidLoad() {
        super.viewDidLoad()
        
        results = try! Realm().objects(Material.self).sorted("name")
        updateDataModel()
        
        nibRegistration(onTableView: tableView, forIdentifiers: "MaterialInProductPickerCell")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.backgroundColor = AppColors.white
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ComponentQuantityModal" {
            guard let controller = segue.destinationViewController as? ComponentQuantityModal else {
                return
            }
            
            controller.delegate         = self
            controller.selectedMaterial = (sender as! Material)
        }
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
        let cell = tableView.dequeueReusableCellWithIdentifier(
            "MaterialInProductPickerCell", forIndexPath: indexPath) as! MaterialInProductPickerCell
        let material = dataModel[indexPath.row]
        
        let imageName = material.isPack || material.isSubMaterial ? "raspberry" : "naples"
        let image = UIImage(named: imageName)
        cell.indicator.image = image
        cell.indicator.alpha = material.isSubMaterial ? 0.5 : 1
        
        let text = material.name.stringByReplacingOccurrencesOfString("_", withString: "")
        cell.nameLabel.text  = text
        cell.priceLabel.text = String(format: "%.2f $", material.price)
        
        cell.setAlternativeBackground(forEvenIndexPath: indexPath)
        
        return cell
    }
    
}

// MARK: EXT - Table view delegate

extension ProductDetailsMaterialPickerController {
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let material = results![indexPath.row]
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        performSegueWithIdentifier("ComponentQuantityModal", sender: material)
    }
    
}

// MARK: EXT - Component quantity delegate

extension ProductDetailsMaterialPickerController: ComponentQuantityDelegate {
    
    func componentQuantityDelegate(didPick quantity: Double, onMaterial material: Material) {
        delegate?.materialPicker(didPick: material, withQuantity: quantity)
        dismissViewControllerAnimated(false, completion: nil)
        navigationController?.popViewControllerAnimated(true)
    }
    
}
