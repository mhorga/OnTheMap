//
//  ListTableViewController.swift
//  OnTheMap
//
//  Created by Marius Horga on 8/8/15.
//  Copyright © 2015 Marius Horga. All rights reserved.
//

import UIKit

class ListTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var userID: String?
    var locations = []
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        tableView.reloadData()
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
        _ = Networking.taskForLogout()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell")! as UITableViewCell
        let location = locations[indexPath.row] as! NSDictionary
        let firstName = location.valueForKey("firstName") as! String
        let lastName = location.valueForKey("lastName") as! String
        cell.textLabel!.text = "\(firstName) \(lastName)"
        cell.imageView!.image = UIImage(named: "pin")
        return cell
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let app = UIApplication.sharedApplication()
        let location = locations[indexPath.row] as! NSDictionary
        let urlString = location.valueForKey("mediaURL") as? String
        if let url = NSURL(string: urlString!) {
            app.openURL(url)
        }
    }
}
