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
    var ref = Firebase(url: "https://bestieapp.firebaseio.com")
    
    var defaults = NSUserDefaults.standardUserDefaults()
    var selectedUserId = String()
    var princessPointCount = UInt()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        disableBioTextView()
        disableUserProfileButtons()
        fetchUserInformation(selectedUserId)
        checkPrincessPointCount()
        checkPrincessPointButtonStatus()
    }
    
    // MARK: Actions
    @IBAction func onGivePrincessPointsTapped(sender: AnyObject) {
        princessPointButton.hidden = true
        //createsPrincessPoint()
        givePrincessPoint()
    }
    
    @IBAction func onChatTapped(sender: AnyObject) {
        
    }
    // enables editable bio for profile owner
    func disableBioTextView() {
        
        let userID = self.defaults.valueForKey("User ID") as! String
        if (selectedUserId == userID) {
            self.userBioTextView.editable = true
        } else {
            self.userBioTextView.editable = false
        }
    }
    
    // MARK: Disasble princess point and chat button for user
    func disableUserProfileButtons(){
        
        let userID = self.defaults.valueForKey("User ID") as! String
        if (self.selectedUserId == userID) {
            self.princessPointButton.hidden = true
            self.chatButton.hidden = true
        }
    }
    
    // MARK: Firebase Functions
    func givePrincessPoint() {
        
        let userID = self.defaults.valueForKey("User ID") as! String
        let childRef = ref.childByAppendingPath("/princessPoints")
        
        // receivedFrom
        let selectedUserRef = childRef.childByAppendingPath(selectedUserId)
        let receivedRef = selectedUserRef.childByAppendingPath("receivedFrom") // adds bucket in Firebase
        let receivedValue = ["receivedFrom": userID]
        
        // givenTo
        let userRef = childRef.childByAppendingPath(userID)
        let giveRef = userRef.childByAppendingPath("givenTo") // adds bucket in Firebase
        let giveValue = ["givenTo": selectedUserId]
        
        giveRef.childByAppendingPath(selectedUserId).updateChildValues(giveValue) // adds point
        receivedRef.childByAppendingPath(userID).updateChildValues(receivedValue) // adds point
    }
    
    func checkPrincessPointButtonStatus() {
        
        let userID = self.defaults.valueForKey("User ID") as! String
        let childRef = ref.childByAppendingPath("/princessPoints")
        
        let userRef = childRef.childByAppendingPath(selectedUserId)
        let giveRef = userRef.childByAppendingPath("receivedFrom")
        giveRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            for id in snapshot.children {
                let grabbedId = id.value!!["receivedFrom"] as! String
                print(grabbedId)
                if (grabbedId == userID) {
                    self.princessPointButton.hidden = true
                    break
                }
            }
            }
        )}
    
    func checkPrincessPointCount() {
        
        let userRef = ref.childByAppendingPath("/princessPoints")
        let idRef = userRef.childByAppendingPath(selectedUserId)
        let receivedFromRef = idRef.childByAppendingPath("receivedFrom")
        receivedFromRef.observeEventType(.Value, withBlock: { snapshot in
            let count = snapshot.childrenCount
            self.princessPointCount = count
            self.userPrincessPointsTextLabel.text = "👑 +\(self.princessPointCount)"
        })
    }
    
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
    
    // MARK: Segue Functions
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "chatVCSegue") {
//            let storyboard = UIStoryboard(name: "ChatVC", bundle: nil)
//            let vc = storyboard.instantiateViewControllerWithIdentifier("chatVCSegue") as! ChatVC
            let destinationChatVc = segue.destinationViewController as! ChatVC
            destinationChatVc.selectedChatUserId = self.selectedUserId
        } else {
        }
    }
}
