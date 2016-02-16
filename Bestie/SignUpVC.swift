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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        BackendProcessor.backendProcessor.observeFireBaseDatabaseForChanges()
        BackendProcessor.backendProcessor.checkUserAuthenticationState()
//        facebookLogInWithReadPermissions()
    
        
        // Facebook login test
        let loginButton = FBSDKLoginButton()
        loginButton.center = self.view.center
        self.view.addSubview(loginButton)
        loginButton.delegate = self
        loginButton.readPermissions = ["public_profile", "email"]

    }
    
//    // Figure out how to retrieve: "first_name", "last_name", "email", "picture", "id", "age_range", "gender", "locale"
//    func facebookLogInWithReadPermissions() {
//        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
//
//         let facebookLogin = FBSDKLoginManager()
//        facebookLogin.logInWithReadPermissions(["email"], fromViewController: self, handler: { (result, error) -> Void in
//            if error != nil {
//                print(FBSDKAccessToken.currentAccessToken())
//            } else if result.isCancelled {
//                print("Cancelled")
//            } else {
//                print("LoggedIn")
//            }
//        })
//            dispatch_async(dispatch_get_main_queue()) {
//                let ref = Firebase(url: "https://bestieapp.firebaseio.com")
//              if (FBSDKAccessToken.currentAccessToken() == nil) {
//                if ref.authData != nil {
//                    return
//                } else {
//                    BackendProcessor.backendProcessor.createNewUserInFireBase()
//                }
//            }
//        }
//    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        let ref = Firebase(url: "https://bestieapp.firebaseio.com")

        if ((error) != nil)
        {
           print(" There's an error") // Process error
        }
        else if result.isCancelled {
            // Handle cancellations
            print("login canceled!")
        }
        else {
            // If you ask for multiple permissions at once, you
            // should check if specific permissions missing
            if (result.grantedPermissions.contains("email") && result.grantedPermissions.contains("public_profile")) {
                
                let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                ref.authWithOAuthProvider("facebook", token: accessToken,
                    withCompletionBlock: { error, authData in
                        if error != nil {
                            print("Login failed. \(error)")
                        } else {
                            print("Logged in! \(authData)")
                            
                            // push user data to Firebase
                            let newUser = [
                            "provider": authData.provider,
                            "displayName": authData.providerData["displayName"] as? NSString as? String
                            ]
                            ref.childByAppendingPath("users").childByAppendingPath(authData.uid).setValue(newUser)
//                            let uid = FBSDKAccessToken.currentAccessToken().userID
//                            let name = authData.providerData["displayName"] as! String
//                            let profilePictureURL = authData.providerData["profileImageURL"] as! String
//                            let value = ["name":name, "profilePictureURL":profilePictureURL]
                            
//                            ref.childByAppendingPath("/users/\(uid)").setValue(value)
                            
                        }
                        
                        SessionDefaults.global.userUID = FBSDKAccessToken.currentAccessToken().userID
                        self.dismissViewControllerAnimated(true, completion: nil)
                        
                })
            }
        }
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User Logged Out")
    }
}

