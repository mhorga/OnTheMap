//
//  InformationViewController.swift
//  OnTheMap
//
//  Created by Marius Horga on 8/14/15.
//  Copyright © 2015 Marius Horga. All rights reserved.
//

import UIKit
import MapKit

class InformationViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var whereStudyLabel: UILabel!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var whereView: UIView!
    @IBOutlet weak var urlView: UIView!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var findButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var userID: String?
    var firstName: String?
    var lastName: String?
    //var user: User?
    
    override func viewDidLoad() {
        locationTextField.delegate = self
        urlTextField.delegate = self
        getUserData(userID!)
        urlView.hidden = true
        submitButton.hidden = true
        mapView.hidden = true
        activityIndicator.hidden = true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.endEditing(true)
    }
    
    func showAlert(message: String) {
        let alertView = UIAlertController(title: "", message: message, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        alertView.addAction(action)
        self.presentViewController(alertView, animated: true, completion: nil)
    }
    
    @IBAction func findOnTheMap(sender: UIButton) {
        self.activityIndicator.hidden = false
        self.activityIndicator.startAnimating()
        if self.mapView.annotations.count != 0 {
            let annotation = self.mapView.annotations[0] as! MKAnnotation
            self.mapView.removeAnnotation(annotation)
        }
        let localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = self.locationTextField.text
        let localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.startWithCompletionHandler { (response, error) -> Void in
            if let latitude = response?.boundingRegion.center.latitude, longitude = response?.boundingRegion.center.longitude {
                let pointAnnotation = MKPointAnnotation()
                pointAnnotation.title = self.locationTextField.text
                pointAnnotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                let pinAnnotationView = MKPinAnnotationView(annotation: pointAnnotation, reuseIdentifier: nil)
                self.mapView.centerCoordinate = pointAnnotation.coordinate
                self.mapView.addAnnotation(pinAnnotationView.annotation!)
                if latitude != 0.0 && longitude != 0.0 {
                    self.urlView.hidden = false
                    self.submitButton.hidden = false
                    self.mapView.hidden = false
                    self.whereStudyLabel.hidden = true
                    self.whereView.hidden = true
                    self.findButton.hidden = true
                }
                self.activityIndicator.stopAnimating()
                self.activityIndicator.hidden = true
            }
            else {
                self.showAlert("Cannot locate search query.")
                self.activityIndicator.stopAnimating()
                self.activityIndicator.hidden = true
                return
            }
        }
    }
    
    @IBAction func submit(sender: UIButton) {
        if urlTextField.text?.rangeOfString("http://") != nil {
            updateLocation()
            dismissViewControllerAnimated(true, completion: nil)
        } else {
            self.showAlert("Use http:// in front of your URL.")
            return
        }
    }
    
    @IBAction func cancel(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func updateLocation() {
        let localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = self.locationTextField.text
        let localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.startWithCompletionHandler { (response, error) -> Void in
            if let latitude = response?.boundingRegion.center.latitude, longitude = response?.boundingRegion.center.longitude {
                var user = User()
                //let details = ["uniqueKey": self.userID!, "firstName": self.firstName!, "lastName": self.lastName!, "mapString": self.locationTextField.text!, "mediaURL": self.urlTextField.text!, "latitude": latitude, "longitude": longitude]
                user.userID = self.userID!
                user.firstName = self.firstName!
                user.lastName = self.lastName!
                user.mapString = self.locationTextField.text!
                user.mediaURL = self.urlTextField.text!
                user.latitude = latitude
                user.longitude = longitude
                let task = Networking.taskForUpdateLocation(user, completionHandler: { (result, error) -> Void in
                    if error != nil {
                        self.showAlert(error!.localizedDescription)
                        return
                    }
                })
                task.resume()
            }
        }
    }
    
    func getUserData(userID: String) {
        let task = Networking.taskForGetUserData(userID) { (result, error) -> Void in
            if error != nil {
                self.showAlert(error!.localizedDescription)
                return
            } else {
                let dictionary = result as! NSDictionary
                if dictionary["user"] != nil {
                    if let first = dictionary["user"]!["first_name"]! as? String, last = dictionary["user"]!["last_name"]! as? String {
                        self.firstName = first
                        self.lastName = last
                    }
                }
            }
        }
        task.resume()
    }
}
