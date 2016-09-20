//
//  AboutController.swift
//  ProductionCost
//
//  Created by BT-Training on 20/09/16.
//  Copyright © 2016 BT-Training. All rights reserved.
//

import UIKit

class AboutController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        addBlurredBackground(onView: self.view, withStyle: .Dark)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func close(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
