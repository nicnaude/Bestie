//
//  ChatHomeVC.swift
//  Bestie
//
//  Created by Nicholas Naudé on 15/02/2016.
//  Copyright © 2016 Nicholas Naudé. All rights reserved.
//

import UIKit
import Firebase
import FBSDKShareKit
import FBSDKCoreKit
import FBSDKLoginKit
import JSQMessagesViewController

var ref: Firebase!
var tempArray = []
var newMatch = [String]()
var existingMatch = [String]()
var tableViewArray = []

let defaults = NSUserDefaults.standardUserDefaults()
var currentUserID = defaults.objectForKey("User ID") as! String

class ChatHomeVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var chatSegmentedControl: UISegmentedControl!
    @IBOutlet weak var conversationsTableView: UITableView!
    
    var ref = Firebase(url: "https://bestieapp.firebaseio.com/")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpUI()
        newMatch = ["Ryan C", "Mike S", "Nicholas N", "Dan Z", "Evgeny S", "Jerry L", "Nathan L", "Michael Austin S", "Louis Staun P", "Louis V"]
        existingMatch = ["Lars S", "Rewalt D", "Marc B", "Jacque K", "Peter P", "Walter W", "Jesse P", "Gustavo F", "Walt Jr W", "Mickey M", "Rewalt D", "Marc B", "Jacque K", "Peter P", "Walter W", "Jesse P", "Gustavo F", "Walt Jr W", "Mickey M"]
    }
    
    // MARK: Action Functions
    @IBAction func onCloseButtonTapped(sender: UIButton) {
        dismissViewControllerAnimated(false, completion: nil)
    }
    
    @IBAction func onSegmentedControlToggled(sender: UISegmentedControl) {
        
        switch chatSegmentedControl.selectedSegmentIndex {
            
        case 0:
            tableViewArray = existingMatch
        case 1:
            tableViewArray = newMatch
            default:
            break
        }
        conversationsTableView.reloadData()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let chatCell = tableView.dequeueReusableCellWithIdentifier("chatCell")! as UITableViewCell
        let selectedConversation = tableViewArray[indexPath.row]
        chatCell.textLabel!.text = selectedConversation as? String
        return chatCell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewArray.count
    }
    
    func queryFirebaseForNewMatches() {
        
        // A new match includes someone you've given a PP to, received a PP from, AND not yet chatted
        
        let princessPointRef = ref.childByAppendingPath("/princessPoints")
        
        let receivedRef = princessPointRef.childByAppendingPath("receivedFrom")
            receivedRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
        
    })
}
    func queryFirebaseforConversations() {
        
        
    }
    
}

