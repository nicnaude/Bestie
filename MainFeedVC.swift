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
    
    // this creates a connection to Firebase.
    let ref = Firebase(url: "https://bestieapp.firebaseio.com")
    var usersArray = [User]()
    var locationManager = CLLocationManager()
    var userLocation = CLLocation()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        storeFacebookAuthState()
        
    }
    
    
    // MARK: - TableViewController Delegate Functions
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.usersArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("userCell")
        let currentUser = usersArray[indexPath.row] as User
        
        //        let url = NSURL(string: currentUser.profilePicture)
        //        let data = NSData(contentsOfURL: url!)
        //        cell?.imageView?.image = UIImage(data: data!)
        cell?.textLabel?.text = currentUser.name
        
        return cell!
    }

    
    // MARK: Location Services Functions
    //    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    //        locationManager.stopUpdatingLocation()
    //    }
    
    
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
  
//    func getAndStoreUserLocation(location: CLLocation) {
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
//            self.locationManager.requestAlwaysAuthorization()
//            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
//            self.locationManager.startUpdatingLocation()
//        }
//        dispatch_async(dispatch_get_main_queue()) {
//            self.defaults.setObject(location, forKey: "Saved Location")
//        }
//    }
    
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
    func fetchUserInformation(userID:String) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let userRef = self.ref.childByAppendingPath("/users")
            userRef.queryOrderedByChild("facebookID").queryEqualToValue(userID).observeEventType(.Value, withBlock: { snapshot in
                guard let value = snapshot.value as? [NSObject: AnyObject], user = value[userID] as? [NSObject: AnyObject] else { return }
                
                let userName = user["name"] as? String ?? "It isn't working"
                let profilePictureURL = user["profilePictureURL"] as? String ?? "It isn't working"
                
                let completeUser = User(userId: userID, name: userName, profilePicture: profilePictureURL)//latitude: defaults.objectForKey("Saved Location"))
                self.usersArray.append(completeUser)
                
                dispatch_async(dispatch_get_main_queue()) {
                    self.tableView.reloadData()
                }
            })
        }

    }
} // end of VC
