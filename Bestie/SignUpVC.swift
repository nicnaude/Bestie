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
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
    // MARK: Location Variables
    var tempLat = CLLocationDegrees()
    var tempLong = CLLocationDegrees()
    
    // MARK: Facebook Variables
    
    var newUser = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        BackendProcessor.backendProcessor.observeFireBaseDatabaseForAuthChanges()
        BackendProcessor.backendProcessor.checkUserAuthenticationState()
        
        // Facebook login test
        let loginButton = FBSDKLoginButton()
        loginButton.center = self.view.center
        self.view.addSubview(loginButton)
        loginButton.delegate = self
        loginButton.readPermissions = ["public_profile", "email"]
        
        
        
    }
    
    // FBSDK Delegate Function #1
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        let ref = Firebase(url: "https://bestieapp.firebaseio.com")
        
        if ((error) != nil) {
            print(" There's an error")
        }
        else if result.isCancelled {
            print("login canceled!")
        }
        else {
            if (result.grantedPermissions.contains("email") && result.grantedPermissions.contains("public_profile")) {
                
                let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                ref.authWithOAuthProvider("facebook", token: accessToken,
                    withCompletionBlock: { error, authData in
                        if error != nil {
                            print("Login failed. \(error)")
                        } else {
                            print("Logged in! \(authData)")
                            
                            // Store new user from Facebook locally
                            let provider = authData.provider
                            let uid = FBSDKAccessToken.currentAccessToken().userID
                            self.defaults.setObject(uid, forKey:"User ID")
                            let facebookID = authData.providerData["id"] as! String
                            let name = authData.providerData["displayName"] as! String
                            let profilePictureURL = authData.providerData["profileImageURL"] as! String
                            let gender = "gender"
                            let bio = "What makes you fabulous? Update your profile now."
                            let latitude = self.tempLat
                            let longitude = self.tempLong
                            
                            self.newUser.createNewUser(facebookID, name: name, profilePicture: profilePictureURL, gender: gender, latitude: latitude, longitude: longitude, bio: bio)
                            CurrentUser = self.newUser
                            //                            ref.childByAppendingPath("/users/\(uid)").updateChildValues(newUser as [NSObject : AnyObject])
                            
                        }
                        SessionDefaults.global.userUID = FBSDKAccessToken.currentAccessToken().userID
                        self.performSegueWithIdentifier("onboardingSegue", sender: nil)
                        
                        
                })
            }
        }
    }
    
    @IBAction func onDismissButtonTapped(sender: UIButton) {
        self.dismissViewControllerAnimated(true, completion: {});
    }
    
    // FBSDK Delegate Function #2
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User Logged Out")
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "onboardingSegue") {
            
            //            let mainFeedVc = segue.destinationViewController as! MainfeedVC
            //            mainFeedVc.newUserFromSignUp = newUser
        }
    }
}

