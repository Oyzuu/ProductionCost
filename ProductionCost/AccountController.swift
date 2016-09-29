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
import PKHUD

class AccountController: UIViewController {
    
    // MARK: Outlets
    
    @IBOutlet weak var helloLabel: UILabel!
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

        usermailLabel.attributedText = getAttributedString(forMail: user.email!, ofSize: 17)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        transition(onView: helloLabel, withDuration: 0.5) {
            self.helloLabel.hidden = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Methods
    
    @IBAction func update(sender: AnyObject) {
        view.endEditing(true)
        
        guard checkPasswordFieldsValidity() else {
            enabledUpdateButton(false, withTransition: true)
            return
        }
        
        user.updatePassword(passConfirmField.text!) { error in
            
            if let error = error {
                print(error.localizedDescription)
                HUD.flash(.LabeledError(title: nil, subtitle: "Please log in again and retry"), delay: 1)
            }
            else {
                HUD.flash(.LabeledSuccess(title: nil, subtitle: "Your password has been updated"),
                          delay: 0.5)
            }
        }
        
        newPasswordField.text = ""
        passConfirmField.text = ""
    }
    
    @IBAction func logOff(sender: AnyObject) {
        view.endEditing(true)
        
        do {
            try FIRAuth.auth()!.signOut()
            HUD.flash(.LabeledSuccess(title: nil, subtitle: "Sign out"),
                      delay: 0.5)
        }
        catch {
            HUD.flash(.LabeledError(title: nil, subtitle: "\(error)"), delay: 1)
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func cancel(sender: AnyObject) {
        view.endEditing(true)
        
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
        
        guard newPass != "" || confirmPass != "" else {
            newPasswordField.errorMessage = newPass     == "" ? "Empty field" : nil
            passConfirmField.errorMessage = confirmPass == "" ? "Empty field" : nil
            return false
        }
        
        guard newPass != "" else {
            newPasswordField.errorMessage = "Empty field"
            return false
        }
        
        guard confirmPass != "" else {
            passConfirmField.errorMessage = "Empty field"
            return false
        }
        
        guard newPass?.characters.count >= 6 else {
            newPasswordField.errorMessage = "password is too short"
            return false
        }
        
        guard newPass == confirmPass else {
            passConfirmField.errorMessage = "confirmation is different"
            return false
        }
        
        return true
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
