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
        BackendProcessor.backendProcessor.observeFireBaseDatabaseForChanges()
        BackendProcessor.backendProcessor.checkUserAuthenticationState()
        
        // Facebook login test
        let loginButton = FBSDKLoginButton()
        loginButton.center = self.view.center
        self.view.addSubview(loginButton)
        
        
        let facebookLogin = FBSDKLoginManager()
        
        // "first_name", "last_name", "email", "picture", "id", "age_range", "gender", "locale"
        
        facebookLogin.logInWithReadPermissions(["email"], fromViewController: self, handler: { (result, error) -> Void in
            if error != nil {
                print(FBSDKAccessToken.currentAccessToken())
            } else if result.isCancelled {
                print("Cancelled")
            } else {
                print("LoggedIn")
            }
        })
    }
}
