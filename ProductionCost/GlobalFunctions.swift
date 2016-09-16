//
//  GlobalFunctions.swift
//  ProductionCost
//
//  Created by BT-Training on 13/09/16.
//  Copyright © 2016 BT-Training. All rights reserved.
//

import Foundation
import UIKit

func printDocumentsDirectory() {
    let urls = NSFileManager.defaultManager()
        .URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
    let documentsDirectory = urls[0]
    print(documentsDirectory)
}


/// Shortening wrapper for transitionWithview
func transtion(onView view: UIView, withDuration duration: Double, closure: () -> ()) {
    UIView.transitionWithView(view,
                              duration: duration,
                              options: UIViewAnimationOptions.TransitionCrossDissolve,
                              animations: closure,
                              completion: nil)
}

/// Register variadic nib identifiers on a UITableView
func nibRegistration(onTableView tableView: UITableView, forIdentifiers identifiers: String...) {
    for identifier in identifiers {
        let cellNib = UINib(nibName: identifier, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: identifier)
    }
}