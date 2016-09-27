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
        
        addBlurredBackground(onView: self.view, withStyle: .Dark)
        
        signInButton.withRoundedBorders()
        signUpButton.withRoundedBorders()
        signUpButton.layer.borderWidth  = 1
        signUpButton.layer.borderColor  = AppColors.raspberry.CGColor
        backButton.withRoundedBorders()
        
        self.mailField.becomeFirstResponder()
        
        mailField.delegate     = self
        passwordField.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Methods

    @IBAction func backToHub(sender: AnyObject) {
        view.endEditing(true)
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
            switch error!.code {
            case 17007:
                setErrorWithFeedback(mailField, hudMessage: error!.localizedDescription,
                                     errorMessage: "Already in use")
            case 17008:
                setErrorWithFeedback(mailField, hudMessage: error!.localizedDescription,
                                     errorMessage: "Wrong mail format")
            case 17009:
                setErrorWithFeedback(passwordField, hudMessage: "Wrong password",
                                     errorMessage: "Wrong password")
            case 17011:
                setErrorWithFeedback(mailField, hudMessage: "Mail not registered",
                                     errorMessage: "Mail not registered")
            case 17026:
                setErrorWithFeedback(passwordField, hudMessage: error!.localizedDescription,
                                     errorMessage: "Password too short")
            case 17999:
                if self.mailField.text! == "" {
                    setErrorWithFeedback(mailField, hudMessage: "Please enter a mail",
                                         errorMessage: "No mail")
                }
                else {
                    setErrorWithFeedback(passwordField, hudMessage: "Please enter a password",
                                         errorMessage: "No password")
                }
                
            default:
                HUD.flash(.LabeledError(title: nil, subtitle: error!.localizedDescription), delay: 1)
            }
        }
        else {
            HUD.flash(.LabeledSuccess(title: nil, subtitle: successMessage), delay: 0.5)
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    private func setErrorWithFeedback(field: UITextField, hudMessage: String, errorMessage: String) {
        (field as! SkyFloatingLabelTextField).errorMessage = errorMessage
        
        HUD.flash(.LabeledError(title: nil, subtitle: hudMessage), delay: 1) { result in
            field.shake()
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
