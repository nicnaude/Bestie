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
    @IBOutlet weak var princessPointRevoke: UIButton!
    @IBOutlet weak var editBioButton: UIButton!
    @IBOutlet weak var closeProfileButton: UIButton!
    @IBOutlet weak var princessPointTextLabel: UILabel!
    @IBOutlet weak var chatLabel: UILabel!
    @IBOutlet weak var chatUnavailableButton: UIButton!
    
    
    // MARK: Variables
    var ref = Firebase(url: "https://bestieapp.firebaseio.com")
    
    var defaults = NSUserDefaults.standardUserDefaults()
    var selectedUserId = String()
    var princessPointCount = UInt()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        
        view?.backgroundColor = UIColor.bestiePurple()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        fetchUserInformation(selectedUserId)
        disableBioTextView()
        // disableUserProfileButtons()
        checkPrincessPointCount()
        checkPrincessPointButtonStatus()
        loadBio()
    }
    
    override func viewWillAppear(animated: Bool) {
        fetchUserInformation(selectedUserId)
    }
    
    // MARK: Actions
    
    @IBAction func onChatTapped(sender: AnyObject) {
    }
    
    @IBAction func onGivePrincessPointsTapped(sender: AnyObject) {
        princessPointButton.hidden = true
        princessPointRevoke.hidden = false
        princessPointTextLabel.text = "Revoke"
        givePrincessPoint()
    }
    
    @IBAction func onEditSaveBioButtonTapped(sender: UIButton) {
        
        if sender.titleLabel!.text == "Edit" {
            sender.setTitle("Done", forState: .Normal)
            userBioTextView.editable = true
            return
        } else if (sender.titleLabel?.text == "Done"){
            sender.setTitle("Edit", forState: .Normal)
            userBioTextView.editable = false
            setBio()
            loadBio()
        }
    }
    
    // enables editable bio for profile owner
    func disableBioTextView() {
        
        let userID = self.defaults.valueForKey("User ID") as! String
        if (selectedUserId != userID) {
            self.userBioTextView.editable = false
            self.editBioButton.hidden = true
        } else if (selectedUserId == userID) {
            self.userBioTextView.editable = false
        }
    }
    
    
    // MARK: Disasble princess point and chat button for user
    func disableUserProfileButtons(){
        
        let userID = self.defaults.valueForKey("User ID") as! String
        
        if (self.selectedUserId == userID) {
            self.princessPointButton.hidden = true
            self.chatButton.hidden = true
            self.princessPointRevoke.hidden = true
            self.closeProfileButton.hidden = true
            self.chatUnavailableButton.hidden = true
            self.chatLabel.hidden = true
            self.princessPointTextLabel.hidden = true
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
        
        self.chatButton.hidden = false
        self.chatUnavailableButton.hidden = true
        self.chatLabel.alpha = 1.0
    }
    
    func checkPrincessPointButtonStatus() {
        
        let userID = self.defaults.valueForKey("User ID") as! String
        let childRef = ref.childByAppendingPath("/princessPoints")
        
        let userRef = childRef.childByAppendingPath(selectedUserId)
        let giveRef = userRef.childByAppendingPath("receivedFrom")
        
        if userID == selectedUserId {
            self.disableUserProfileButtons()
            return
        }
        giveRef.queryOrderedByKey().queryEqualToValue(userID).observeSingleEventOfType(.Value, withBlock: { snapshot in
            if (!snapshot.hasChildren()) {
                self.princessPointButton.hidden = false
                self.princessPointRevoke.hidden = true
                self.princessPointTextLabel.text = "+Princess Point"
                self.chatButton.hidden = true
                self.chatLabel.alpha = 0.5
                return
            } else {
                self.princessPointButton.hidden = true
                self.princessPointRevoke.hidden = false
                self.princessPointTextLabel.text = "Revoke"
                self.chatButton.hidden = false
                self.chatLabel.alpha = 1
                return
                
            }
            
            
            
            
//            for id in snapshot.children {
//                let grabbedId = id.value!!["receivedFrom"] as! String
//                print(grabbedId)
//                if (grabbedId == userID) {
//                    self.princessPointButton.hidden = true
//                    self.princessPointRevoke.hidden = false
//                    self.princessPointTextLabel.text = "Revoke"
//                    self.chatButton.hidden = false
//                    self.chatLabel.alpha = 1
//                    return
//                } else if (grabbedId != userID) {
//                    self.princessPointButton.hidden = false
//                    self.princessPointRevoke.hidden = true
//                    self.princessPointTextLabel.text = "+Princess Point"
//                    self.chatButton.hidden = true
//                    self.chatLabel.alpha = 0.5
//                    return
//                }
//            }
//            self.disableUserProfileButtons()
        })
    }
    
    func checkPrincessPointCount() {
        
        let userRef = ref.childByAppendingPath("/princessPoints")
        let idRef = userRef.childByAppendingPath(selectedUserId)
        let receivedFromRef = idRef.childByAppendingPath("receivedFrom")
        receivedFromRef.observeEventType(.Value, withBlock: { snapshot in
            let count = snapshot.childrenCount
            self.princessPointCount = count
            self.userPrincessPointsTextLabel.text = "👑 +\(self.princessPointCount)"
            self.disableUserProfileButtons()
        })
    }
    
    func setBio() {
        
        let userID = self.defaults.valueForKey("User ID") as! String
        let bio = ["bio": userBioTextView.text as String]
        
        let userRef = ref.childByAppendingPath("/users")
        userRef.childByAppendingPath(userID).updateChildValues(bio)
    }
    
    func loadBio() {
        
        let userRef = ref.childByAppendingPath("/users")
        let userID = self.defaults.valueForKey("User ID") as! String
        if (selectedUserId != userID) {
            userRef.childByAppendingPath(selectedUserId).childByAppendingPath("bio").observeSingleEventOfType(.Value, withBlock: { snapshot in
                let bioFromFirebase = snapshot.value as! String
                self.userBioTextView.text = bioFromFirebase
                self.userBioTextView.editable = false
                self.editBioButton.hidden = true
            })
        } else if (selectedUserId == userID) {
            userRef.childByAppendingPath(userID).childByAppendingPath("bio").observeSingleEventOfType(.Value, withBlock: { snapshot in
                let bioFromFirebase = snapshot.value as! String
                self.userBioTextView.text = bioFromFirebase
                self.userBioTextView.editable = false
            })
        }
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
                    
                    self.profilePictureImage.layer.borderWidth = 0.0 // 1.0
                    self.profilePictureImage.layer.masksToBounds = false
                    self.profilePictureImage.layer.borderColor = UIColor.whiteColor().CGColor
                    //   self.profilePictureImage.layer.cornerRadius = self.profilePictureImage.frame.size.width/2
                    self.profilePictureImage.clipsToBounds = false //true
                    self.profilePictureImage.image = UIImage(data: data!)
                    }
                )}
            task.resume()
            })
            self.disableUserProfileButtons()
        }
    
    // MARK: Segue Functions
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "chatVCSegue") {
            let destinationChatVc = segue.destinationViewController as! ChatVC
            destinationChatVc.selectedChatUserId = self.selectedUserId
        } else {
        }
    }
}
