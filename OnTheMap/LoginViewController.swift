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
    
    var userID: String? = nil
    var sessionID: String? = nil
    
    @IBAction func loginButton(sender: UIButton) {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"udacity\": {\"username\": \"\(emailTextField.text!)\", \"password\": \"\(passwordTextField.text!)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                dispatch_async(dispatch_get_main_queue()) {
                    let alertView = UIAlertController(title: "", message: "Failed network connection.", preferredStyle: UIAlertControllerStyle.Alert)
                    let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
                    alertView.addAction(action)
                    self.presentViewController(alertView, animated: true, completion: nil)
                }
                return
            } else {
                let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
                let parsedResult = NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments, error: nil) as! NSDictionary
                if parsedResult["account"] != nil {
                    if let registered = parsedResult["account"]!["registered"] as? Int {
                        if registered == 1 {
                            self.userID = parsedResult["account"]!["key"] as? String
                            self.sessionID = parsedResult["session"]!["id"] as? String
                        }
                    }
                    dispatch_async(dispatch_get_main_queue()) {
                        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("tabBar") as! UITabBarController
                        let mapVC = controller.customizableViewControllers?.first as! MapViewController
                        mapVC.userID = self.userID
                        let listTVC = controller.customizableViewControllers?.last as! ListTableViewController
                        listTVC.userID = self.userID
                        self.presentViewController(controller, animated: true, completion: nil)
                    }
                } else {
                    dispatch_async(dispatch_get_main_queue()) {
                        let alertView = UIAlertController(title: "", message: "Invalid email or password.", preferredStyle: UIAlertControllerStyle.Alert)
                        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
                        alertView.addAction(action)
                        self.presentViewController(alertView, animated: true, completion: nil)
                    }
                }
            }
        }
        task.resume()
        self.emailTextField.text = nil
        self.passwordTextField.text = nil
    }
    
    @IBAction func signUpButton(sender: UIButton) {
        let url = NSURL(string: "https://www.udacity.com/account/auth#!/signup")
        UIApplication.sharedApplication().openURL(url!)
    }
    
    @IBAction func facebookButton(sender: UIButton) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
