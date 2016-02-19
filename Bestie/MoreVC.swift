//
//  MoreVC.swift
//  Bestie
//
//  Created by Nicholas Naudé on 15/02/2016.
//  Copyright © 2016 Nicholas Naudé. All rights reserved.
//

import UIKit

var moreDataContent = []

class MoreVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        moreDataContent = ["Update Profile", "Feedback", "Terms of Service"]
}
    
    // MARK: - TableView methods
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("moreCell")
        
        let selectedCell = moreDataContent.objectAtIndex(indexPath.row) as! String
        cell?.textLabel?.text = selectedCell
        
//        if(cell?.textLabel?.text == "Update Profile"){
//            let storyboard = UIStoryboard(name: "ProfileVC", bundle: nil)
//            let vc = storyboard.instantiateViewControllerWithIdentifier("someViewController") as! UIViewController
//            self.presentViewController(vc, animated: true, completion: nil)
//        } else if (cell?.textLabel?.text == "Feedback") {
//        
//        } else {
//        
//        }
        
        return cell!
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return moreDataContent.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Return the number of sections.
        return 2 // To test
    }
}
