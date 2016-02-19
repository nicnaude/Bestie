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
    
    var currentUser = [User]()
    var ref = Firebase(url: "https://bestieapp.firebaseio.com/")
    var defaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let uidName = self.defaults.valueForKey("User ID")
        
        fetchUserInformation(uidName! as! String)
    }
    
    func fetchUserInformation(userID:String) {
        
        let userRef = ref.childByAppendingPath("/users")
        userRef.queryOrderedByChild("facebookID").queryEqualToValue(userID).observeSingleEventOfType(.Value, withBlock: { snapshot in
            print(snapshot)
            guard let value = snapshot.value as? [NSObject: AnyObject], user = value[userID] as? [NSObject: AnyObject] else { return }
            let userName = user["name"] as? String ?? "It isn't working"
            
            let profilePictureURL = user["profilePictureURL"] as? String ?? "It isn't working"
            
            let completeUser = User(userId: userID, name: userName, profilePicture: profilePictureURL)//latitude: defaults.objectForKey("Saved Location"))
            self.userFirstNameTextLabel.text = completeUser.name
            }
        )
    }
    
    @IBAction func onGivePrincessPointsTapped(sender: AnyObject) {
    }
    
    @IBAction func onChatTapped(sender: AnyObject) {
    }
}
