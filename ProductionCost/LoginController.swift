//
//  LoginController.swift
//  ProductionCost
//
//  Created by BT-Training on 21/09/16.
//  Copyright © 2016 BT-Training. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import Firebase
import PKHUD

class LoginController: UIViewController {
    
    // MARK: Outlets

    @IBOutlet weak var signInButton:  UIButton!
    @IBOutlet weak var signUpButton:  UIButton!
    @IBOutlet weak var backButton:    UIButton!
    @IBOutlet weak var mailField:     SkyFloatingLabelTextField!
    @IBOutlet weak var passwordField: SkyFloatingLabelTextField!
    
    // MARK: Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        view.backgroundColor = UIColor.clearColor()
        addBlurredBackground(onView: self.view, withStyle: .Dark)
        
        signInButton.layer.cornerRadius = 5
        signUpButton.layer.cornerRadius = 5
        signUpButton.layer.borderWidth  = 1
        signUpButton.layer.borderColor  = AppColors.raspberry.CGColor
        backButton.layer.cornerRadius   = 5
        mailField.becomeFirstResponder()
        mailField.delegate     = self
        passwordField.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Methods

    @IBAction func backToHub(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func signIn(sender: AnyObject) {
        view.endEditing(true)
        
        guard let mail = mailField.text, password = passwordField.text else {
            return
        }
        
        FIRAuth.auth()?.signInWithEmail(mail, password: password) { user, error in
            self.firebaseValidation(forUser: user, withError: error,
                                    withSuccessMessage: "Successfully logged in")
        }
    }
    
    @IBAction func signUp(sender: AnyObject) {
        view.endEditing(true)
        
        guard let mail = mailField.text, password = passwordField.text else {
            return
        }
        
        FIRAuth.auth()?.createUserWithEmail(mail, password: password) { user, error in
            self.firebaseValidation(forUser: user, withError: error,
                                    withSuccessMessage: "Successfully signed in")
        }
    }
    
    private func firebaseValidation(forUser user: FIRUser?, withError error: NSError?,
                                            withSuccessMessage successMessage: String) {
        print("User : \(user?.email!)")
        if error != nil {
            print(error)
            
            var message = ""
            
            switch error!.code {
            case 17007:
                message = error!.localizedDescription
                self.mailField.errorMessage = "Already in use"
            case 17008:
                message = error!.localizedDescription
                self.mailField.errorMessage = "Wrong mail format"
            case 17009:
                message = "Wrong password"
                self.passwordField.errorMessage = "Wrong password"
            case 17011:
                message = "Mail not registered"
                self.mailField.errorMessage = "Mail not registered"
            case 17026:
                message = error!.localizedDescription
                self.passwordField.errorMessage = "Password too short"
            case 17999:
                print(mailField.text)
                print(passwordField.text)
                
                if self.mailField.text! == "" {
                    message = "Wrong user mail"
                    self.mailField.errorMessage = "No mail"
                }
                else {
                    message = "Please enter a password"
                    self.passwordField.errorMessage = "No password"
                }
                
            default: message = error!.localizedDescription
            }
            
            HUD.flash(.LabeledError(title: nil, subtitle: message), delay: 1)
        }
        else {
            HUD.flash(.LabeledSuccess(title: nil, subtitle: successMessage), delay: 0.5)
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
}

// MARK: EXT - Text field delegate

extension LoginController: UITextFieldDelegate {
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let textField = (textField as! SkyFloatingLabelTextField)
        
        guard textField.hasErrorMessage else {
            return true
        }
        
        transition(onView: textField, withDuration: 0.5) {
            textField.errorMessage = ""
        }
        
        return true
    }
    
}
