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

func getDocumentsDirectory() -> String {
//    let urls = NSFileManager.defaultManager()
//        .URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
    let bis = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
    return bis + "/"
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

/// Register variadic nib identifiers on a UITableView
func nibRegistration(onTableView tableView: UITableView, forIdentifiers identifiers: String...) {
    for identifier in identifiers {
        let cellNib = UINib(nibName: identifier, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: identifier)
    }
}

/// Add a blurred background view with selected style
func addBlurredBackground(onView view: UIView, withStyle style: UIBlurEffectStyle) {
    let blurEffect  = UIBlurEffect(style: style)
    let blurredView = UIVisualEffectView(effect: blurEffect)
    
    blurredView.frame            = view.bounds
    blurredView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
    
    view.addSubview(blurredView)
    view.sendSubviewToBack(blurredView)
    view.backgroundColor = UIColor.clearColor()
}

/// returns a blurred view with selected style
func createBlurredSubview(forView view: UIView, withStyle style: UIBlurEffectStyle) -> UIView {
    let blurEffect  = UIBlurEffect(style: style)
    let blurredView = UIVisualEffectView(effect: blurEffect)
    
    blurredView.frame            = view.bounds
    blurredView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
    
    return blurredView
}

/// returns a view with selected color
func createColoredSubview(forView view: UIView, withColor color: UIColor) -> UIView {
    let foregroundView = UIView()
    
    foregroundView.frame            = view.bounds
    foregroundView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
    foregroundView.backgroundColor  = color
    
    return foregroundView
}

/// Wrapper for Realm instance configuration
func setDefaultRealmForUser(username: String) {
    var config = Realm.Configuration()
    
    config.fileURL = config.fileURL!.URLByDeletingLastPathComponent!
        .URLByAppendingPathComponent("\(username).realm")
    
    // Set this as the configuration used for the default Realm
    Realm.Configuration.defaultConfiguration = config
}

func stringToDouble(string: String) -> Double {
    return Double(string.stringByReplacingOccurrencesOfString(",", withString: "."))!
}

// MARK: Extensions

/// String easy trim
extension String {
    
    func trim() -> String {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
    }
    
}

extension UIView {
    
    func round() {
        self.layer.cornerRadius = self.frame.size.height / 2
    }
    
    func withRoundedBorders() {
        self.layer.cornerRadius = 2
    }
    
}