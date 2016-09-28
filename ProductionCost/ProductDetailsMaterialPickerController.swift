//
//  ProductDetailsMaterialPickerController.swift
//  ProductionCost
//
//  Created by BT-Training on 15/09/16.
//  Copyright © 2016 BT-Training. All rights reserved.
//

import UIKit
import RealmSwift
import PKHUD

// MARK: Protocol for delegate

protocol MaterialPickerDelegate: class {
    func materialPicker(didPick material: Material, withQuantity quantity: Double)
}

class ProductDetailsMaterialPickerController: UITableViewController {
    
    // MARK: Properties
    
    var results = try! Realm().objects(Material.self).sorted("name")
    var delegate: MaterialPickerDelegate?
    
    // MARK: Overrides

    override func viewDidLoad() {
        super.viewDidLoad()
        
        nibRegistration(onTableView: tableView, forIdentifiers: "MaterialInProductPickerCell")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.backgroundColor = AppColors.white
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if results.count == 0 {
            HUD.flash(.Label("No component found"), delay: 1) { result in
                self.navigationController?.popViewControllerAnimated(true)
            }
        }
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

}

// MARK: EXT- Table view data source

extension ProductDetailsMaterialPickerController {

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(
            "MaterialInProductPickerCell", forIndexPath: indexPath) as! MaterialInProductPickerCell
        let material = results[indexPath.row]
        
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
        let material = results[indexPath.row]
        
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
