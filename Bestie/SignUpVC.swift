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

class SignUpVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Facebook login test
        let loginButton = FBSDKLoginButton()
        loginButton.center = self.view.center
        self.view.addSubview(loginButton)
        
        // Additional Facebook login with Firebase
        let ref = Firebase(url: "https://bestieapp.firebaseio.com")

        let facebookLogin = FBSDKLoginManager()

        facebookLogin.logInWithReadPermissions(["first_name", "last_name", "email", "picture", "id", "age_range", "gender", "locale"], fromViewController: self.parentViewController, handler: { (result, error) -> Void in
            if error != nil {
                print(FBSDKAccessToken.currentAccessToken())
            } else if result.isCancelled {
                print("Cancelled")
            } else {
                print("LoggedIn")
            }
        })
    }
    
//        facebookLogin.logInWithReadPermissions(["email"]!, fromViewController: self, handler: <#T##FBSDKLoginManagerRequestTokenHandler!##FBSDKLoginManagerRequestTokenHandler!##(FBSDKLoginManagerLoginResult!, NSError!) -> Void#>)
//        
//        facebookLogin.logInWithReadPermissions(["email"], handler: {
//            (facebookResult, facebookError) -> Void in
//            
//            if facebookError != nil {
//                print("Facebook login failed. Error \(facebookError)")
//            } else if facebookResult.isCancelled {
//                print("Facebook login was cancelled.")
//            } else {
//                let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
//                
//                ref.authWithOAuthProvider("facebook", token: accessToken,
//                    withCompletionBlock: { error, authData in
//                        
//                        if error != nil {
//                            print("Login failed. \(error)")
//                        } else {
//                            print("Logged in! \(authData)")
//                        }
//                })
//            }
//        })
//    }
}
