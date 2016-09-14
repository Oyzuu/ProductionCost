//
//  CategoriesController.swift
//  ProductionCost
//
//  Created by BT-Training on 14/09/16.
//  Copyright © 2016 BT-Training. All rights reserved.
//

import UIKit
import RealmSwift

// MARK: Categories Controller delegate

protocol CategoriesDelegate: class {
    func categoriesDelegate(didFinish categoryName: String)
}

class CategoriesPickerController: UITableViewController {
    
    // MARK: Properties
    
    var delegate: CategoriesDelegate?
    var dataModel = Category.values
    
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

// MARK: EXT - Table view data source

extension CategoriesPickerController {
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataModel.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("CategoryCell", forIndexPath: indexPath)
        cell.textLabel?.text = dataModel[indexPath.row]
        return cell
    }
    
}

// MARK: EXT - Table view delegate

extension CategoriesPickerController {
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        delegate?.categoriesDelegate(didFinish: dataModel[indexPath.row])
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        navigationController?.popViewControllerAnimated(true)
    }
    
}
