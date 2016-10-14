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
    
    var defaults = UserDefaults.standard
    var selectedUserId = String()
    var princessPointCount = UInt()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        setUpUI()
        
        view?.backgroundColor = UIColor.bestiePurple()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        fetchUserInformation(selectedUserId)
        disableBioTextView()
        // disableUserProfileButtons()
        checkPrincessPointCount()
        checkPrincessPointButtonStatus()
        loadBio()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = true
        fetchUserInformation(selectedUserId)
    }
    
    // MARK: Actions
    
    @IBAction func onChatTapped(_ sender: AnyObject) {
    }
    
    @IBAction func onGivePrincessPointsTapped(_ sender: AnyObject) {
        princessPointButton.isHidden = true
        princessPointRevoke.isHidden = false
        princessPointTextLabel.text = "Revoke"
        givePrincessPoint()
    }
    
    @IBAction func onEditSaveBioButtonTapped(_ sender: UIButton) {
        
        if sender.titleLabel!.text == "Edit" {
            sender.setTitle("Done", for: UIControlState())
            userBioTextView.isEditable = true
            return
        } else if (sender.titleLabel?.text == "Done"){
            sender.setTitle("Edit", for: UIControlState())
            userBioTextView.isEditable = false
            setBio()
            loadBio()
        }
    }
    
    // enables editable bio for profile owner
    func disableBioTextView() {
        
        let userID = self.defaults.value(forKey: "User ID") as! String
        if (selectedUserId != userID) {
            self.userBioTextView.isEditable = false
            self.editBioButton.isHidden = true
        } else if (selectedUserId == userID) {
            self.userBioTextView.isEditable = false
        }
    }
    
    
    // MARK: Disasble princess point and chat button for user
    func disableUserProfileButtons(){
        
        let userID = self.defaults.value(forKey: "User ID") as! String
        
        if (self.selectedUserId == userID) {
            self.princessPointButton.isHidden = true
            self.chatButton.isHidden = true
            self.princessPointRevoke.isHidden = true
            self.closeProfileButton.isHidden = true
            self.chatUnavailableButton.isHidden = true
            self.chatLabel.isHidden = true
            self.princessPointTextLabel.isHidden = true
        }
    }
    
    // MARK: Firebase Functions
    func givePrincessPoint() {
        
        let userID = self.defaults.value(forKey: "User ID") as! String
        let childRef = ref?.child(byAppendingPath: "/princessPoints")
        
        // receivedFrom
        let selectedUserRef = childRef?.child(byAppendingPath: selectedUserId)
        let receivedRef = selectedUserRef?.child(byAppendingPath: "receivedFrom") // adds bucket in Firebase
        let receivedValue = ["receivedFrom": userID]
        
        // givenTo
        let userRef = childRef?.child(byAppendingPath: userID)
        let giveRef = userRef?.child(byAppendingPath: "givenTo") // adds bucket in Firebase
        let giveValue = ["givenTo": selectedUserId]
        
        giveRef?.child(byAppendingPath: selectedUserId).updateChildValues(giveValue) // adds point
        receivedRef?.child(byAppendingPath: userID).updateChildValues(receivedValue) // adds point
        
        self.chatButton.isHidden = false
        self.chatUnavailableButton.isHidden = true
        self.chatLabel.alpha = 1.0
    }
    
    func checkPrincessPointButtonStatus() {
        
        let userID = self.defaults.value(forKey: "User ID") as! String
        let childRef = ref?.child(byAppendingPath: "/princessPoints")
        
        let userRef = childRef?.child(byAppendingPath: selectedUserId)
        let giveRef = userRef?.child(byAppendingPath: "receivedFrom")
        
        if userID == selectedUserId {
            self.disableUserProfileButtons()
            return
        }
        giveRef?.queryOrderedByKey().queryEqual(toValue: userID).observeSingleEvent(of: .value, with: { snapshot in
            if (!(snapshot?.hasChildren())!) {
                self.princessPointButton.isHidden = false
                self.princessPointRevoke.isHidden = true
                self.princessPointTextLabel.text = "+Princess Point"
                self.chatButton.isHidden = true
                self.chatLabel.alpha = 0.5
                return
            } else {
                self.princessPointButton.isHidden = true
                self.princessPointRevoke.isHidden = false
                self.princessPointTextLabel.text = "Revoke"
                self.chatButton.isHidden = false
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
        
        let userRef = ref?.child(byAppendingPath: "/princessPoints")
        let idRef = userRef?.child(byAppendingPath: selectedUserId)
        let receivedFromRef = idRef?.child(byAppendingPath: "receivedFrom")
        receivedFromRef?.observe(.value, with: { snapshot in
            let count = snapshot?.childrenCount
            self.princessPointCount = count!
            self.userPrincessPointsTextLabel.text = "👑 +\(self.princessPointCount)"
            self.disableUserProfileButtons()
        })
    }
    
    func setBio() {
        
        let userID = self.defaults.value(forKey: "User ID") as! String
        let bio = ["bio": userBioTextView.text as String]
        
        let userRef = ref?.child(byAppendingPath: "/users")
        userRef?.child(byAppendingPath: userID).updateChildValues(bio)
    }
    
    func loadBio() {
        
        let userRef = ref?.child(byAppendingPath: "/users")
        let userID = self.defaults.value(forKey: "User ID") as! String
        if (selectedUserId != userID) {
            userRef?.child(byAppendingPath: selectedUserId).child(byAppendingPath: "bio").observeSingleEvent(of: .value, with: { snapshot in
                let bioFromFirebase = snapshot?.value as! String
                self.userBioTextView.text = bioFromFirebase
                self.userBioTextView.isEditable = false
                self.editBioButton.isHidden = true
            })
        } else if (selectedUserId == userID) {
            userRef?.child(byAppendingPath: userID).child(byAppendingPath: "bio").observeSingleEvent(of: .value, with: { snapshot in
                let bioFromFirebase = snapshot?.value as! String
                self.userBioTextView.text = bioFromFirebase
                self.userBioTextView.isEditable = false
            })
        }
    }
    
    func fetchUserInformation(_ userID:String) {
        
        let userRef = ref?.child(byAppendingPath: "/users")
        userRef?.queryOrdered(byChild: "facebookID").queryEqual(toValue: selectedUserId).observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot?.value as? [AnyHashable: Any], let user = value[userID] as? [AnyHashable: Any] else { return }
            
            let userName = user["name"] as? String ?? "It isn't working"
            self.userFirstNameTextLabel.text = userName
            
            
            let profilePictureURL = user["profilePictureURL"] as? String ?? "It isn't working"
            let url = URL(string: profilePictureURL)
            let session = URLSession.shared
            let task = session.dataTask(with: url!, completionHandler: { (data: Data?, response: URLResponse?, error: NSError?) -> Void in
                DispatchQueue.main.async(execute: { () -> Void in
                    
                    self.profilePictureImage.layer.borderWidth = 0.0 // 1.0
                    self.profilePictureImage.layer.masksToBounds = false
                    self.profilePictureImage.layer.borderColor = UIColor.white.cgColor
                    //   self.profilePictureImage.layer.cornerRadius = self.profilePictureImage.frame.size.width/2
                    self.profilePictureImage.clipsToBounds = false //true
                    self.profilePictureImage.image = UIImage(data: data!)
                    }
                )} as! (Data?, URLResponse?, Error?) -> Void) 
            task.resume()
            })
            self.disableUserProfileButtons()
        }
    
    // MARK: Segue Functions
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "chatVCSegue") {
            let destinationChatVc = segue.destination as! ChatVC
            destinationChatVc.selectedChatUserId = self.selectedUserId
        } else {
        }
    }
}
