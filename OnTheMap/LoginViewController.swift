//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Marius Horga on 8/7/15.
//  Copyright © 2015 Marius Horga. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var user =  User()
    
    @IBAction func loginButton(sender: UIButton) {
        user.username = emailTextField.text
        user.password = passwordTextField.text
        Networking.sharedInstance().loginToUdacity(user) { (success, returnKey, errorString) in
            if errorString != nil {
                dispatch_async(dispatch_get_main_queue(), {
                    self.showAlert(errorString!)
                })
            } else {
                if success {
                    self.user.userID = returnKey!
                    dispatch_async(dispatch_get_main_queue(), {
                        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("tabBar") as! UITabBarController
                        let mapVC = controller.customizableViewControllers?.first as! MapViewController
                        mapVC.userID = self.user.userID
                        let listTVC = controller.customizableViewControllers?.last as! ListTableViewController
                        listTVC.userID = self.user.userID
                        self.presentViewController(controller, animated: true, completion: nil)
                    })
                } else {
                    dispatch_async(dispatch_get_main_queue(), {
                        self.showAlert(errorString!)
                    })
                }
            }
        }
        emailTextField.text = nil
        passwordTextField.text = nil
    }
    
    @IBAction func signUpButton(sender: UIButton) {
        UIApplication.sharedApplication().openURL(NSURL(string: Networking.Constants.udacitySignUpURL)!)
    }
    
    @IBAction func facebookButton(sender: UIButton) {
    }
    
    func showAlert(message: String) {
        let alertView = UIAlertController(title: "", message: message, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        alertView.addAction(action)
        self.presentViewController(alertView, animated: true, completion: nil)
    }
}
