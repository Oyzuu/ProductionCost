//
//  ViewController.swift
//  ProductionCost
//
//  Created by BT-Training on 12/09/16.
//  Copyright © 2016 BT-Training. All rights reserved.
//

import UIKit
import RealmSwift
import PKHUD

// MARK: Cell indentifiers constants

struct MaterialCellIdentifiers {
    static let PackMaterialCell = "PackMaterialCell"
    static let UnitMaterialCell = "UnitMaterialCell"
    static let AddMaterialCell  = "AddMaterialCell"
    static let SubMaterialCell  = "SubMaterialCell"
}

class MaterialListController: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Properties
    
    var dataModel = [Material]()
    var results: Results<Material>?
    
    // MARK: Overrides

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let realm = try! Realm()
        results   = realm.objects(Material.self).sorted("name")
        updateDataModel()
        
        // tableView init
        
//        tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 49, right: 0)
        tableView.rowHeight = 60
        
        nibRegistration(onTableView: tableView, forIdentifiers:
            MaterialCellIdentifiers.AddMaterialCell,
            MaterialCellIdentifiers.UnitMaterialCell,
            MaterialCellIdentifiers.PackMaterialCell,
            MaterialCellIdentifiers.SubMaterialCell)
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
        if segue.identifier == "AddMaterialSegue" {
            guard let navControl = segue.destinationViewController as? UINavigationController,
            materialForm = navControl.viewControllers[0] as? MaterialFormController  else {
                return
            }
            
            materialForm.delegate = self
            materialForm.isUnit = sender as! Bool
        }
        
        if segue.identifier == "EditMaterialSegue" {
            guard let navControl = segue.destinationViewController as? UINavigationController,
                materialForm = navControl.viewControllers[0] as? MaterialFormController  else {
                    return
            }
            
            materialForm.delegate = self
            
            guard let index = sender as? Int else {
                return
            }
            
            materialForm.materialToEdit = dataModel[index]
        }
    }
    
    // MARK: Methods

    @IBAction func addMaterial(sender: AnyObject) {
        let actionSheet = UIAlertController(title: "Component type", message: "",
                                            preferredStyle: .ActionSheet)
        
        let addUnit = UIAlertAction(title: "Unit", style: .Default) { action in
            self.performSegueWithIdentifier("AddMaterialSegue", sender: true)
        }
        
        let addPack = UIAlertAction(title: "Pack", style: .Default) { action in
            self.performSegueWithIdentifier("AddMaterialSegue", sender: false)
        }
        let cancel  = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        actionSheet.addAction(addUnit)
        actionSheet.addAction(addPack)
        actionSheet.addAction(cancel)
        
        presentViewController(actionSheet, animated: true, completion: nil)
    }

    @IBAction func searchMaterials(sender: AnyObject) {
        tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .Automatic)
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
    
    private func realm(saveMaterial material: Material) {
        let realm = try! Realm()
        
        try! realm.write {
            realm.add(material)
        }
    }
    
    private func realm(deleteMaterial material: Material) {
        let realm = try! Realm()
        
        try! realm.write {
            if let subMaterial = material.subMaterial {
                realm.delete(subMaterial)
            }
            
            realm.delete(material)
        }
    }
    
    private func showUsageAlert(forMaterial material: Material, inNumberOfComponents number: Int) {
        let message =
            "This component is used in " + (number > 1 ? "some" : "a") + " product" + (number > 1 ? "s" : "") +
        ", do you want to delete it ?"
        
        let alert = UIAlertController(title: "Component in use",
                                      message: message, preferredStyle: .Alert)
        
        let noAction     = UIAlertAction(title: "No",     style: .Cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "Delete", style: .Destructive) {
            action in
            
            self.realm(deleteMaterial: material)
            
            self.updateDataModel()
            
            transition(onView: self.tableView, withDuration: 0.3) {
                self.tableView.reloadData()
            }
        }
        
        alert.addAction(noAction)
        alert.addAction(deleteAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
}

// MARK: Material form delegate

extension MaterialListController: MaterialFormDelegate {
    
    func MaterialForm(didFinish material: Material?) {
        if let material = material {
            realm(saveMaterial: material)
        }
        
        updateDataModel()
        tableView.reloadData()
    }
    
}

// MARK: EXT - Table view delegate

extension MaterialListController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if dataModel.count == 0 {
            addMaterial(self)
        }
            
        else if dataModel[indexPath.row].isSubMaterial {
            let subComponent = dataModel[indexPath.row]
            let predicate    = NSPredicate(format: "subMaterial = %@", subComponent)
            let parent       = try! Realm().objects(Material.self).filter(predicate).first
            let parentIndex  = dataModel.indexOf(parent!)
            let subtitle     =
            "This is a derived component, you have to edit the source component."
            
            let alert = UIAlertController(title: "You can't edit this",
                                          message: subtitle,
                                          preferredStyle: .Alert)
            let cancelAction      = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            let takeMeThereAction = UIAlertAction(title: "Take me there", style: .Default) {
                action in
                self.performSegueWithIdentifier("EditMaterialSegue", sender: parentIndex)
            }
            
            alert.addAction(cancelAction)
            alert.addAction(takeMeThereAction)
            presentViewController(alert, animated: true, completion: nil)
        }
        else {
            performSegueWithIdentifier("EditMaterialSegue", sender: indexPath.row)
        }

        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if dataModel.count == 0 {
            return false
        }
        
        return true
    }

}

// MARK: EXT - Table view data source

extension MaterialListController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if dataModel.count == 0 {
            return 1
        }

        return dataModel.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {        
        if dataModel.count == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier(
                MaterialCellIdentifiers.AddMaterialCell, forIndexPath: indexPath)
            
            return cell
        }
        else {
            let material   = dataModel[indexPath.row]
            var identifier = ""
            
            switch (material.isPack, material.isSubMaterial) {
            case (true, _): identifier = MaterialCellIdentifiers.PackMaterialCell
            case (_, true): identifier = MaterialCellIdentifiers.SubMaterialCell
            default:        identifier = MaterialCellIdentifiers.UnitMaterialCell
            }
            
            let cell = tableView.dequeueReusableCellWithIdentifier(
                identifier, forIndexPath: indexPath) as! MainMaterialCell
            
            cell.prepare(withMaterial: material)
            cell.setAlternativeBackground(forEvenIndexPath: indexPath)
            
            return cell
        }
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        guard dataModel.count > 0 else {
            return
        }
        
        if editingStyle == .Delete {
            let material = dataModel[indexPath.row]
            
            let inProductsCount =
                try! Realm().objects(Product.self).filter("%@ in components", material).count
            
            if inProductsCount == 0 && material.subMaterial == nil {
                realm(deleteMaterial: material)
                
                updateDataModel()
                
                transition(onView: tableView, withDuration: 0.3) {
                    self.tableView.reloadData()
                }
            }
            else if let submaterial = material.subMaterial {
                let submaterialInProductsCount =
                    try! Realm().objects(Product.self).filter("%@ in components", submaterial).count
                
                if submaterialInProductsCount > 0 {
                    showUsageAlert(forMaterial: material,
                                   inNumberOfComponents: submaterialInProductsCount + inProductsCount)
                }
            }
            else {
                showUsageAlert(forMaterial: material, inNumberOfComponents: inProductsCount)
            }
        }
    }
    
}

