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
import MapKit

class MainfeedVC: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Constants
    let defaults = NSUserDefaults.standardUserDefaults()
    let ref = Firebase(url: "https://bestieapp.firebaseio.com")
    let region = CLCircularRegion()
    let centerLocation =  CLLocation()
    
    // MARK: Variables
    var locationManager = CLLocationManager()
    var userLocation = CLLocation()
    var usersArray = [User]()
    var selectedUserId = String()
    var userLocationExists : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        region = CLCircularRegion(center: centerLocation, radius: 80467.2, identifier: "San Francisco Bay Area")
        
    }
    
    override func viewWillAppear(animated: Bool) {
        self.usersArray = [User]()
        storeFacebookAuthStateAndFetchUsers()
        tableView.reloadData()
    }
    
    override func viewWillDisappear(animated: Bool) {
        ref.childByAppendingPath("users").removeAllObservers()
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
        if userLocation.verticalAccuracy < 1000 && userLocation.horizontalAccuracy < 1000 && !userLocationExists {
            manager.stopUpdatingLocation()
            userLocationExists = true
            print("User Location:", userLocation)
            
            //save user location to Firebase
            let userID = self.defaults.valueForKey("User ID") as! String
            let latitudeForFirebase = ["latitude": userLocation.coordinate.latitude]
            let longitudeForFirebase = ["longitude": userLocation.coordinate.longitude]
            
            let userRef = ref.childByAppendingPath("/users")
            userRef.childByAppendingPath(userID).updateChildValues(latitudeForFirebase)
            userRef.childByAppendingPath(userID).updateChildValues(longitudeForFirebase)
        }
    }
    
    func checkUserWithinGeofence(centerLocation: CLLocation, usersLocation:CLLocation) -> Bool{
        
        let distanceBetweenPoints = centerLocation.distanceFromLocation(usersLocation)
        if distanceBetweenPoints > region.radius {
            removeIneligibleUser()
        }else {
            fetchAllUsersAndPutCurrentUserAtIndex0()
        }
    }
    
    func removeIneligibleUser(){

        let currentUserID = self.defaults.valueForKey("User ID") as? String
        let userRef = ref.childByAppendingPath("/users")
        
        userRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            for user in snapshot.children {
                
                let userName = user.value!!["name"] as? String ?? "username isn't working"
                let profilePictureURL = user.value!!["profilePictureURL"] as? String ?? "profile picture isn't working"
                let gender = user.value!!["gender"]
                let latitude = user.value!!["latitude"]
                let longitude = user.value!!["longitude"]
                let bio = user.value!!["bio"]
                let userId = user.value!!["facebookID"] as? String ?? "userId isn't working"
                
                let completeUser = User(userId: userId, name: userName, profilePicture: profilePictureURL, gender: gender, latitude: latitude, longitude: longitude, bio: bio)
                
                // adds ineligible user from user bucket to ineligible bucket
                let ineligibleUserRef = ref.childByAppendingPath("ineligible")
                ineligibleUserRef.childByAppendingPath(completeUser)
            }
        })
        // removes user now in ineligible bucket from user bucket
        userRef.childByAppendingPath(currentUserID).removeValue()
    }
    
    // MARK: NSUserDefaults Functions
    func storeFacebookAuthStateAndFetchUsers() {
        if (defaults.objectForKey("User ID") == nil){
            performSegueWithIdentifier("signUpSegue", sender: self)
        } else {
            print("MAIN FEED VC: The user is logged in.")
            if (userLocationExists == false) {
                locationManager.delegate = self
                getUserLocation()
            }
            //            return
            centerLocation = CLLocation(latitude: 37.790766, longitude: -122.401998)
            checkUserWithinGeofence(centerLocation, usersLocation: userLocation)
            // fetchAllUsersAndPutCurrentUserAtIndex0()
        }
    }
    
    func fetchAllUsersAndPutCurrentUserAtIndex0() {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let userRef = self.ref.childByAppendingPath("/users")
            self.usersArray = [User]()
            userRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
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
                    let userId = user.value!!["facebookID"] as? String ?? "userId isn't working"
                    let completeUser = User(userId: userId, name: userName, profilePicture: profilePictureURL, gender: gender, latitude: latitude, longitude: longitude, bio: bio)
                    
                    if ("\(completeUser.userId)") == self.defaults.valueForKey("User ID") as! String {
                        self.usersArray.insert(completeUser, atIndex: 0)
                    } else {
                        
                        let princessPointRef = self.ref.childByAppendingPath("/princessPoints")
                        princessPointRef.childByAppendingPath(currentUserID).childByAppendingPath("/rejected").observeSingleEventOfType(.Value, withBlock: { (snapshot) -> Void in
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