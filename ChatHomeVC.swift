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

let defaults = UserDefaults.standard
var currentUserID = defaults.object(forKey: "User ID") as! String

class ChatHomeVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var chatSegmentedControl: UISegmentedControl!
    @IBOutlet weak var conversationsTableView: UITableView!
    
    var ref = Firebase(url: "https://bestieapp.firebaseio.com/")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.conversationsTableView.contentInset = UIEdgeInsetsMake(64,0,0,0)
        
        newMatch = ["Ryan C", "Mike S", "Nicholas N", "Dan Z", "Evgeny S", "Jerry L", "Nathan L", "Michael Austin S", "Louis Staun P", "Louis V"]
        existingMatch = ["Lars S", "Rewalt D", "Marc B", "Jacque K", "Peter P", "Walter W", "Jesse P", "Gustavo F", "Walt Jr W", "Mickey M", "Rewalt D", "Marc B", "Jacque K", "Peter P", "Walter W", "Jesse P", "Gustavo F", "Walt Jr W", "Mickey M","Lars S", "Rewalt D", "Marc B", "Jacque K", "Peter P", "Walter W", "Jesse P", "Gustavo F", "Walt Jr W", "Mickey M", "Rewalt D", "Marc B", "Jacque K", "Peter P", "Walter W", "Jesse P", "Gustavo F", "Walt Jr W", "Mickey M","Lars S", "Rewalt D", "Marc B", "Jacque K", "Peter P", "Walter W", "Jesse P", "Gustavo F", "Walt Jr W", "Mickey M", "Rewalt D", "Marc B", "Jacque K", "Peter P", "Walter W", "Jesse P", "Gustavo F", "Walt Jr W", "Mickey M"]
    }//

    
    
    // MARK: Action Functions
    @IBAction func onCloseButtonTapped(_ sender: UIButton) {
        dismiss(animated: false, completion: nil)
    }
    
    @IBAction func onSegmentedControlToggled(_ sender: UISegmentedControl) {
        
        switch chatSegmentedControl.selectedSegmentIndex {
            
        case 0:
            tableViewArray = existingMatch
            conversationsTableView.backgroundColor = UIColor.clear
        case 1:
            tableViewArray = newMatch
            conversationsTableView.backgroundColor = UIColor.clear
            default:
            break
        }
        conversationsTableView.reloadData()
    }//
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let chatCell = tableView.dequeueReusableCell(withIdentifier: "chatCell")! as UITableViewCell
        let selectedConversation = tableViewArray[(indexPath as NSIndexPath).row]
        chatCell.textLabel!.text = selectedConversation as? String
        return chatCell
    }//
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewArray.count
    }//
    
    
    func queryFirebaseForNewMatches() {
        
        // A new match includes someone you've given a PP to, received a PP from, AND not yet chatted
        let princessPointRef = ref?.child(byAppendingPath: "/princessPoints")
        
        let receivedRef = princessPointRef?.child(byAppendingPath: "receivedFrom")
            receivedRef?.observeSingleEvent(of: .value, with: { snapshot in
        
    })
}
    func queryFirebaseforConversations() {
        
        
    }
    
}

