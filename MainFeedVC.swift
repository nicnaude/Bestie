//
//  MainFeedVC.swift
//  Bestie
//
//  Created by Nicholas Naudé and Michael Saltzman on 13/02/2016.
//  Copyright © 2016 Nicholas Naudé and Michael Saltzman. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

class MainfeedVC: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    let defaults = NSUserDefaults.standardUserDefaults()
    
    let ref = Firebase(url: "https://bestieapp.firebaseio.com")
    var locationManager = CLLocationManager()
    var userLocation = CLLocation()
    var usersArray = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        storeFacebookAuthState()
    }
    
    
    // MARK: - TableViewController Delegate Functions
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.usersArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let userCell = tableView.dequeueReusableCellWithIdentifier("userCell") as! UserCell
        let currentUser = usersArray[indexPath.row] as User
        userCell.textLabel?.text = currentUser.name
        userCell.backgroundColor = UIColor.lightGrayColor()
        return userCell
    }
    
    func getUserLocation() {
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.startUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations.first!
        if userLocation.verticalAccuracy < 1000 && userLocation.horizontalAccuracy < 1000 {
            locationManager.stopUpdatingLocation()
            // save to Firebase
            print(userLocation)
        }
    }

    // MARK: NSUserDefaults Functions
    func storeFacebookAuthState() {
        if (defaults.objectForKey("User ID") == nil){
            performSegueWithIdentifier("signUpSegue", sender: self)
        } else {
            print("MAIN FEED VC: The user is logged in.")
            let currentUserId = defaults.valueForKey("User ID") as! String
            fetchUserInformation(currentUserId)
            locationManager.delegate = self
            getUserLocation()
            return
        }
    }
    
    // MARK: Firebase Functions
//    func fetchUserInformation(userID:String) {
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
//            let userRef = self.ref.childByAppendingPath("/users")
//            userRef.queryOrderedByChild("facebookID").queryEqualToValue(userID).observeEventType(.Value, withBlock: { snapshot in
//                guard let value = snapshot.value as? [NSObject: AnyObject], user = value[userID] as? [NSObject: AnyObject] else { return }
//                
//                let userName = user["name"] as? String ?? "It isn't working"
//                let profilePictureURL = user["profilePictureURL"] as? String ?? "It isn't working"
//                
//                let completeUser = User(userId: userID, name: userName, profilePicture: profilePictureURL)//latitude: defaults.objectForKey("Saved Location"))
//                self.usersArray.append(completeUser)
//                let currentUserId = self.defaults.valueForKey("User ID")
//                completeUser.userId = currentUserId as! String
//                if (completeUser.userId == currentUserId as! String) {
//                    self.usersArray.insert(completeUser, atIndex: 0)
//                    print(self.usersArray)
//                }
//                
//                dispatch_async(dispatch_get_main_queue()) {
//                    self.tableView.reloadData()
//                }
//            })
//        }
//        
//    }
    
        func fetchUserInformation(userID:String) {
            let userRef = self.ref.childByAppendingPath("/users")
            userRef.queryOrderedByChild("facebookID").queryEqualToValue(userID).observeEventType(.Value, withBlock: { snapshot in
//                  self.ref.queryOrderedByKey().queryEqualToValue("child_added").observeEventType(.Value, withBlock: { snapshot in
                    guard let value = snapshot.value as? [NSObject: AnyObject], user = value[userID] as? [NSObject: AnyObject] else { return }
    
                    let userName = user["name"] as? String ?? "It isn't working"
                    let profilePictureURL = user["profilePictureURL"] as? String ?? "It isn't working"
    
                    let completeUser = User(userId: userID, name: userName, profilePicture: profilePictureURL)//latitude: defaults.objectForKey("Saved Location"))
//                    self.usersArray.append(completeUser)
                    let currentUserId = self.defaults.valueForKey("User ID")
                    completeUser.userId = currentUserId as! String
                    if (completeUser.userId == currentUserId as! String) {
                        self.usersArray.insert(completeUser, atIndex: 0)
                        print(self.usersArray)
                    }
    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.tableView.reloadData()
                    }
                })
            }
            
        }

func fetchAllUsers() {
    let userRef = ref.childByAppendingPath("/users")
    userRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
        
    })
}


    
// end of VC
