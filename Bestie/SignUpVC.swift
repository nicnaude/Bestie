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

class SignUpVC: UIViewController, FBSDKLoginButtonDelegate {
    
    let defaults = NSUserDefaults.standardUserDefaults()
    
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
                            
                            // push user data to Firebase
                            let provider = authData.provider
                            let uid = FBSDKAccessToken.currentAccessToken().userID
                            self.defaults.setObject(uid, forKey:"User ID")
                            let facebookID = authData.providerData["id"] as! String
                            let name = authData.providerData["displayName"] as! String
                            let profilePictureURL = authData.providerData["profileImageURL"] as! String
                            // need to add gender, etc
                            let value = ["provider":provider, "facebookID": facebookID, "name":name, "profilePictureURL":profilePictureURL]
                            
                            ref.childByAppendingPath("/users/\(uid)").setValue(value)
                        }
                        SessionDefaults.global.userUID = FBSDKAccessToken.currentAccessToken().userID
                        self.performSegueWithIdentifier("onboardingSegue", sender: nil)
                })
            }
        }
    }
    
    // FBSDK Delegate Function #2
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User Logged Out")
    }
}

