//
//  AppDelegate.swift
//  ProductionCost
//
//  Created by BT-Training on 12/09/16.
//  Copyright © 2016 BT-Training. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        window?.tintColor = AppColors.raspberry
        
        // TEST
//        print(NSLocale.preferredLanguages()[0])
//        if NSLocale.preferredLanguages()[0].hasPrefix("fr-") {
//            print("OKAY C'EST DU FRANCAIS")
//        }
        
        FIRApp.configure()
        
        UIBarButtonItem.appearance()
            .setTitleTextAttributes([NSFontAttributeName : UIFont(name: "Avenir", size: 16)!],
                                    forState: .Normal)
        
        printDocumentsDirectory()
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        
    }

    func applicationDidEnterBackground(application: UIApplication) {
        
    }

    func applicationWillEnterForeground(application: UIApplication) {
        
    }

    func applicationDidBecomeActive(application: UIApplication) {
        
    }

    func applicationWillTerminate(application: UIApplication) {
        
    }


}

