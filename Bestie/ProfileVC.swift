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
    
    @IBOutlet weak var profilePictureImage: UIImageView!
 //   @IBOutlet weak var profilePictureImage: UIButton!
    @IBOutlet weak var userFirstNameTextLabel: UILabel!
    @IBOutlet weak var userPrincessPointsTextLabel: UILabel!
    @IBOutlet weak var userBioTextView: UITextView!
    @IBOutlet weak var chatButton: UIButton!
    @IBOutlet weak var princessPointButton: UIButton!
    
    var currentUser = [User]()
    var ref = Firebase(url: "https://bestieapp.firebaseio.com/")
    var defaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        chatButton.hidden = true
        
        
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
            
            let url = NSURL(string: profilePictureURL)
            let session = NSURLSession.sharedSession()
            
            let task = session.dataTaskWithURL(url!) { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                    self.profilePictureImage.layoutSubviews()
                    // self.profilePictureImage.imageView?.image = UIImage(named: "profileimage")
                    
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
    
    
    
    
    @IBAction func onGivePrincessPointsTapped(sender: AnyObject) {
        chatButton.hidden = false
        princessPointButton.hidden = true
    }
    
    @IBAction func onChatTapped(sender: AnyObject) {
        
    }
    
}
