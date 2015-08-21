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
    
    struct JSONKeys {
        static let Session = "session"
        static let Users = "users"
        static let UserID = "<user_id>"
        static let Udacity = "udacity"
        static let Username = "username"
        static let Password = "password"
        static let User = "user"
        static let Account = "account"
        static let Email = "email"
        static let LastName = "last_name"
        static let FirstName = "first_name"
        static let Registered = "registered"
        static let Key = "key"
        static let ID = "id"
        static let Expiration = "expiration"
        static let Verified = "_verified"
        static let Address = "address"
    }
    
    /* Shared session */
    var session: NSURLSession
    
    /* Configuration object */
    //var config = Networking()
    
    /* Authentication state */
    var sessionID : String? = nil
    var userID : Int? = nil
    
    // MARK: - Initialization
    
    convenience init?(dictionary: [String : AnyObject]) {
        self.init()
    }
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    // MARK: - Shared Instance
    
    class func sharedInstance() -> Networking {
        struct Singleton {
            static var sharedInstance = Networking()
        }
        return Singleton.sharedInstance
    }
    
    func loginToUdacity(user: User, completionHandler: (success: Bool, returnKey: String?, errorString: String?) -> Void) {
        let task = taskForUdacity(user) { JSONResult, error in
            if let error = error {
                completionHandler(success: false, returnKey: "none", errorString: "No connection available.")
            } else {
                if let result = JSONResult.valueForKey(JSONKeys.Account) as? NSDictionary {
                    if let isRegistered = result.valueForKey(JSONKeys.Registered) as? Bool {
                        var localKey = result.valueForKey(JSONKeys.Key) as! String
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
            if let error = downloadError {
                let newError = NSError(domain: "OnTheMap Error", code: 1, userInfo: nil)
                completionHandler(result: nil, error: downloadError)
            } else {
                let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
                self.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
            }
        }
        task.resume()
        return task
    }
    
    class func taskForLogout() -> NSURLSessionDataTask {
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "DELETE"
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie as? NSHTTPCookie }
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
    
    func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        var parsingError: NSError? = nil
        let parsedResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &parsingError)
        if let error = parsingError {
            completionHandler(result: nil, error: error)
        } else {
            completionHandler(result: parsedResult, error: nil)
        }
    }
}
