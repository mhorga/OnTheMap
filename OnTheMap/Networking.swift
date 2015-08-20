//
//  Networking.swift
//  OnTheMap
//
//  Created by Marius Horga on 8/20/15.
//  Copyright (c) 2015 Marius Horga. All rights reserved.
//

import UIKit

class Networking {
    
    func login(username: String, password: String, completionHandler: (AnyObject) -> Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            completionHandler
        }
        task.resume()
    }
}