import UIKit
import Firebase
import CoreLocation
import MapKit
import QuartzCore

class MainfeedVC: UIViewController, CLLocationManagerDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    
    // MARK: Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: Constants
    let defaults = UserDefaults.standard
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
        addBestieLogo()
        
        // STEP 1
        centerLocation = CLLocation(latitude: 37.790766, longitude: -122.401998)
        region = CLCircularRegion(center: centerLocation.coordinate, radius: 10000000.5, identifier: "San Francisco Bay Area") // original distance was 80467.2
        
        // Set UI colors
        navigationController!.navigationBar.barTintColor = UIColor.white
        view?.backgroundColor = UIColor.bestiePurple()
        
        locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()
        collectionView.reloadData()
    }//
    

    override func viewWillAppear(_ animated: Bool) {
        collectionView.reloadData()
        getUserLocation() //Commented out in order for Nicholas to test out in London
    }//
    
    
    override func viewDidLayoutSubviews() {
        
    }//
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        getUserLocation() //Commented out in order for Nicholas to test out in London
    }//
    
    
    override func viewWillDisappear(_ animated: Bool) {
        ref?.child(byAppendingPath: "users").removeAllObservers()
    }//
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations.first!
        if userLocation.verticalAccuracy < 1000 && userLocation.horizontalAccuracy < 1000 && !userLocationExists {
            manager.stopUpdatingLocation()
            userLocationExists = true
            print("User Location:", userLocation)
            
            tempLat = userLocation.coordinate.latitude
            tempLong = userLocation.coordinate.longitude
            self.checkForUserAndEligibility()
        }
    }//
    
    
    // MARK: STEP 3
    func checkUserWithinGeofence(_ centerLocation: CLLocation, usersLocation:CLLocation){
        
        let distanceBetweenPoints = centerLocation.distance(from: usersLocation)
        if distanceBetweenPoints > region.radius { // Outside the geofence.
            if (userExists == true && userIsIneligible == false) {
                
                // go pull from users and push to ineligible and segue to sorry
                removeFromUsersAddToIneligible()
            } else if (userExists == false && userIsIneligible == true) {
                
                // do nothing and segue to sorry page
                performSegue(withIdentifier: "ineligibleVc", sender: self)
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
    }//
    
    
    func removeFromUsersAddToIneligible() {
        
        let currentUserID = self.defaults.value(forKey: "User ID") as? String
        let userRef = ref?.child(byAppendingPath: "/users")
        
        userRef?.observeSingleEvent(of: .value, with: { snapshot in
            for user in (snapshot?.children)! {
                if ((user as AnyObject).key == currentUserID) {
                    
                    let userName = (user as AnyObject).value!!["name"] as? String ?? "username isn't working"
                    let profilePictureURL = (user as AnyObject).value!!["profilePictureURL"] as? String ?? "profile picture isn't working"
                    let gender = (user as AnyObject).value!!["gender"] as! String
                    let latitude = (user as AnyObject).value!!["latitude"] as! Double
                    let longitude = (user as AnyObject).value!!["longitude"] as! Double
                    let bio = (user as AnyObject).value!!["bio"] as! String
                    let userId = (user as AnyObject).value!!["facebookID"] as? String ?? "userId isn't working"
                    
                    let completeUser = ["facebookID": userId, "name": userName, "profilePictureURL": profilePictureURL, "gender": gender, "latitude": latitude, "longitude": longitude, "bio": bio]
                    
                    let ineligibleUserRef = self.ref?.child(byAppendingPath: "/ineligible")
                    ineligibleUserRef.child(byAppendingPath: currentUserID).updateChildValues(completeUser as [AnyHashable: Any])
                    userRef?.child(byAppendingPath: currentUserID).removeValue()
                } else {
                }
            }
        })
    }//
    
    
    func removeFromIneligibleAddToUsers() {
        
        let currentUserID = self.defaults.value(forKey: "User ID") as? String
        let ineligibleRef = ref?.child(byAppendingPath: "/ineligible")
        
        ineligibleRef?.observeSingleEvent(of: .value, with: { snapshot in
            for user in (snapshot?.children)! {
                if ((user as AnyObject).key == currentUserID) {
                    let userName = (user as AnyObject).value!!["name"] as? String ?? "username isn't working"
                    let profilePictureURL = (user as AnyObject).value!!["profilePictureURL"] as? String ?? "profile picture isn't working"
                    let gender = (user as AnyObject).value!!["gender"] as! String
                    let latitude = (user as AnyObject).value!!["latitude"] as! Double
                    let longitude = (user as AnyObject).value!!["longitude"] as! Double
                    let bio = (user as AnyObject).value!!["bio"] as! String
                    let userId = (user as AnyObject).value!!["facebookID"] as? String ?? "userId isn't working"
                    
                    let completeUser = ["facebookID": userId, "name": userName, "profilePictureURL": profilePictureURL, "gender": gender, "latitude": latitude, "longitude": longitude, "bio": bio]
                    
                    let userRef = self.ref?.child(byAppendingPath: "/users")
                    userRef.child(byAppendingPath: currentUserID).updateChildValues(completeUser as [AnyHashable: Any])
                    ineligibleRef?.child(byAppendingPath: currentUserID).removeValue()
                    
                } else {
                }
            }
        })
        fetchAllUsersAndPutCurrentUserAtIndex0()
    }//
    
    
    func addNewUserToUsers() {
        
        let currentUserID = self.defaults.value(forKey: "User ID") as? String
        let userRef = self.ref?.child(byAppendingPath: "/users")
        
        let userId = CurrentUser.userId
        let name = CurrentUser.name
        let profilePictureURL = CurrentUser.profilePicture
        let gender = CurrentUser.gender
        let bio = CurrentUser.bio
        let latitude = CurrentUser.latitude
        let longitude = CurrentUser.longitude
        
        let newUserForUsers = ["name": name, "profilePictureURL": profilePictureURL, "gender": gender, "latitude": latitude, "longitude": longitude, "bio": bio, "facebookID": userId] as [String : Any]
        
        userRef?.child(byAppendingPath: currentUserID).updateChildValues(newUserForUsers as [AnyHashable: Any])
        fetchAllUsersAndPutCurrentUserAtIndex0()
    }//
    
    
    func addNewUserToIneligilbe() {
        
        let currentUserID = self.defaults.value(forKey: "User ID") as? String
        
        let ineligibleUserRef = self.ref?.child(byAppendingPath: "/ineligible")
        
        let userId = CurrentUser.userId
        let name = CurrentUser.name
        let profilePictureURL = CurrentUser.profilePicture
        let gender = CurrentUser.gender
        let bio = CurrentUser.bio
        let latitude = CurrentUser.latitude
        let longitude = CurrentUser.longitude
        
        let newUserForIneligible = ["name": name, "profilePictureURL": profilePictureURL, "gender": gender, "latitude": latitude, "longitude": longitude, "bio": bio, "facebookID": userId] as [String : Any]
        
        ineligibleUserRef?.child(byAppendingPath: currentUserID).updateChildValues(newUserForIneligible as [AnyHashable: Any])
    }//
    
    
    // STEP 2
    // MARK: NSUserDefaults Functions
    func checkForUserAndEligibility() {
        if (defaults.object(forKey: "User ID") == nil) {
            isFirstLogin = true
            performSegue(withIdentifier: "signUpSegue", sender: self)
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
    }//
    
    
    func populateCurrentUser(_ completionHandler:@escaping () -> ()) {
        
        let currentUserID = self.defaults.value(forKey: "User ID") as? String
        let userRef = self.ref?.child(byAppendingPath: "/users").child(byAppendingPath: currentUserID)
        userRef?.observeSingleEvent(of: .value, with: { snapshot in
            print(snapshot?.children)
            
            let userName = snapshot?.value!["name"] as? String ?? "username isn't working"
            let profilePictureURL = snapshot?.value!["profilePictureURL"] as? String ?? "profile picture isn't working"
            let gender = snapshot?.value!["gender"] as! String
            let latitude = snapshot?.value!["latitude"] as! Double
            let longitude = snapshot?.value!["longitude"] as! Double
            let bio = snapshot?.value!["bio"] as! String
            let userId = snapshot?.value!["facebookID"] as? String ?? "userId isn't working"
            
            CurrentUser.createNewUser(userId, name: userName, profilePicture: profilePictureURL, gender: gender, latitude: latitude, longitude: longitude, bio: bio)
            self.usersArray.append(CurrentUser)
            completionHandler()
        })
    }//
    
    
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.usersArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let userCell = collectionView.dequeueReusableCell(withReuseIdentifier: "UserCell", for: indexPath) as! UserCell
        let currentUser = usersArray[(indexPath as NSIndexPath).row] as User
        let url = URL(string: currentUser.profilePicture)
        let data = try? Data(contentsOf: url!)
        userCell.imageView.image = UIImage(data: data!)
        userCell.layer.borderWidth = 1.0
        userCell.layer.masksToBounds = false
        userCell.layer.borderColor = UIColor.white.cgColor
        userCell.layer.cornerRadius = userCell.frame.size.width/2
        userCell.clipsToBounds = true
        //}
        return userCell
    }//
    
    
    // MARK: Location Services Function
    func getUserLocation() {
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.startUpdatingLocation()
    }//
    
    
    func doesUserExistInUserBucket() {
        
        let currentUserID = self.defaults.value(forKey: "User ID") as? String
        let userRef = ref?.child(byAppendingPath: "/users")
        userRef?.observeSingleEvent(of: .value, with: { snapshot in
            for data in (snapshot?.children)! {
                if ((data as AnyObject).key! == currentUserID!) {
                    self.userExists = true
                    break
                } else {
                    self.userExists = false
                }
            }
        })
    }//
    
    
    func doesUserExistinIneligibleBucket() {
        
        let currentUserID = self.defaults.value(forKey: "User ID") as? String
        let ineligibleRef = ref?.child(byAppendingPath: "/ineligible")
        ineligibleRef?.observeSingleEvent(of: .value, with: { snapshot in
            for data in (snapshot?.children)! {
                if ((data as AnyObject).key! == currentUserID!) {
                    self.userExists = true
                    break
                } else {
                    self.userExists = false
                }
            }
        })
    }//
    
    
    func fetchAllUsersAndPutCurrentUserAtIndex0() {
        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.default).async {
            let userRef = self.ref?.child(byAppendingPath: "/users")
            self.usersArray = [User]()
            userRef?.observeSingleEvent(of: .value, with: { snapshot in
                for user in (snapshot?.children)! {
                    print(snapshot?.children)
                    
                    let userKey = (user as AnyObject).key
                    let currentUserID = self.defaults.value(forKey: "User ID") as? String
                    
                    let userName = (user as AnyObject).value!!["name"] as? String ?? "Username unavailable."
                    let profilePictureURL = (user as AnyObject).value!!["profilePictureURL"] as? String ?? "Profile picture unavailable."
                    let gender = (user as AnyObject).value!!["gender"] as? String ?? "Gender unavailable."
                    let latitude = (user as AnyObject).value!!["latitude"] as? Double
                    let longitude = (user as AnyObject).value!!["longitude"] as? Double
                    let bio = (user as AnyObject).value!!["bio"] as? String ?? "Bio unavailable."
                    let userId = (user as AnyObject).value!!["facebookID"] as? String ?? "userId isn't working"
                    let completeUser = User()
                    completeUser.createNewUser(userId, name: userName, profilePicture: profilePictureURL, gender: gender, latitude: latitude!, longitude: longitude!, bio: bio)
                    
                    if ("\(completeUser.userId)") == self.defaults.value(forKey: "User ID") as! String {
                        self.usersArray.insert(completeUser, at: 0)
                    } else {
                        
                        let princessPointRef = self.ref?.child(byAppendingPath: "/princessPoints")
                        princessPointRef?.child(byAppendingPath: currentUserID).child(byAppendingPath: "/rejected").observeSingleEvent(of: .value, with: { (snapshot) -> Void in
                            if snapshot?.exists() {
                                var rejected = false
                                for child in snapshot?.children{
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
                            DispatchQueue.main.async {
                                self.collectionView.reloadData()
                            }
                        })
                    }
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                }
            })
        }
    }//
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "profileSegue", sender: collectionView.cellForItem(at: indexPath))
    }//
    
    
    // MARK: Segue Functions
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "signUpSegue") {
            let signupVc = segue.destination as! SignUpVC
            signupVc.tempLat = tempLat
            signupVc.tempLong = tempLong
        } else if (segue.identifier == "profileSegue") {
            let cell = sender as! UserCell
            let destinationProfileVc = segue.destination as! ProfileVC
            let selectedCell = usersArray[((self.collectionView.indexPath(for: cell))! as NSIndexPath).row]
            let selectedUserIdinMainVc = selectedCell.userId
            destinationProfileVc.selectedUserId = selectedUserIdinMainVc
            let _ = destinationProfileVc.view
        } else if (segue.identifier == "moreSegue") {
        } else  if (segue.identifier == "chatHomeSegue") {
        }
    }//
    
    
    //layout collectionview cell
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        
        let numberOfCell: CGFloat = 3.5   //you need to give a type as CGFloat
        let cellWidth = UIScreen.main.bounds.size.width / numberOfCell
        return CGSize(width: cellWidth, height: cellWidth)
    }//

    
    @IBAction func unwindSegueMainFeedVC(_ segue:UIStoryboardSegue) {
        
    }//
    
    
    @IBAction func savePlayerDetail(_ segue:UIStoryboardSegue) {
        
    }//
    
} ///
