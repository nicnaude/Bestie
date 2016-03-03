import UIKit
import Firebase
import CoreLocation
import MapKit
import QuartzCore

class MainfeedVC: UIViewController, CLLocationManagerDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    
    // MARK: Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: Constants
    let defaults = NSUserDefaults.standardUserDefaults()
    let ref = Firebase(url: "https://bestieapp.firebaseio.com")
     
    // MARK: Variables
    var usersArray = [User]()
    var selectedUserId = String()
    
    // MARK: Location variables
    var region = CLCircularRegion()
    var centerLocation =  CLLocation()
    var userLocationExists : Bool = false
    var userLocation = CLLocation()
    var locationManager = CLLocationManager()
    var tempLat = CLLocationDegrees()
    var tempLong = CLLocationDegrees()
    var isFirstLogin = Bool()
    var userExists = Bool()
    var userIsIneligible = Bool()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.usersArray = [User]()
        
        setUpUI()
        
         UITabBar.appearance().tintColor = UIColor.bestiePurple()
        
        // STEP 1
        centerLocation = CLLocation(latitude: 37.790766, longitude: -122.401998)
        region = CLCircularRegion(center: centerLocation.coordinate, radius: 80467.2, identifier: "San Francisco Bay Area")
        
        // Set UI colors
        navigationController!.navigationBar.barTintColor = UIColor.whiteColor()
        view?.backgroundColor = UIColor.bestiePurple()
        
        locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()
        collectionView.reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        collectionView.reloadData()
        getUserLocation()
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        getUserLocation()
    }
    
    override func viewWillDisappear(animated: Bool) {
        ref.childByAppendingPath("users").removeAllObservers()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations.first!
        if userLocation.verticalAccuracy < 1000 && userLocation.horizontalAccuracy < 1000 && !userLocationExists {
            manager.stopUpdatingLocation()
            userLocationExists = true
            print("User Location:", userLocation)
            
            tempLat = userLocation.coordinate.latitude
            tempLong = userLocation.coordinate.longitude
            self.checkForUserAndEligibility()
        }
    }
    
    // MARK: STEP 3
    func checkUserWithinGeofence(centerLocation: CLLocation, usersLocation:CLLocation){
        
        let distanceBetweenPoints = centerLocation.distanceFromLocation(usersLocation)
        if distanceBetweenPoints > region.radius { // Outside the geofence.
            if (userExists == true && userIsIneligible == false) {
                
                // go pull from users and push to ineligible and segue to sorry
                removeFromUsersAddToIneligible()
            } else if (userExists == false && userIsIneligible == true) {
                
                // do nothing and segue to sorry page
                performSegueWithIdentifier("ineligibleVc", sender: self)
            } else if (userExists == false && userIsIneligible == false) {
                
                // user is new, just push to ineligible and segue to sorry
                addNewUserToIneligilbe()
            }
        } else if (distanceBetweenPoints < region.radius) { // Inside the geofence.
            if (userExists == true && userIsIneligible == false) {
                
                // user exists already, go fetch all users
                fetchAllUsersAndPutCurrentUserAtIndex0()
            } else if (userExists == false && userIsIneligible == true) {
                
                // move user from ineligible bucket to user bucket
                removeFromIneligibleAddToUsers()
            } else if (userExists == false && userIsIneligible == false) {
                
                // user is new, push to users
                addNewUserToUsers()
            }
        }
    }
    
    func removeFromUsersAddToIneligible() {
        
        let currentUserID = self.defaults.valueForKey("User ID") as? String
        let userRef = ref.childByAppendingPath("/users")
        
        userRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            for user in snapshot.children {
                if (user.key == currentUserID) {
                    
                    let userName = user.value!!["name"] as? String ?? "username isn't working"
                    let profilePictureURL = user.value!!["profilePictureURL"] as? String ?? "profile picture isn't working"
                    let gender = user.value!!["gender"] as! String
                    let latitude = user.value!!["latitude"] as! Double
                    let longitude = user.value!!["longitude"] as! Double
                    let bio = user.value!!["bio"] as! String
                    let userId = user.value!!["facebookID"] as? String ?? "userId isn't working"
                    
                    let completeUser = ["facebookID": userId, "name": userName, "profilePictureURL": profilePictureURL, "gender": gender, "latitude": latitude, "longitude": longitude, "bio": bio]
                    
                    let ineligibleUserRef = self.ref.childByAppendingPath("/ineligible")
                    ineligibleUserRef.childByAppendingPath(currentUserID).updateChildValues(completeUser as [NSObject : AnyObject])
                    userRef.childByAppendingPath(currentUserID).removeValue()
                } else {
                }
            }
        })
    }
    
    func removeFromIneligibleAddToUsers() {
        
        let currentUserID = self.defaults.valueForKey("User ID") as? String
        let ineligibleRef = ref.childByAppendingPath("/ineligible")
        
        ineligibleRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            for user in snapshot.children {
                if (user.key == currentUserID) {
                    let userName = user.value!!["name"] as? String ?? "username isn't working"
                    let profilePictureURL = user.value!!["profilePictureURL"] as? String ?? "profile picture isn't working"
                    let gender = user.value!!["gender"] as! String
                    let latitude = user.value!!["latitude"] as! Double
                    let longitude = user.value!!["longitude"] as! Double
                    let bio = user.value!!["bio"] as! String
                    let userId = user.value!!["facebookID"] as? String ?? "userId isn't working"
                    
                    let completeUser = ["facebookID": userId, "name": userName, "profilePictureURL": profilePictureURL, "gender": gender, "latitude": latitude, "longitude": longitude, "bio": bio]
                    
                    let userRef = self.ref.childByAppendingPath("/users")
                    userRef.childByAppendingPath(currentUserID).updateChildValues(completeUser as [NSObject : AnyObject])
                    ineligibleRef.childByAppendingPath(currentUserID).removeValue()
                    
                } else {
                }
            }
        })
        fetchAllUsersAndPutCurrentUserAtIndex0()
    }
    
    func addNewUserToUsers() {
        
        let currentUserID = self.defaults.valueForKey("User ID") as? String
        let userRef = self.ref.childByAppendingPath("/users")
        
        let userId = CurrentUser.userId
        let name = CurrentUser.name
        let profilePictureURL = CurrentUser.profilePicture
        let gender = CurrentUser.gender
        let bio = CurrentUser.bio
        let latitude = CurrentUser.latitude
        let longitude = CurrentUser.longitude
        
        let newUserForUsers = ["name": name, "profilePictureURL": profilePictureURL, "gender": gender, "latitude": latitude, "longitude": longitude, "bio": bio, "facebookID": userId]
        
        userRef.childByAppendingPath(currentUserID).updateChildValues(newUserForUsers as [NSObject : AnyObject])
        fetchAllUsersAndPutCurrentUserAtIndex0()
    }
    
    func addNewUserToIneligilbe() {
        
        let currentUserID = self.defaults.valueForKey("User ID") as? String
        
        let ineligibleUserRef = self.ref.childByAppendingPath("/ineligible")
        
        let userId = CurrentUser.userId
        let name = CurrentUser.name
        let profilePictureURL = CurrentUser.profilePicture
        let gender = CurrentUser.gender
        let bio = CurrentUser.bio
        let latitude = CurrentUser.latitude
        let longitude = CurrentUser.longitude
        
        let newUserForIneligible = ["name": name, "profilePictureURL": profilePictureURL, "gender": gender, "latitude": latitude, "longitude": longitude, "bio": bio, "facebookID": userId]
        
        ineligibleUserRef.childByAppendingPath(currentUserID).updateChildValues(newUserForIneligible as [NSObject : AnyObject])
    }
    
    // STEP 2
    // MARK: NSUserDefaults Functions
    func checkForUserAndEligibility() {
        if (defaults.objectForKey("User ID") == nil) {
            isFirstLogin = true
            performSegueWithIdentifier("signUpSegue", sender: self)
            print("MAIN FEED VC: User is NOT logged in.")
        } else {
            if CurrentUser.name == "" {
                populateCurrentUser({ () -> () in
                    print("MAIN FEED VC: User is logged in.")
                    self.doesUserExistinIneligibleBucket()
                    self.doesUserExistInUserBucket()
                    // STEP 3
                    self.checkUserWithinGeofence(self.centerLocation, usersLocation: self.userLocation)
                })
            } else {
                print("MAIN FEED VC: User is logged in.")
                self.doesUserExistinIneligibleBucket()
                self.doesUserExistInUserBucket()
                // STEP 3
                self.checkUserWithinGeofence(self.centerLocation, usersLocation: self.userLocation)
            }
        }
    }
    
    func populateCurrentUser(completionHandler:() -> ()) {
        
        let currentUserID = self.defaults.valueForKey("User ID") as? String
        let userRef = self.ref.childByAppendingPath("/users").childByAppendingPath(currentUserID)
        userRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            print(snapshot.children)
            
            let userName = snapshot.value!["name"] as? String ?? "username isn't working"
            let profilePictureURL = snapshot.value!["profilePictureURL"] as? String ?? "profile picture isn't working"
            let gender = snapshot.value!["gender"] as! String
            let latitude = snapshot.value!["latitude"] as! Double
            let longitude = snapshot.value!["longitude"] as! Double
            let bio = snapshot.value!["bio"] as! String
            let userId = snapshot.value!["facebookID"] as? String ?? "userId isn't working"
            
            CurrentUser.createNewUser(userId, name: userName, profilePicture: profilePictureURL, gender: gender, latitude: latitude, longitude: longitude, bio: bio)
            self.usersArray.append(CurrentUser)
            completionHandler()
        })
    }
    
    // MARK: TableViewController Delegate Functions
    //    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    //        return self.usersArray.count
    //    }
    
    //    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    //
    //        let userCell = tableView.dequeueReusableCellWithIdentifier("userCell") as! UserCell
    //        let currentUser = usersArray[indexPath.row] as User
    //        userCell.textLabel?.text = currentUser.name
    //
    //        return userCell
    //    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.usersArray.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let userCell = collectionView.dequeueReusableCellWithReuseIdentifier("UserCell", forIndexPath: indexPath) as! UserCell
        let currentUser = usersArray[indexPath.row] as User
        let url = NSURL(string: currentUser.profilePicture)
        let data = NSData(contentsOfURL: url!)
        userCell.imageView.image = UIImage(data: data!)
        userCell.layer.borderWidth = 1.0
        userCell.layer.masksToBounds = false
        userCell.layer.borderColor = UIColor.whiteColor().CGColor
        userCell.layer.cornerRadius = userCell.frame.size.width/2
        userCell.clipsToBounds = true
        //}
        return userCell
    }
    
    // MARK: Location Services Function
    func getUserLocation() {
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.startUpdatingLocation()
    }
    
    func doesUserExistInUserBucket() {
        
        let currentUserID = self.defaults.valueForKey("User ID") as? String
        let userRef = ref.childByAppendingPath("/users")
        userRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            for data in snapshot.children {
                if (data.key! == currentUserID!) {
                    self.userExists = true
                    break
                } else {
                    self.userExists = false
                }
            }
        })
    }
    
    func doesUserExistinIneligibleBucket() {
        
        let currentUserID = self.defaults.valueForKey("User ID") as? String
        let ineligibleRef = ref.childByAppendingPath("/ineligible")
        ineligibleRef.observeSingleEventOfType(.Value, withBlock: { snapshot in
            for data in snapshot.children {
                if (data.key! == currentUserID!) {
                    self.userExists = true
                    break
                } else {
                    self.userExists = false
                }
            }
        })
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
                    
                    let userName = user.value!!["name"] as? String ?? "Username unavailable."
                    let profilePictureURL = user.value!!["profilePictureURL"] as? String ?? "Profile picture unavailable."
                    let gender = user.value!!["gender"] as? String ?? "Gender unavailable."
                    let latitude = user.value!!["latitude"] as? Double
                    let longitude = user.value!!["longitude"] as? Double
                    let bio = user.value!!["bio"] as? String ?? "Bio unavailable."
                    let userId = user.value!!["facebookID"] as? String ?? "userId isn't working"
                    let completeUser = User()
                    completeUser.createNewUser(userId, name: userName, profilePicture: profilePictureURL, gender: gender, latitude: latitude!, longitude: longitude!, bio: bio)
                    
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
                                self.collectionView.reloadData()
                            }
                        })
                    }
                    dispatch_async(dispatch_get_main_queue()) {
                        self.collectionView.reloadData()
                    }
                }
            })
        }
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("profileSegue", sender: collectionView.cellForItemAtIndexPath(indexPath))
    }
    
    // MARK: Segue Functions
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "signUpSegue") {
            let signupVc = segue.destinationViewController as! SignUpVC
            signupVc.tempLat = tempLat
            signupVc.tempLong = tempLong
        } else if (segue.identifier == "profileSegue") {
            let cell = sender as! UserCell
            let destinationProfileVc = segue.destinationViewController as! ProfileVC
            let selectedCell = usersArray[(self.collectionView.indexPathForCell(cell))!.row]
            let selectedUserIdinMainVc = selectedCell.userId
            destinationProfileVc.selectedUserId = selectedUserIdinMainVc
            let _ = destinationProfileVc.view
        } else if (segue.identifier == "moreSegue") {
        } else  if (segue.identifier == "chatHomeSegue") {
        }
    }
    
    @IBAction func unwindSegueMainFeedVC(segue:UIStoryboardSegue) {
        
    }
    
    @IBAction func savePlayerDetail(segue:UIStoryboardSegue) {
        
    }
    
}