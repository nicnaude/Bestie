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
        //        let nameFBUrl = ref.childByAppendingPath("users").childByAppendingPath(uidName! as! String).childByAppendingPath("name")
        //        let nameURLString = String(format:"%@.json", nameFBUrl.description)
        //        let nameURL = NSURL(string: nameURLString)
        //        let session = NSURLSession.sharedSession()
        //        let task = session.dataTaskWithURL(nameURL!) { (data, response, error) -> Void in
        //            do {
        //                let nameString = try NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as! String
        //                self.userFirstNameTextLabel.text = nameString
        //            } catch let error as NSError {
        //                print(error)
        //            }
        //        }
        //        task.resume()
    } // END OF VIEW DID LOAD
    
    func fetchUserInformation(userID:String) {
        
        let userRef = ref.childByAppendingPath("/users")
        userRef.queryOrderedByChild("facebookID").queryEqualToValue(userID).observeEventType(.Value, withBlock: { snapshot in
            guard let value = snapshot.value as? [NSObject: AnyObject], user = value[userID] as? [NSObject: AnyObject] else { return }
            let userName = user["name"] as? String ?? "It isn't working"
            
            let profilePictureURL = user["profilePictureURL"] as? String ?? "It isn't working"
            
            let completeUser = User(userId: userID, name: userName, profilePicture: profilePictureURL)
            self.userFirstNameTextLabel.text = completeUser.name
            }
        )
        
        /* userRef.queryOrderedByChild("name").queryEqualToValue(userID).observeSingleEventOfType(.Value, withBlock: { snapshot in
        //            let uid = snapshot.key as String
        //            let userName = snapshot.value ["name"] as! String
        //            let profilePictureURL = snapshot.value ["profilePictureURL"] as! String
        //
        //            let completeUser = User(userId: uid, name: userName, profilePicture: profilePictureURL)
        //dispatch to main queue
        self.userFirstNameTextLabel.text = snapshot.value ["name"] as? String
        }
        )*/
    }
    
    @IBAction func onGivePrincessPointsTapped(sender: AnyObject) {
    }
    
    @IBAction func onChatTapped(sender: AnyObject) {
    }
}
