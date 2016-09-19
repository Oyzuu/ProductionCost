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
        let font    = UIFont.fontAwesomeOfSize(20)
        let buttons = [productsButton:   String.fontAwesomeIconWithName(.Cubes),
                       componentsButton: String.fontAwesomeIconWithName(.Cube),
                       suppliersButton:  String.fontAwesomeIconWithName(.Truck),
                       accountButton:    String.fontAwesomeIconWithName(.User),
                       settingsButton:   String.fontAwesomeIconWithName(.Gears),
                       aboutbutton:      String.fontAwesomeIconWithName(.Info)]
        
        for (button, icon) in buttons {
            button.layer.masksToBounds = true
            button.layer.cornerRadius = button.frame.size.height / 2
            button.titleLabel?.font = font
            button.setTitleColor(AppColors.white, forState: .Normal)
            button.setTitle(icon, forState: .Normal)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
