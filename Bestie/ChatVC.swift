//
//  ChatVC.swift
//  Bestie
//
//  Created by Nicholas Naudé on 15/02/2016.
//  Copyright © 2016 Nicholas Naudé. All rights reserved.
//

import UIKit
import Firebase
//import JSQMessagesViewController

class ChatVC: UIViewController { //JSQMessagesViewController
    
    let defaults = NSUserDefaults.standardUserDefaults()
    var ref = Firebase(url: "https://bestieapp.firebaseio.com")
    var selectedChatUserId = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    @IBAction func onRevokeButtonTapped(sender: UIBarButtonItem) {
        
        signupErrorAlert("Revoke Princess Point?", message: "Taking away their Princess Point removes this Bestie from your feed. FOREVER! 🤔")
        
    }
    
    func signupErrorAlert(title: String, message: String) {
        
        // Called upon signup error to let the user know signup didn't work.
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let action = UIAlertAction(title: "Yes", style: .Default) { (alert: UIAlertAction!) -> Void in
            self.revokePrincessPoint()
            self.setRejectionStatus()
            self.performSegueWithIdentifier("unwindSegueMainFeedVC", sender: self)
        }
        let action2 = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)

        alert.addAction(action)
        alert.addAction(action2)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func revokePrincessPoint() {
        
        // Revokes princess point
        let userID = self.defaults.valueForKey("User ID") as! String
        let childRef = ref.childByAppendingPath("/princessPoints")
        let selectedChatUserRef = childRef.childByAppendingPath(selectedChatUserId)
        let userRef = childRef.childByAppendingPath(userID)
        
        let giveRef = userRef.childByAppendingPath("givenTo")
        let selectedUserRef = giveRef.childByAppendingPath(selectedChatUserId)
        selectedUserRef.removeValue()

        let receievedRef = selectedChatUserRef.childByAppendingPath("receivedFrom")
        let userIdRef = receievedRef.childByAppendingPath(userID)
        userIdRef.removeValue()
    }
    
    func setRejectionStatus() {
        
        let userID = self.defaults.valueForKey("User ID") as! String
        let childRef = ref.childByAppendingPath("/princessPoints")
        
        // rejectedBy
        let selectedUserRef = childRef.childByAppendingPath(selectedChatUserId)
        let rejectedByRef = selectedUserRef.childByAppendingPath("rejectedBy") // adds bucket in Firebase
        let rejectedByValue = ["rejectedBy": userID]
        
        // rejected
        let userRef = childRef.childByAppendingPath(userID)
        let rejectedRef = userRef.childByAppendingPath("rejected") // adds bucket in Firebase
        let rejectedValue = ["rejected": selectedChatUserId]
        
        rejectedRef.childByAppendingPath(selectedChatUserId).updateChildValues(rejectedValue) // adds point
        rejectedByRef.childByAppendingPath(userID).updateChildValues(rejectedByValue) // add
    }
}
