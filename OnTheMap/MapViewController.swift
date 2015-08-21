//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Marius Horga on 8/8/15.
//  Copyright © 2015 Marius Horga. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    var userID: String?
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getStudentLocations()
        activityIndicator.hidden = true
    }

    @IBAction func changeDetails(sender: UIBarButtonItem) {
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("infoVC") as! InformationViewController
        if userID != nil {
            let alert = UIAlertController(title: nil, message: "Do you want to overwrite your location data?", preferredStyle: .Alert)
            let okAlert = UIAlertAction(title: "OK", style: .Default, handler: { (UIAlertAction) -> Void in
                controller.userID = self.userID
                self.presentViewController(controller, animated: true, completion: nil)
            })
            alert.addAction(okAlert)
            let cancelAlert = UIAlertAction(title: "Cancel", style: .Default, handler: { (UIAlertAction) -> Void in
                return
            })
            alert.addAction(cancelAlert)
            self.presentViewController(alert, animated: true, completion: nil)
            return
        } else {
            controller.userID = nil
            self.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    @IBAction func logout(sender: UIBarButtonItem) {
        let task = Networking.taskForLogout()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func getStudentLocations() {
        let request = NSMutableURLRequest(URL: NSURL(string: Networking.Constants.parseURL)!)
        request.addValue("-updatedAt", forHTTPHeaderField: "order")
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                self.showAlert("Download failed.")
                return
            } else {
                let parsedResult = NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments, error: nil) as! NSDictionary
                let listTab = self.tabBarController?.viewControllers?.last as! ListTableViewController
                listTab.locations = parsedResult["results"] as! NSArray
                self.showStudentLocations(parsedResult["results"] as! NSArray)
            }
        }
        task.resume()
    }
    
    
    func showAlert(message: String) {
        let alertView = UIAlertController(title: "", message: message, preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
        alertView.addAction(action)
        self.presentViewController(alertView, animated: true, completion: nil)
    }
    
    func showStudentLocations(locations: NSArray) {
        var annotations = [MKPointAnnotation]()
        for dictionary in locations {
            let latitude = CLLocationDegrees(dictionary["latitude"] as! Double)
            let longitude = CLLocationDegrees(dictionary["longitude"] as! Double)
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let name = (dictionary["firstName"] as! String) + " " + (dictionary["lastName"] as! String)
            let mediaURL = dictionary["mediaURL"] as! String
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(name)"
            annotation.subtitle = mediaURL
            annotations.append(annotation)
        }
        dispatch_async(dispatch_get_main_queue()) {
            self.activityIndicator.hidden = false
            self.activityIndicator.startAnimating()
            self.mapView.addAnnotations(annotations)
            self.activityIndicator.stopAnimating()
            self.activityIndicator.hidden = true
        }
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseIdentifier = "pin"
        var pin = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseIdentifier) as? MKPinAnnotationView
        if pin == nil {
            pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            pin!.pinColor = .Red
            pin!.canShowCallout = true
            pin!.rightCalloutAccessoryView = UIButton.buttonWithType(UIButtonType.DetailDisclosure) as! UIButton
        } else {
            pin!.annotation = annotation
        }
        return pin
    }
    
    func mapView(mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == annotationView.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            app.openURL(NSURL(string: (annotationView.annotation!.subtitle!)!)!)
        }
    }
}
