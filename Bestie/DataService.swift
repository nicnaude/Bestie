//
//  DataService.swift
//  Bestie
//
//  Created by Michael Saltzman on 2/18/16.
//  Copyright © 2016 Nicholas Naudé. All rights reserved.
//

import Foundation
import Firebase

class DataService
{
    static let dataService = DataService()
    static let BASE_URL = "https://bestieapp.firebaseio.com"
    
    fileprivate var _BASE_REF = Firebase(url: "\(BASE_URL)")
    fileprivate var _USER_REF = Firebase(url: "\(BASE_URL)/users")
    fileprivate var _LOCATION_REF = Firebase(url: "\(BASE_URL)/users/location")
    
    var BASE_REF: Firebase {
        return _BASE_REF!
    }

    var USER_REF: Firebase {
        return _USER_REF!
    }
    
    var LOCATION_REF: Firebase {
        return _LOCATION_REF!
    }
}
