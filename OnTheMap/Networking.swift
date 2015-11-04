//
//  Networking.swift
//  OnTheMap
//
//  Created by Marius Horga on 8/20/15.
//  Copyright (c) 2015 Marius Horga. All rights reserved.
//

import UIKit

class Networking: NSObject {
    
    struct Constants {
        static let parseURL: String = "https://api.parse.com/1/classes/StudentLocation?limit=100"
        static let udacityURL: String = "https://www.udacity.com/api/session"
        static let udacitySignUpURL: String = "https://www.udacity.com/account/auth#!/signup"
    }
    
    var session: NSURLSession
    static let sharedInstance = Networking() // Singleton
    
    convenience init?(dictionary: [String : AnyObject]) {
        self.init()
    }
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    func loginToUdacity(user: User, completionHandler: (success: Bool, returnKey: String?, errorString: String?) -> Void) {
        let task = taskForUdacity(user) { result, error in
            if let _ = error {
                completionHandler(success: false, returnKey: "none", errorString: "No connection available.")
            } else {
                if let result = result.valueForKey("account") as? NSDictionary {
                    if let _ = result.valueForKey("registered") as? Bool {
                        let localKey = result.valueForKey("key") as! String
                        completionHandler(success: true, returnKey: localKey, errorString: nil)
                    }
                } else {
                    completionHandler(success: false, returnKey: "none", errorString: "Wrong username or password.")
                }
            }
        }
        task.resume()
    }
    
    func taskForUdacity(user: User, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        let url = NSURL(string: Constants.udacityURL)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"udacity\": {\"username\": \"\(user.username)\", \"password\": \"\(user.password)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
        let task = self.session.dataTaskWithRequest(request) {data, response, downloadError in
            if let _ = downloadError {
                completionHandler(result: nil, error: downloadError)
            } else {
                let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5))
                let parsingError: NSError? = nil
                let parsedResult: AnyObject?
                do {
                     parsedResult = try NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments)
                    if let error = parsingError {
                        completionHandler(result: nil, error: error)
                    } else {
                        completionHandler(result: parsedResult, error: nil)
                    }
                } catch let error {
                    print(error)
                }
            }
        }
        task.resume()
        return task
    }
    
    class func taskForGetStudentLocations(completionHandler: (data: [[String: AnyObject]]?, errorString: String?) -> Void) {
        let url = NSURL(string: Constants.parseURL)!
        let request = NSMutableURLRequest(URL: url)
        request.addValue("-updatedAt", forHTTPHeaderField: "order")
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                completionHandler(data: nil, errorString: error!.localizedDescription)
                return
            }
            let parsingError: NSError? = nil
            do {
                if let parsedData = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as? [String: AnyObject] {
                    if parsingError == nil {
                        if let students = parsedData["results"] as? [[String: AnyObject]]{
                            completionHandler(data: students, errorString: nil)
                        } else {
                            if let errorResults = parsedData["error"] as? String{
                                completionHandler(data: nil, errorString: "\(errorResults): validate keys")
                            } else {
                                completionHandler(data: nil, errorString: "Unable to load students data")
                            }
                        }
                    } else {
                        completionHandler(data: nil, errorString: error!.localizedDescription)
                    }
                } else {
                    completionHandler(data: nil, errorString: "Unable to parse data")
                }
            } catch _ {
                print("Error")
            }
        }
        task.resume()
    }
    
    class func taskForLogout() -> NSURLSessionDataTask {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "DELETE"
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                print(error!)
                return
            }
        }
        task.resume()
        return task
    }
    
    class func taskForUpdateLocation(user: User, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://api.parse.com/1/classes/StudentLocation")!)
        request.HTTPMethod = "POST"
        request.addValue("QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr", forHTTPHeaderField: "X-Parse-Application-Id")
        request.addValue("QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY", forHTTPHeaderField: "X-Parse-REST-API-Key")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = "{\"uniqueKey\": \"\(user.userID)\", \"firstName\": \"\(user.firstName)\", \"lastName\": \"\(user.lastName)\",\"mapString\": \"\(user.mapString)\", \"mediaURL\": \"\(user.mediaURL)\",\"latitude\": \(user.latitude), \"longitude\": \(user.longitude)}".dataUsingEncoding(NSUTF8StringEncoding)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                completionHandler(result: nil, error: error)
                return
            }
        }
        task.resume()
        return task
    }
    
    class func taskForGetUserData(userID: String, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        let url = "https://www.udacity.com/api/users/\(userID)"
        let request = NSMutableURLRequest(URL: NSURL(string: url)!)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if let error = error {
                completionHandler(result: nil, error: error)
            } else {
                let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) // subset response data!
                let parsedResult: NSDictionary?
                do {
                    parsedResult = try NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments) as? NSDictionary
                    completionHandler(result: parsedResult, error: nil)
                } catch _ {
                    print("Error")
                }
            }
        }
        task.resume()
        return task
    }
}
