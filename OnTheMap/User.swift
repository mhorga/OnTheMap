//
//  User.swift
//  OnTheMap
//
//  Created by Marius Horga on 8/21/15.
//  Copyright (c) 2015 Marius Horga. All rights reserved.
//

import Foundation

struct User {
    var username = ""
    var password = ""
    var userID = ""
    var firstName = ""
    var lastName = ""
    var mapString = ""
    var mediaURL = ""
    var latitude = 0.0
    var longitude = 0.0
    
    init() {
    }
    
    init(credentials: NSDictionary) {
        username = credentials["username"] as! String
        password = credentials["password"] as! String
    }
}