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

        self.tableView.contentInset = UIEdgeInsetsMake(64,0,0,0)
        
        let defaults = UserDefaults.standard
        moreDataContent = ["Update Profile", "Feedback", "Terms of Service"]
    }//

    
    
    // MARK: Action Functions
    @IBAction func onCloseButtonTapped(_ sender: UIButton) {
        
        dismiss(animated: false, completion: nil)
    }//
    
    
    // MARK: - TableView methods
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "moreCell")
        
        let selectedCell = moreDataContent.object(at: (indexPath as NSIndexPath).row) as! String
        cell?.textLabel?.text = selectedCell
        return cell!
    }//
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        if cell?.textLabel?.text == "Update Profile" {
            self.performSegue(withIdentifier: "profileSegue", sender: self)
        } else if (cell?.textLabel?.text == "Feedback") {
            let email = "nicnaude@gmail.com"
            // add subject field.
            let url = URL(string: "mailto:\(email)")
            UIApplication.shared.openURL(url!)
        } else {
            self.performSegue(withIdentifier: "TOSsegue", sender: self)
        }
    }//
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "profileSegue") {
            let userID = defaults.value(forKey: "User ID") as! String
            let destinationProfileVc = segue.destination as! ProfileVC
            destinationProfileVc.selectedUserId = userID
        }
    }//
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return moreDataContent.count
    }//
    

} // The End
