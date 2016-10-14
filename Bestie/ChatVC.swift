//
//  ChatVC.swift
//  Bestie
//
//  Created by Nicholas Naudé on 15/02/2016.
//  Copyright © 2016 Nicholas Naudé. All rights reserved.
//

import UIKit
import Firebase
import JSQMessagesViewController

class ChatVC: JSQMessagesViewController {
    
    // MARK: Chat Variables
    var messageClass = [Message]()
    var messages = [JSQMessage]()
    
    var outgoingBubbleImageView: JSQMessagesBubbleImage!
    var incomingBubbleImageView: JSQMessagesBubbleImage!
    
    // MARK: Other Variables
    let defaults = UserDefaults.standard
    var ref = Firebase(url: "https://bestieapp.firebaseio.com")
    var selectedChatUserId: String!
    var pathId = String()
    var selectedUserAvatar = String()
    
    // MARK: Lifecycle Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBubbles()
        addBestieLogo()
        let currentUserId = defaults.value(forKey: "User ID") as! String
        self.senderId = currentUserId
        
        // Chat avatars
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSize(width: 30.0, height: 30.0)
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSize(width: 30.0, height: 30.0)
        collectionView?.collectionViewLayout.springinessEnabled = true
        
        // Hide attachment functionality
        self.inputToolbar?.contentView?.leftBarButtonItem = nil
        
        //getReceiversProfilePicture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        ref?.child(byAppendingPath: "/chat")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        joinOrCreateChat( { ()->() in
            self.observeMessages()
        })
    }
    
    // MARK: Action Functions
    @IBAction func onCloseButtonTapped(_ sender: UIButton) {
        
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func onRevokeButtonTapped(_ sender: UIBarButtonItem) {
        signupErrorAlert("🤔", message: "Taking away their Princess Point removes them from your feed forever. Are you sure?")
    }
    
    // MARK: Chat Functions
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item] // 1
        let currentUserId = defaults.value(forKey: "User ID") as! String
        if message.senderId == currentUserId { // 2
            return outgoingBubbleImageView
        } else { // 3
            return incomingBubbleImageView
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        
        
        let message = messages[(indexPath as NSIndexPath).item]
        let currentUserId = defaults.value(forKey: "User ID") as! String
        if message.senderId == currentUserId
        { // 1
            cell.textView!.textColor = UIColor.white // 2
        } else {
            cell.textView!.textColor = UIColor.black // 3
        }
        return cell
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        let user = messages[indexPath.item].senderId
        if user == currentUserID {
            let avatarRound = JSQMessagesAvatarImageFactory.circularAvatarImage(UIImage(named: "image"), withDiameter: 30)
            let avatar = JSQMessagesAvatarImageFactory.avatarImage(with: avatarRound, diameter: 30)
            return avatar
        } else {
            let avatarRound = JSQMessagesAvatarImageFactory.circularAvatarImage(UIImage(named: "image2"), withDiameter: 30)
            let avatar = JSQMessagesAvatarImageFactory.avatarImage(with: avatarRound, diameter: 30)
            return avatar
        }
    }
    
//    func getReceiversProfilePicture() {
//        
//        let profilePhotoRef = ref.childByAppendingPath(selectedUserId)
//        profilePhotoRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
//            let photo = snapshot.value["profilePictureURL"] as! String
//            self.selectedUserAvatar = photo
//        })
//    }
    
    func addMessage(_ id: String, text: String) {
        let message = JSQMessage(senderId: id, displayName: "", text: text)
        messages.append(message!)
    }
    
    fileprivate func observeMessages() {
        let chatRef = ref?.child(byAppendingPath: "chats")
        let messageQuery = chatRef?.child(byAppendingPath: self.pathId)
        messageQuery?.queryLimited(toLast: 100).observe(.childAdded, with: { snapshot in
            let text = snapshot?.value!["messageContent"] as! String
            let id = snapshot?.value!["senderId"] as! String
            
            self.addMessage(id, text: text)
            self.finishReceivingMessage()
        })
    }
    
    func joinOrCreateChat(_ completionHandler:@escaping () -> ()) {
        let currentUserUID = defaults.value(forKey: "User ID") as? String ?? "i don't know"
        
        let desiredIdCombo = currentUserUID + selectedChatUserId
        let testIdCombo = selectedChatUserId + currentUserUID
        let chatRef = ref?.child(byAppendingPath: "chats")
        var foundChat = false
        
        chatRef?.queryOrderedByKey().observeSingleEvent(of: .value, with: { snapshot in
            print(snapshot?.children.allObjects.count)
            for id in (snapshot?.children.allObjects)! {
                print("here")
                if ((id as AnyObject).key == desiredIdCombo) {
                    self.pathId = desiredIdCombo
                    print("Path ID:", self.pathId)
                    foundChat = true
                } else if ((id as AnyObject).key == testIdCombo) {
                    self.pathId = testIdCombo
                    foundChat = true
                }
            }
            if (!foundChat){
                self.pathId = desiredIdCombo
                print("Path ID:", self.pathId)
            }
            completionHandler()
        })
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        let currentUserUID = defaults.value(forKey: "User ID") as? String ?? "i don't know"
        
        let chatRef = ref?.child(byAppendingPath: "chats")
        let itemRef = chatRef?.child(byAppendingPath: self.pathId).childByAutoId()
        let newMessageForFirebase = ["senderId": currentUserUID, "messageContent": text]
        itemRef?.updateChildValues(newMessageForFirebase)
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        finishSendingMessage()
    }
    
    fileprivate func setupBubbles() {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        outgoingBubbleImageView = bubbleImageFactory?.outgoingMessagesBubbleImage(with: UIColor.bestiePurple())
        incomingBubbleImageView = bubbleImageFactory?.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }
    
    // MARK: Princess Point Functions
    func signupErrorAlert(_ title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let action = UIAlertAction(title: "Yes", style: .default) { (alert: UIAlertAction!) -> Void in
            self.revokePrincessPoint()
            self.setRejectionStatus()
            self.performSegue(withIdentifier: "unwindSegueMainFeedVC", sender: self)
        }
        let action2 = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(action)
        alert.addAction(action2)
        present(alert, animated: true, completion: nil)
    }
    
    func revokePrincessPoint() {
        
        // Revokes princess point
        let userID = self.defaults.value(forKey: "User ID") as! String
        let childRef = ref?.child(byAppendingPath: "/princessPoints")
        let selectedChatUserRef = childRef?.child(byAppendingPath: selectedChatUserId)
        let userRef = childRef?.child(byAppendingPath: userID)
        
        let giveRef = userRef?.child(byAppendingPath: "givenTo")
        let selectedUserRef = giveRef?.child(byAppendingPath: selectedChatUserId)
        selectedUserRef?.removeValue()
        
        let receievedRef = selectedChatUserRef?.child(byAppendingPath: "receivedFrom")
        let userIdRef = receievedRef?.child(byAppendingPath: userID)
        userIdRef?.removeValue()
    }
    
    func setRejectionStatus() {
        
        let userID = self.defaults.value(forKey: "User ID") as! String
        let childRef = ref?.child(byAppendingPath: "/princessPoints")
        
        // rejectedBy
        let selectedUserRef = childRef?.child(byAppendingPath: selectedChatUserId)
        let rejectedByRef = selectedUserRef?.child(byAppendingPath: "rejectedBy") // adds bucket in Firebase
        let rejectedByValue = ["rejectedBy": userID]
        
        // rejected
        let userRef = childRef?.child(byAppendingPath: userID)
        let rejectedRef = userRef?.child(byAppendingPath: "rejected") // adds bucket in Firebase
        let rejectedValue = ["rejected": selectedChatUserId]
        
        rejectedRef?.child(byAppendingPath: selectedChatUserId).updateChildValues(rejectedValue) // adds point
        rejectedByRef?.child(byAppendingPath: userID).updateChildValues(rejectedByValue) // add
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "unwindSegueMainFeedVC" {
            let destinatation = segue.destination as! MainfeedVC
            destinatation.fetchAllUsersAndPutCurrentUserAtIndex0()
        }
    }
}
