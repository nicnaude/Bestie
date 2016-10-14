//
//  SignUpVC.swift
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
import CoreLocation

class SignUpVC: UIViewController, FBSDKLoginButtonDelegate {
    
    let defaults = UserDefaults.standard
    
    let screenSize: CGRect = UIScreen.main.bounds
    
    // MARK: Location Variables
    var tempLat = CLLocationDegrees()
    var tempLong = CLLocationDegrees()
    
    // MARK: Facebook Variables
    
    var newUser = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        BackendProcessor.backendProcessor.observeFireBaseDatabaseForAuthChanges()
        BackendProcessor.backendProcessor.checkUserAuthenticationState()
        
        let screenWidth = screenSize.width
        let screenHeight = (screenSize.height * 0.33) * 2.2
        let centerOfScreen = (screenSize.width * 0.5) - 100


        // Facebook login
        let loginButton = FBSDKLoginButton()
        loginButton.frame = CGRect(x: centerOfScreen, y: screenHeight, width: 200, height: 40)
        self.view.addSubview(loginButton)
        loginButton.delegate = self
        loginButton.readPermissions = ["public_profile", "email"]
    }
    
    //Get large facebook image:
//    let pictureRequest = FBSDKGraphRequest(graphPath: "me/picture?type=large&redirect=false", parameters: nil)
//    pictureRequest.startWithCompletionHandler({
//    (connection, result, error: NSError!) -> Void in
//    if error == nil {
//    println("\(result)")
//    } else {
//    println("\(error)")
//    }
//    })
    
    
    // FBSDK Delegate Function #1
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        let ref = Firebase(url: "https://bestieapp.firebaseio.com")
        
        if ((error) != nil) {
            print(" There's an error")
        }
        else if result.isCancelled {
            print("login canceled!")
        }
        else {
            
            if (result.grantedPermissions.contains("email") && result.grantedPermissions.contains("public_profile")) {
                
                let accessToken = FBSDKAccessToken.current().tokenString
                ref?.auth(withOAuthProvider: "facebook", token: accessToken,
                    withCompletionBlock: { error, authData in
                        if error != nil {
                            print("Login failed. \(error)")
                        } else {
                            print("Logged in! \(authData)")
                            
                            
                            
                            
                            // Store new user from Facebook locally
                            let provider = authData?.provider
                            let uid = FBSDKAccessToken.current().userID
                            self.defaults.set(uid, forKey:"User ID")
                            let facebookID = authData?.providerData["id"] as! String
                            let name = authData?.providerData["displayName"] as! String
                            // = authData.providerData["profileImageURL"] as! String
                            let cachedUserProfile = authData?.providerData["cachedUserProfile"] as! NSDictionary
                            let picture = cachedUserProfile["picture"] as! NSDictionary
                            let data = picture["data"] as! NSDictionary
                            let gender = "" //cachedUserProfile["gender"]
                            let bio = "What makes you fabulous? Update your profile now."
                            let latitude = self.tempLat
                            let longitude = self.tempLong
                            
                            let request = FBSDKGraphRequest.init(graphPath: "/\(uid)/picture?width=1080&height=1080&redirect=false", parameters: nil)
                            
                            request?.start(completionHandler: {
                                (connection, result, error: NSError!) -> Void in
                                if error == nil {
                                    
                                    let data = result["data"] as! NSDictionary
                                    let profilePictureURL = data["url"] as! String
                                    
                                    print(data)
                                    self.newUser.createNewUser(facebookID, name: name, profilePicture: profilePictureURL, gender: gender, latitude: latitude, longitude: longitude, bio: bio)
                                    CurrentUser = self.newUser
                                } else {
                                    print("hello")
                                }
                            })
                            
                            
                            
                            
                            //                            ref.childByAppendingPath("/users/\(uid)").updateChildValues(newUser as [NSObject : AnyObject])
                            
                        }
                        SessionDefaults.global.userUID = FBSDKAccessToken.current().userID
                        self.performSegue(withIdentifier: "onboardingSegue", sender: nil)
                })
            }
        }
    }
    
    @IBAction func onDismissButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: {});
    }
    
    // FBSDK Delegate Function #2
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("User Logged Out")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "onboardingSegue") {
            
            //            let mainFeedVc = segue.destinationViewController as! MainfeedVC
            //            mainFeedVc.newUserFromSignUp = newUser
        }
    }
}

