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
    
    // Facebook/Firebase Authorization Observer custom method
    func observeFireBaseDatabaseForAuthChanges(){
        ref?.observeAuthEvent({ authData in
            if authData != nil {
                // user authenticated
                print("observeFireBaseDatabaseForAuthChanges: \(authData)")
            } else {
                // No user is signed in
            }
        })
    }
    
    // Firebase authenticating Facebook login custom method
    func checkUserAuthenticationState() {
        
        if ref?.authData != nil {
            // user authenticated
            print("The state is: \(ref?.authData)")
        } else {
            print("User is not signed in.")
        }
    }
    
    // Firebase kill observer (stop listening) after user authenticated via Facebook custom method
    func stopListeningToChangesFromFireBase(){
        let handle = ref?.observeAuthEvent({ authData in })
        ref?.removeAuthEventObserver(withHandle: handle!)
    }
    
    // Logs user out of the app custom method
    func logOutUser(){
        ref?.unauth()
    }
}
