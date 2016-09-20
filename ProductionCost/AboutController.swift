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
        
        let blurEffect  = UIBlurEffect(style: .Dark)
        let blurredView = UIVisualEffectView(effect: blurEffect)
        blurredView.frame = view.bounds
        blurredView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
        view.addSubview(blurredView)
        view.sendSubviewToBack(blurredView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func close(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
