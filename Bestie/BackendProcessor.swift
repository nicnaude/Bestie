//
//  BackendProcessor.swift
//  Bestie
//
//  Created by Nicholas Naudé on 15/02/2016.
//  Copyright © 2016 Nicholas Naudé. All rights reserved.
//

import Foundation
import Firebase
import FBSDKShareKit
import FBSDKCoreKit
import FBSDKLoginKit

class BackendProcessor {
    
    static let backendProcessor = BackendProcessor()
    let ref = Firebase(url: "https://bestieapp.firebaseio.com")
    
    //
    func observeFireBaseDatabaseForChanges(){
        ref.observeAuthEventWithBlock({ authData in
            if authData != nil {
                // user authenticated
                print(authData)
            } else {
                // No user is signed in
            }
        })
    }
    
    func checkUserAuthenticationState() {
        
        if ref.authData != nil {
            // user authenticated
            print(ref.authData)
        } else {
            print("User is not signed in.")
        }
    }
    
    func stopListeningToChangesFromFireBase(){
        let handle = ref.observeAuthEventWithBlock({ authData in })
        ref.removeAuthEventObserverWithHandle(handle)
    }
    
    func logOutUser(){
        ref.unauth()
    }
    
    func createNewUserInFireBase(){
        // The logged in user's unique identifier
//        print(ref.authData.uid)
        
        // Create a new user dictionary accessing the user's info
        // provided by the authData parameter
        let newUser = [
            "provider": ref.authData.provider,
            "displayName": ref.authData.providerData["displayName"] as? NSString as? String
        ]
        
        // Create a child path with a key set to the uid underneath the "users" node
        // This creates a URL path like the following:
        //  - https://<YOUR-FIREBASE-APP>.firebaseio.com/users/<uid>
        ref.childByAppendingPath("users")
            .childByAppendingPath(ref.authData.uid).setValue(newUser)
    }
}