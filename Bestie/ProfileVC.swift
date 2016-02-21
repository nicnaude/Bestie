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
    
    // MARK: Outlets
    @IBOutlet weak var profilePictureImage: UIImageView!
    @IBOutlet weak var userFirstNameTextLabel: UILabel!
    @IBOutlet weak var userPrincessPointsTextLabel: UILabel!
    @IBOutlet weak var userBioTextView: UITextView!
    @IBOutlet weak var chatButton: UIButton!
    @IBOutlet weak var princessPointButton: UIButton!
    
    // MARK: Variables
    var ref = Firebase(url: "https://bestieapp.firebaseio.com/")
    var defaults = NSUserDefaults.standardUserDefaults()
    var selectedUserId = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chatButton.hidden = true
        
        fetchUserInformation(selectedUserId)
    }
    
    // MARK: Actions
    @IBAction func onGivePrincessPointsTapped(sender: AnyObject) {
        chatButton.hidden = false
        princessPointButton.hidden = true
    }
    
    @IBAction func onChatTapped(sender: AnyObject) {
        
    }
    
//    func givePrincessPoint() {
//        
//        let userRef = ref.childByAppendingPath("/users")
//        // push user data to Firebase
//        let provider = authData.provider
//        let uid = FBSDKAccessToken.currentAccessToken().userID
//        self.defaults.setObject(uid, forKey:"User ID")
//        let facebookID = authData.providerData["id"] as! String
//        let name = authData.providerData["displayName"] as! String
//        let profilePictureURL = authData.providerData["profileImageURL"] as! String
//        let gender = "gender"
//        let location = 1.1
//        let value = ["provider":provider, "facebookID": facebookID, "name":name, "profilePictureURL":profilePictureURL, "gender": gender, "location": location]
//        
//        ref.childByAppendingPath("/users/\(uid)").setValue(value)
//
//        
//        
//        
//    }
    
    
    
    
    // MARK: Firebase Functions
    func fetchUserInformation(userID:String) {
        
        let userRef = ref.childByAppendingPath("/users")
        userRef.queryOrderedByChild("facebookID").queryEqualToValue(selectedUserId).observeSingleEventOfType(.Value, withBlock: { snapshot in
            guard let value = snapshot.value as? [NSObject: AnyObject], user = value[userID] as? [NSObject: AnyObject] else { return }
            
            let userName = user["name"] as? String ?? "It isn't working"
            self.userFirstNameTextLabel.text = userName
        
            
            let profilePictureURL = user["profilePictureURL"] as? String ?? "It isn't working"
            let url = NSURL(string: profilePictureURL)
            let session = NSURLSession.sharedSession()
            let task = session.dataTaskWithURL(url!) { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    self.profilePictureImage.layer.borderWidth = 1.0
                    self.profilePictureImage.layer.masksToBounds = false
                    self.profilePictureImage.layer.borderColor = UIColor.whiteColor().CGColor
                    self.profilePictureImage.layer.cornerRadius = self.profilePictureImage.frame.size.width/2
                    self.profilePictureImage.clipsToBounds = true
                    self.profilePictureImage.image = UIImage(data: data!)
                    }
                )}
            task.resume()
            }
        )}
}
