//
//  User.swift
//  Bestie
//
//  Created by Michael Saltzman on 2/16/16.
//  Copyright © 2016 Nicholas Naudé. All rights reserved.
//

import UIKit
import MapKit

class User: NSObject {
    
    var userId : String
    var name : String
    var profilePicture : String
    var gender : String
    var location : CLLocation
    var bio : String
    //var princessPoint : Int
  
    
    init(userId: String, name: String, profilePicture: String, gender: String, latitude: Double, longitude: Double, bio: String) { //princessPoint: Int) {
        self.userId = userId
        self.name = name
        self.profilePicture = profilePicture
        self.gender = gender
        self.location = CLLocation(latitude: latitude, longitude: longitude)
        self.bio = bio
        //self.princessPoint = princessPoint
    }
}
