//
//  ComponentQuantityModal.swift
//  ProductionCost
//
//  Created by BT-Training on 22/09/16.
//  Copyright © 2016 BT-Training. All rights reserved.
//

import UIKit
import PKHUD

protocol ComponentQuantityDelegate: class {
    
    func componentQuantityDelegate(didPick quantity: Double, onMaterial material: Material)
    
}

class ComponentQuantityModal: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var oneQuarterButton: UIButton!
    @IBOutlet weak var oneHalfButton: UIButton!
    @IBOutlet weak var threeQuarterButton: UIButton!
    @IBOutlet weak var oneButton: UIButton!
    @IBOutlet weak var fiveButton: UIButton!
    @IBOutlet weak var tenButton: UIButton!
    @IBOutlet weak var packButton: UIButton!
    
    // MARK: Properties
    
    var delegate: ComponentQuantityDelegate?
    var selectedMaterial: Material!
    
    // MARK: Overrides

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        view.backgroundColor = AppColors.modalBlack
        
        let buttons = [oneQuarterButton, oneHalfButton, threeQuarterButton, oneButton,
                       fiveButton,       tenButton,     packButton]
        
        for button in buttons {
            button.round()
            button.layer.shadowColor = AppColors.white.CGColor
            button.layer.shadowOffset = CGSize(width: 2, height: 2)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Methods
    
    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func addOneQuarter(sender: AnyObject) {
        delegate?.componentQuantityDelegate(didPick: 0.25, onMaterial: selectedMaterial)
    }
    
    @IBAction func addOneHalf(sender: AnyObject) {
        delegate?.componentQuantityDelegate(didPick: 0.5, onMaterial: selectedMaterial)
    }
    
    @IBAction func addThreeQuarter(sender: AnyObject) {
        delegate?.componentQuantityDelegate(didPick: 0.75, onMaterial: selectedMaterial)
    }
    
    @IBAction func addOne(sender: AnyObject) {
        delegate?.componentQuantityDelegate(didPick: 1, onMaterial: selectedMaterial)
    }
    
    @IBAction func addFive(sender: AnyObject) {
        delegate?.componentQuantityDelegate(didPick: 5, onMaterial: selectedMaterial)
    }
    
    @IBAction func addTen(sender: AnyObject) {
        delegate?.componentQuantityDelegate(didPick: 10, onMaterial: selectedMaterial)
    }
    
    @IBAction func addPack(sender: AnyObject) {
        HUD.flash(.LabeledError(title: nil, subtitle: "Not implemented yet"), delay: 1)
    }
}
