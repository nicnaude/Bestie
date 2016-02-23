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
    
    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Constants
    let defaults = NSUserDefaults.standardUserDefaults()
    let ref = Firebase(url: "https://bestieapp.firebaseio.com")
    
    // MARK: Variables
    var locationManager = CLLocationManager()
    var userLocation = CLLocation()
    var usersArray = [User]()
    var selectedUserId = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        storeFacebookAuthStateAndFetchUsers()

    }
    
    override func viewWillAppear(animated: Bool) {
        self.tableView.reloadData()
        storeFacebookAuthStateAndFetchUsers()

    }
    
    // MARK: TableViewController Delegate Functions
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.usersArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let userCell = tableView.dequeueReusableCellWithIdentifier("userCell") as! UserCell
        let currentUser = usersArray[indexPath.row] as User
        userCell.textLabel?.text = currentUser.name
        
        return userCell
    }
    
    // MARK: Location Services Function
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
    func storeFacebookAuthStateAndFetchUsers() {
        if (defaults.objectForKey("User ID") == nil){
            performSegueWithIdentifier("signUpSegue", sender: self)
        } else {
            print("MAIN FEED VC: The user is logged in.")
            fetchAllUsersAndPutCurrentUserAtIndex0()
            locationManager.delegate = self
            getUserLocation()
            return
        }
    }
    
    // MARK: Firebase Functions
    func fetchAllUsersAndPutCurrentUserAtIndex0() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let userRef = self.ref.childByAppendingPath("/users")
            userRef.observeEventType(.Value, withBlock: { snapshot in
                self.usersArray = [User]()
                for user in snapshot.children {
                    print(snapshot.children)
                    
                    let userKey = user.key
                    let currentUserID = self.defaults.valueForKey("User ID") as? String
                    
                    let userName = user.value!!["name"] as? String ?? "username isn't working"
                    let profilePictureURL = user.value!!["profilePictureURL"] as? String ?? "profile picture isn't working"
                    let gender = "gender"
                    let latitude = 1.1
                    let longitude = 1.1
                    let bio = "bio"
                    //                    let princessPoint = 1
                    let userId = user.value!!["facebookID"] as? String ?? "userId isn't working"
                    let completeUser = User(userId: userId, name: userName, profilePicture: profilePictureURL, gender: gender, latitude: latitude, longitude: longitude, bio: bio) //princessPoint: princessPoint)
                    
                    if ("\(completeUser.userId)") == self.defaults.valueForKey("User ID") as! String {
                        self.usersArray.insert(completeUser, atIndex: 0)
                    } else {
                        
                        let princessPointRef = self.ref.childByAppendingPath("/princessPoints")
                        princessPointRef.childByAppendingPath(currentUserID).childByAppendingPath("/rejected").observeEventType(.Value, withBlock: { (snapshot) -> Void in
                            if snapshot.exists() {
                                var rejected = false
                                for child in snapshot.children{
                                    if(child.key == userKey){
                                        rejected = true
                                    }
                                }
                                if rejected == false {
                                    self.usersArray.append(completeUser)
                                }

                            }else{
                                self.usersArray.append(completeUser)
                            }
                            dispatch_async(dispatch_get_main_queue()) {
                                self.tableView.reloadData()
                            }
                        })
                    }
                    dispatch_async(dispatch_get_main_queue()) {
                        self.tableView.reloadData()
                    }
                }
            })
        }
    }
    
//    func checkBestieRejectionStatus() {
//        
//        guard let userID = self.defaults.valueForKey("User ID") as? String else { return }
//        let childRef = ref.childByAppendingPath("/princessPoints")
//        let userRef = childRef.childByAppendingPath(userID)
//        
//        userRef.childByAppendingPath("rejected").observeSingleEventOfType(.Value , withBlock: { snapshot in
//            for child in snapshot.children {
//                let child = child.value!!["rejected"]
//                for user in self.usersArray {
//                    if (child == user) {
//                        self.usersArray.insert(child , atIndex: 0)
//                        self.usersArray.removeAtIndex(0)
//                        print("Updated Table View:", self.usersArray)
//                    }
//                }
//            }
//        })
//    }
    
    // take a snapshot of everyone in User ID's reject bucket
    // check the global user array in the tableview and remove the user that's in the reject bucket
    
    // MARK: Segue Functions
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "signUpSegue") {
        } else if (segue.identifier == "profileSegue") {
            let destinationProfileVc = segue.destinationViewController as! ProfileVC
            let indexPath = tableView.indexPathForSelectedRow
            let selectedCell = usersArray[(indexPath?.row)!]
            let selectedUserIdinMainVc = selectedCell.userId
            destinationProfileVc.selectedUserId = selectedUserIdinMainVc
        } else if (segue.identifier == "moreSegue") {
        } else  if (segue.identifier == "chatHomeSegue") {
        }
    }
    
    @IBAction func unwindSegueMainFeedVC(segue:UIStoryboardSegue) {
        
    }
    
    @IBAction func savePlayerDetail(segue:UIStoryboardSegue) {
        
    }
    
}