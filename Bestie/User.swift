//
//  User.swift
//  Bestie
//
//  Created by Michael Saltzman on 2/16/16.
//  Copyright © 2016 Nicholas Naudé. All rights reserved.
//

import UIKit

class User: NSObject {
    
    var userId = String()
    var name = String()
    var profilePicture = String()
  
    
    init(userId: String, name: String, profilePicture: String) {
        self.userId = userId
        self.name = name
        self.profilePicture = profilePicture
    }
}
