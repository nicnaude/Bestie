//
//  MainFeedVC.swift
//  Bestie
//
//  Created by Nicholas Naudé and Michael Saltzman on 13/02/2016.
//  Copyright © 2016 Nicholas Naudé and Michael Saltzman. All rights reserved.
//

import UIKit
import Firebase

class MainfeedVC: UIViewController {
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    // this creates a connection to Firebase.
    let ref = Firebase(url: "https://bestieapp.firebaseio.com/users/uid/name/")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (defaults.objectForKey("User ID") == nil){
            performSegueWithIdentifier("signUpVC", sender: nil)
        } else {
            print("MAIN FEED VC: The user is logged in.")
            return
        }
    }
    
    // MARK: - TableViewControllers
    
} // end of VC
