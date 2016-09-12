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
    
    var materials = [Material]()
    
    // MARK: Overrides

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let realm = try! Realm()
        let results = realm.objects(Material.self)
        for result in results {
            materials.append(result)
        }
        
        // tableView init
        
        tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 49, right: 0)
        tableView.rowHeight = 60
        
        var cellNib = UINib(nibName: CellIdentifiers.PackMaterialCell, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: CellIdentifiers.PackMaterialCell)
        
        cellNib = UINib(nibName: CellIdentifiers.AddMaterialCell, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: CellIdentifiers.AddMaterialCell)
        
        cellNib = UINib(nibName: CellIdentifiers.UnitMaterialCell, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: CellIdentifiers.UnitMaterialCell)
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
    }
    
    // MARK: Methods

    @IBAction func addMaterial(sender: AnyObject) {
        let actionSheet = UIAlertController(title: "Material type", message: "",
                                            preferredStyle: .ActionSheet)
        
        let addUnit = UIAlertAction(title: "Unit", style: .Default) { action in
            self.performSegueWithIdentifier("AddMaterialSegue", sender: true)
        }
        
        let addPack = UIAlertAction(title: "Pack",   style: .Default) { action in
            self.performSegueWithIdentifier("AddMaterialSegue", sender: false)
        }
        let cancel  = UIAlertAction(title: "Cancel", style: .Cancel,  handler: nil)
        
        actionSheet.addAction(addUnit)
        actionSheet.addAction(addPack)
        actionSheet.addAction(cancel)
        
        presentViewController(actionSheet, animated: true, completion: nil)
    }

    @IBAction func searchMaterial(sender: AnyObject) {
        guard materials.count > 0 else {
            print("empty array")
            return
        }
        
        let realm = try! Realm()
        
        try! realm.write {
            for material in materials {
                realm.add(material)
            }
        }
    }
    
}

extension MaterialListController: MaterialFormDelegate {
    
    func MaterialForm(controller: MaterialFormController, didSave material: Material) {
        materials.append(material)
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
        if materials.count == 0 {
            addMaterial(self)
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
}

// MARK: EXT - Table view data source

extension MaterialListController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if materials.count == 0 {
            return 1
        }
        else {
            return materials.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        print(materials.count)
        
        if materials.count == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier(
                CellIdentifiers.AddMaterialCell, forIndexPath: indexPath) as! AddMaterialCell
            
            return cell
        }
        else if materials[indexPath.row].isPack {
            let cell = tableView.dequeueReusableCellWithIdentifier(
                CellIdentifiers.PackMaterialCell, forIndexPath: indexPath) as! MainMaterialCell
            
            let result = materials[indexPath.row]
            
            cell.nameLabel.text        = result.name
            let tempQuantity = "\(result.quantity)"
            cell.informationLabel.text = result.quantity == 1 ? "" : "by \(result.quantity)"
            cell.priceLabel.text       = "\(result.price) $"
            
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier(
                CellIdentifiers.UnitMaterialCell, forIndexPath: indexPath) as! MainMaterialCell
            
            let result = materials[indexPath.row]
            
            cell.nameLabel.text        = result.name
            cell.priceLabel.text       = "\(result.price) $"
            
            return cell
        }
    }
}

