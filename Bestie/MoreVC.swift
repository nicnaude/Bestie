//
//  MoreVC.swift
//  Bestie
//
//  Created by Nicholas Naudé on 15/02/2016.
//  Copyright © 2016 Nicholas Naudé. All rights reserved.
//

import UIKit
import Firebase

var moreDataContent = []
var selectedUserId = String()
var userID = String()

class MoreVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let defaults = NSUserDefaults.standardUserDefaults()
        moreDataContent = ["Update Profile", "Feedback", "Terms of Service"]
    }
    
    // MARK: Action Functions
    @IBAction func onCloseButtonTapped(sender: UIButton) {
        
        dismissViewControllerAnimated(false, completion: nil)
    }
    // MARK: - TableView methods
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("moreCell")
        
        let selectedCell = moreDataContent.objectAtIndex(indexPath.row) as! String
        cell?.textLabel?.text = selectedCell
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        
        if cell?.textLabel?.text == "Update Profile" {
            self.performSegueWithIdentifier("profileSegue", sender: self)
        } else if (cell?.textLabel?.text == "Feedback") {
            let email = "nicnaude@gmail.com"
            // add subject field.
            let url = NSURL(string: "mailto:\(email)")
            UIApplication.sharedApplication().openURL(url!)
        } else {
            self.performSegueWithIdentifier("TOSsegue", sender: self)
        }
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "profileSegue") {
            let userID = defaults.valueForKey("User ID") as! String
            let destinationProfileVc = segue.destinationViewController as! ProfileVC
            destinationProfileVc.selectedUserId = userID
        }
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return moreDataContent.count
    }
    
    
    @IBAction func onLogoutTapped(sender: UIBarButtonItem) {
        BackendProcessor.backendProcessor.logOutUser()
    }
}
