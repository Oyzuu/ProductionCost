//
//  AccountController.swift
//  ProductionCost
//
//  Created by BT-Training on 28/09/16.
//  Copyright © 2016 BT-Training. All rights reserved.
//

import UIKit
import Firebase
import SkyFloatingLabelTextField

class AccountController: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var usermailLabel: UILabel!
    @IBOutlet weak var newPasswordField: SkyFloatingLabelTextField!
    @IBOutlet weak var passConfirmField: SkyFloatingLabelTextField!
    @IBOutlet weak var updateButton: UIButton!
    @IBOutlet weak var logOutButton: UIButton!
    
    // MARK: Properties
    
    var user: FIRUser!
    
    // MARK: Overrides

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        addBlurredBackground(onView: view, withStyle: .Dark)
        
        updateButton.withRoundedBorders()
        updateButton.setTitleColor(AppColors.black, forState: .Disabled)
        logOutButton.withRoundedBorders()

        usermailLabel.attributedText = getAttributedString(forMail: user.email!)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Methods
    
    @IBAction func update(sender: AnyObject) {
        if !checkPasswordFieldsValidity() {
            newPasswordField.errorMessage = "error !"
            passConfirmField.errorMessage = "error !"
            enabledUpdateButton(false, withTransition: true)
        }
    }
    
    @IBAction func logOff(sender: AnyObject) {
        try! FIRAuth.auth()!.signOut()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func cancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    private func enabledUpdateButton(isEnabled: Bool, withTransition: Bool) {
        guard updateButton.enabled != isEnabled else {
            return
        }
        
        if withTransition {
            transition(onView: updateButton, withDuration: 0.3) {
                self.updateButton.enabled         = isEnabled
                self.updateButton.backgroundColor = isEnabled ? AppColors.raspberry : AppColors.black50
            }
            
            return
        }
        
        updateButton.enabled         = isEnabled
        updateButton.backgroundColor = isEnabled ? AppColors.raspberry : AppColors.black50
    }
    
    private func checkPasswordFieldsValidity() -> Bool {
        let newPass     = newPasswordField.text?.trim()
        let confirmPass = passConfirmField.text?.trim()
        
        guard newPass != "" && confirmPass != "" else {
            print("empty fields")
            return false
        }
        
        guard newPass?.characters.count >= 6 && confirmPass?.characters.count >= 6 else {
            print("fields with less than 6 chars")
            return false
        }
        
        return true
    }
    
    private func getAttributedString(forMail mail: String) -> NSMutableAttributedString {
        let indexOfArobase   = mail.characters.indexOf("@")
        let userString       = mail.substringToIndex(indexOfArobase!)
        let domainString     = mail.substringFromIndex(indexOfArobase!)
        
        let avenirMedium17 = UIFont(name: "Avenir-Medium", size: 17)
        let avenirNextUltraLight17 = UIFont(name: "AvenirNext-UltraLight", size: 17)
        
        let attributedUser   = NSMutableAttributedString(string: userString, attributes:
            [NSFontAttributeName: avenirMedium17!])
        
        let attributedDomain = NSMutableAttributedString(string: domainString, attributes:
            [NSFontAttributeName: avenirNextUltraLight17!])
        attributedUser.appendAttributedString(attributedDomain)
        
        return attributedUser
    }

}

// MARK: EXT - Text field delegate

extension AccountController: UITextFieldDelegate {
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let textField = (textField as! SkyFloatingLabelTextField)
        
        guard textField.hasErrorMessage else {
            return true
        }
        
        transition(onView: textField, withDuration: 0.5) {
            textField.errorMessage = ""
        }
        
        if !newPasswordField.hasErrorMessage && !passConfirmField.hasErrorMessage {
            enabledUpdateButton(true, withTransition: true)
        }
        
        return true
    }
    
}
