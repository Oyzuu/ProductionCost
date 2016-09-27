//
//  QuantityEditor.swift
//  ProductionCost
//
//  Created by BT-Training on 27/09/16.
//  Copyright © 2016 BT-Training. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField

protocol QuantityEditorDelegate: class {
    func quantityEditorDelegate(didEditQuantity: String, onComponent: MaterialWithModifier)
}

class QuantityEditor: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var quantityField: SkyFloatingLabelTextField!
    @IBOutlet weak var okButton: UIButton!
    
    // MARK: Properties
    
    var componentToEdit: MaterialWithModifier!
    var delegate: QuantityEditorDelegate!
    
    // MARK: Overrides

    override func viewDidLoad() {
        super.viewDidLoad()
        quantityField.becomeFirstResponder()
        quantityField.text = "\((componentToEdit.material?.quantity)! * componentToEdit.modifier)"
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        addBlurredBackground(onView: view, withStyle: .Dark)
        okButton.withRoundedBorders()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Methods
    
    @IBAction func validate(sender: AnyObject) {
        view.endEditing(true)
        
        guard quantityField.text?.trim() != "" else {
            quantityField.shake()
            return
        }
        
        delegate.quantityEditorDelegate(quantityField.text!.trim(), onComponent: componentToEdit)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func cancel(sender: AnyObject) {
        view.endEditing(true)
        dismissViewControllerAnimated(true, completion: nil)
    }
}
