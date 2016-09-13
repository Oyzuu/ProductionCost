//
//  ViewController.swift
//  ProductionCost
//
//  Created by BT-Training on 12/09/16.
//  Copyright © 2016 BT-Training. All rights reserved.
//

import UIKit
import RealmSwift

// MARK: Cell indentifiers constants

struct CellIdentifiers {
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
        results = realm.objects(Material.self)
        updateDataModel()
        
        // tableView init
        
        tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 49, right: 0)
        tableView.rowHeight = 60
        
        nibRegistration(forIdentifiers:
            CellIdentifiers.AddMaterialCell,
            CellIdentifiers.UnitMaterialCell,
            CellIdentifiers.PackMaterialCell,
            CellIdentifiers.SubMaterialCell)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
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
        let actionSheet = UIAlertController(title: "Material type", message: "",
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

    @IBAction func searchMaterial(sender: AnyObject) {
        guard dataModel.count > 0 else {
            print("empty array")
            return
        }
        
        let realm = try! Realm()
        
        try! realm.write {
            for material in dataModel {
                realm.add(material)
            }
        }
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
    
}

extension MaterialListController: MaterialFormDelegate {
    
    func MaterialForm(controller: MaterialFormController, didSave material: Material) {
        dataModel.append(material)
        
        // TODO: Clean this ASAP
        searchMaterial(material)
        
        updateDataModel()
        tableView.reloadData()
    }
    
    func MaterialForm(controller: MaterialFormController, didEdit material: Material) {
        
    }
    
}

// MARK: EXT - Navigation bar delegate

extension MaterialListController: UINavigationBarDelegate {
    
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .TopAttached
    }
    
}

// MARK: EXT - Table view delegate

extension MaterialListController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if dataModel.count == 0 {
            addMaterial(self)
        }
        else {
            performSegueWithIdentifier("EditMaterialSegue", sender: indexPath.row)
        }

        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let material = dataModel[indexPath.row]
            
            let realm = try! Realm()
            try! realm.write {
                if let subMaterial = material.subMaterial {
                    realm.delete(subMaterial)
                }
                
                realm.delete(material)
            }
            
            updateDataModel()
            tableView.reloadData()
        }
    }
    
}

// MARK: EXT - Table view data source

extension MaterialListController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if dataModel.count == 0 {
            return 1
        }
        else {
            return dataModel.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        print(dataModel.count)
        
        if dataModel.count == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier(
                CellIdentifiers.AddMaterialCell, forIndexPath: indexPath) as! AddMaterialCell
            
            return cell
        }
        else {
            let material   = dataModel[indexPath.row]
            var identifier = ""
            
            switch (material.isPack, material.isSubMaterial) {
            case (true, _): identifier = CellIdentifiers.PackMaterialCell
            case (_, true): identifier = CellIdentifiers.SubMaterialCell
            default:        identifier = CellIdentifiers.UnitMaterialCell
            }
            
            let cell = tableView.dequeueReusableCellWithIdentifier(
                identifier, forIndexPath: indexPath) as! MainMaterialCell
            
            cell.prepare(withMaterial: material)
            cell.setAlternativeBackground(forEvenIndexPath: indexPath)
            
            return cell
        }
    }
}

