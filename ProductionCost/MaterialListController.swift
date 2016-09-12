//
//  ViewController.swift
//  ProductionCost
//
//  Created by BT-Training on 12/09/16.
//  Copyright © 2016 BT-Training. All rights reserved.
//

import UIKit
import RealmSwift

struct CellIdentifiers {
    static let MainMaterialCell = "MainMaterialCell"
    static let AddMaterialCell  = "AddMaterialCell"
    static let SubMaterialCell  = "SubMaterialCell"
}

class MaterialListController: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Properties
    
//    var materials = [
//        (name: "bonjour",       quantity: "par 20",     price: "1,00 $",    isPack: true),
//        (name: "au revoir",     quantity: "",           price: "15,99 $",   isPack: false),
//        (name: "qsdqsdqsd",     quantity: "par 0,5",    price: "3500,96 $", isPack: true),
//        (name: "DsdhuD",        quantity: "",           price: "1000 $",    isPack: false),
//        (name: "jhsqoih SQd'd", quantity: "par 3/4",    price: "150000 $",  isPack: true),
//        (name: "Qsdss",         quantity: "",           price: "0,65 $",    isPack: false),
//        (name: "ZeruDsdh",      quantity: "",           price: "2,36 $",    isPack: false)
//    ]
    
    var materials = [Material]()
    
    // MARK: Overrides

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let urls = NSFileManager.defaultManager()
            .URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let documentsDirectory = urls[0]
        print(documentsDirectory)
        
//        let mat1 = Material()
//        mat1.name  = "bonjour"
//        mat1.price = 1.56
//        materials.append(mat1)
//        
//        let mat2 = Material()
//        mat2.name  = "au revoir"
//        mat2.price = 150.56
//        materials.append(mat2)
//        
//        let mat3 = Material()
//        mat3.name  = "à demain"
//        mat3.isPack = true
//        mat3.quantity = 6
//        mat3.price = 25.59
//        materials.append(mat3)
        
        tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
        tableView.rowHeight = 60
        
        var cellNib = UINib(nibName: CellIdentifiers.MainMaterialCell, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: CellIdentifiers.MainMaterialCell)
        
        cellNib = UINib(nibName: CellIdentifiers.AddMaterialCell, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: CellIdentifiers.AddMaterialCell)
        
//        var cellNib = UINib(nibName: CellIdentifiers.MainMaterialCell, bundle: nil)
//        tableView.registerNib(cellNib, forCellReuseIdentifier: CellIdentifiers.MainMaterialCell)
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
        }
    }
    
    // MARK: Methods

    @IBAction func addMaterial(sender: AnyObject) {
        let actionSheet = UIAlertController(title: "Material type", message: "",
                                            preferredStyle: .ActionSheet)
        
        let addUnit = UIAlertAction(title: "Unit", style: .Default) { action in
            print("add unit")
            
            self.performSegueWithIdentifier("AddMaterialSegue", sender: nil)
        }
        
        let addPack = UIAlertAction(title: "Pack",   style: .Default, handler: nil)
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
        else {
            let cell = tableView.dequeueReusableCellWithIdentifier(
                CellIdentifiers.MainMaterialCell, forIndexPath: indexPath) as! MainMaterialCell
            
            let result = materials[indexPath.row]
            
            cell.iconImageView.image = result.isPack ? UIImage(named: "pack") : UIImage(named: "unit")
            
            cell.nameLabel.text        = result.name
            cell.informationLabel.text = result.quantity == 1 ? "" : "by \(result.quantity)"
            cell.priceLabel.text       = "\(result.price) $"
            
            return cell
        }
    }
}

