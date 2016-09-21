//
//  GlobalFunctions.swift
//  ProductionCost
//
//  Created by BT-Training on 13/09/16.
//  Copyright © 2016 BT-Training. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

func printDocumentsDirectory() {
    let urls = NSFileManager.defaultManager()
        .URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
    let documentsDirectory = urls[0]
    print(documentsDirectory)
}

/// I needed this for testing at some point, don't judge me.
func generateRandomString(ofSize size: Int) -> String {
    var string = ""
    let lowerCaseAlphabet = "abcdefghijklmnopqrstuvwxyz"
    for _ in 0..<size {
        let randomIndex = arc4random_uniform((UInt32(lowerCaseAlphabet.characters.count)))
        let charAtIndex =
            String(lowerCaseAlphabet[lowerCaseAlphabet.startIndex.advancedBy(Int(randomIndex))])
        
        string += arc4random() % 2 == 0 ? charAtIndex : charAtIndex.uppercaseString
    }

    return string
}

/// Shortening wrapper for transitionWithview
func transition(onView view: UIView, withDuration duration: Double, action: () -> ()) {
    UIView.transitionWithView(view,
                              duration: duration,
                              options: UIViewAnimationOptions.TransitionCrossDissolve,
                              animations: action,
                              completion: nil)
}

/// Shortening wrapper for transitionWithview with completion closure
func transition(onView view: UIView, withDuration duration: Double, action: () -> (), completion: (Bool) -> ()) {
    UIView.transitionWithView(view,
                              duration: duration,
                              options: UIViewAnimationOptions.TransitionCrossDissolve,
                              animations: action,
                              completion: completion)
}

/// Shortening wrapper for transitionWithview to be called by the view
extension UIView {
    
    func transition(withDuration duration: Double, action: () -> ()) {
        UIView.transitionWithView(self,
                                  duration: duration,
                                  options: UIViewAnimationOptions.TransitionCrossDissolve,
                                  animations: action,
                                  completion: nil)
    }
    
    func transition(onView view: UIView, withDuration duration: Double, action: () -> (), completion: (Bool) -> ()) {
        UIView.transitionWithView(view,
                                  duration: duration,
                                  options: UIViewAnimationOptions.TransitionCrossDissolve,
                                  animations: action,
                                  completion: completion)
    }
    
}

/// Register variadic nib identifiers on a UITableView
func nibRegistration(onTableView tableView: UITableView, forIdentifiers identifiers: String...) {
    for identifier in identifiers {
        let cellNib = UINib(nibName: identifier, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: identifier)
    }
}

/// String easy trim
extension String {
    
    func trim() -> String {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
    
}

/// Add a blurred background
func addBlurredBackground(onView view: UIView, withStyle style: UIBlurEffectStyle) {
    let blurEffect  = UIBlurEffect(style: style)
    let blurredView = UIVisualEffectView(effect: blurEffect)
    
    blurredView.frame = view.bounds
    blurredView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
    
    view.addSubview(blurredView)
    view.sendSubviewToBack(blurredView)
}

/// Wrapper for Realm instance configuration
func setDefaultRealmForUser(username: String) {
    var config = Realm.Configuration()
    
    config.fileURL = config.fileURL!.URLByDeletingLastPathComponent!
        .URLByAppendingPathComponent("\(username).realm")
    
    // Set this as the configuration used for the default Realm
    Realm.Configuration.defaultConfiguration = config
}
