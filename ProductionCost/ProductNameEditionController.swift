//
//  ProductNameEditionController.swift
//  ProductionCost
//
//  Created by BT-Training on 20/09/16.
//  Copyright © 2016 BT-Training. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField

protocol ProductNameEditionDelegate: class {
    
    func productNameEditionDelegate(didCancel controller: ProductNameEditionController)
    func productNameEditionDelegate(didFinishEditing name: String)
    
}

class ProductNameEditionController: UIViewController {

    // MARK: Outlets
    
    @IBOutlet weak var nameField: SkyFloatingLabelTextField!
    @IBOutlet weak var okButton: UIButton!
    
    // MARK: Properties
    
    var nameToEdit: String?
    var delegate: ProductNameEditionDelegate?
    
    // MARK: Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameField.becomeFirstResponder()
        if let nameToEdit = self.nameToEdit {
            nameField.text = nameToEdit
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        view.backgroundColor = UIColor.clearColor()
        addBlurredBackground(onView: self.view, withStyle: .Dark)
        okButton.layer.cornerRadius = okButton.frame.size.height / 2
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Methods
    
    @IBAction func cancel(sender: AnyObject) {
        view.endEditing(true)
        
        delegate?.productNameEditionDelegate(didCancel: self)
    }
    
    @IBAction func validate(sender: AnyObject) {
        view.endEditing(true)
        
        guard nameField.text != "" else {
            nameField.shake()
            return
        }
        
        if let nameString = nameField.text {
            delegate?.productNameEditionDelegate(didFinishEditing: nameString)
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
}
