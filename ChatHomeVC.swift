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

//let defaults = NSUserDefaults.standardUserDefaults()
//let uid = FBSDKAccessToken.currentAccessToken().userID
//var currentUser = defaults.setObject(uid, forKey:"User ID")


class ChatHomeVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var ref = Firebase(url: "https://bestieapp.firebaseio.com/")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tempArray = ["temp"]
        // Do any additional setup after loading the view.
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        
        //        let destination = segue.destinationViewController as! UINavigationController
        
        let navVc = segue.destinationViewController as! ChatVC
        //let chatVc = navVc.viewControllers.first as! ChatVC
        //        chatVc.senderId = ref.authData.uid
        //        chatVc.senderDisplayName = ""
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("chatCell")
        
        let selectedCell = tempArray.objectAtIndex(indexPath.row) as! String
        cell?.textLabel?.text = selectedCell
        
        return cell!
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return tempArray.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 2
    }
}
