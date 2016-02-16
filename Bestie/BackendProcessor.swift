//
//  BackendProcessor.swift
//  Bestie
//
//  Created by Nicholas Naudé on 15/02/2016.
//  Copyright © 2016 Nicholas Naudé. All rights reserved.
//

import Foundation
import Firebase

class BackendProcessor {
    
    static let backendProcessor = BackendProcessor()
    let ref = Firebase(url: "https://bestieapp.firebaseio.com")
    
    //
    func observeFireBaseDatabaseForChanges (){
        ref.observeAuthEventWithBlock({ authData in
            if authData != nil {
                // user authenticated
                print(authData)
            } else {
                // No user is signed in
            }
        })
    }
    
    
    func checkUserAuthenticationState () {

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
}