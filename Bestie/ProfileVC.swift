//
//  ProfileVC.swift
//  Bestie
//
//  Created by Nicholas Naudé on 15/02/2016.
//  Copyright © 2016 Nicholas Naudé. All rights reserved.
//

import UIKit
import Firebase

class ProfileVC: UIViewController {

    @IBOutlet weak var userPictureImageView: UIImageView!
    @IBOutlet weak var userFirstNameTextLabel: UILabel!
    @IBOutlet weak var userPrincessPointsTextLabel: UILabel!
    @IBOutlet weak var userBioTextView: UITextView!
    
    // this creates a connection to Firebase.
    let rootRef = Firebase(url: "https://bestieapp.firebaseio.com")

    // create child ref
    let childRef = Firebase(url: "https://bestieapp.firebaseio.com/")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // send a test to fireBase to see if it works!
        rootRef.setValue("Hello, Firebase totally works.")
        
        rootRef.observeEventType(.Value, withBlock: {snapshot in
            let message = snapshot.value as! String
//            self.headerTextLabel.text = message
        })
    }
    
    @IBAction func onGivePrincessPointsTapped(sender: AnyObject) {
    }

    @IBAction func onChatTapped(sender: AnyObject) {
    }
}
