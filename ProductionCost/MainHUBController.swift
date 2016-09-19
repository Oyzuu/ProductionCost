//
//  MainHUBController.swift
//  ProductionCost
//
//  Created by BT-Training on 19/09/16.
//  Copyright © 2016 BT-Training. All rights reserved.
//

import UIKit

class MainHUBController: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var productsButton:   UIButton!
    @IBOutlet weak var componentsButton: UIButton!
    @IBOutlet weak var suppliersButton:  UIButton!
    @IBOutlet weak var accountButton:    UIButton!
    @IBOutlet weak var settingsButton:   UIButton!
    @IBOutlet weak var aboutbutton:      UIButton!

    // MARK: Overrides

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let buttons = [productsButton, componentsButton, suppliersButton,
                       accountButton, settingsButton, aboutbutton]
        
        for button in buttons {
            button.layer.masksToBounds = true
            button.layer.cornerRadius = button.frame.size.height / 2
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
