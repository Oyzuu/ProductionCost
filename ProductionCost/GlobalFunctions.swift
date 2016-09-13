//
//  GlobalFunctions.swift
//  ProductionCost
//
//  Created by BT-Training on 13/09/16.
//  Copyright © 2016 BT-Training. All rights reserved.
//

import Foundation

func printDocumentsDirectory() {
    let urls = NSFileManager.defaultManager()
        .URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
    let documentsDirectory = urls[0]
    print(documentsDirectory)
}