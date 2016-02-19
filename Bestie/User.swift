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
    //var location : CLLocation
  
    
    init(userId: String, name: String, profilePicture: String) {//, latitude: Double, longitude: Double)
        self.userId = userId
        self.name = name
        self.profilePicture = profilePicture
        //self.location = CLLocation(latitude: latitude, longitude: longitude)
    }
}
