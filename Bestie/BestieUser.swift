//
//  BestieUser.swift
//  Bestie
//
//  Created by Michael Saltzman on 2/19/16.
//  Copyright © 2016 Nicholas Naudé. All rights reserved.
//
//
//import Foundation
//import Firebase
//
//struct BestieUser {
//    
//    let key: String!
//    let userId: String
//    let name: String!
//    let profilePicture: String!
//    let ref: Firebase
//    
//     // Initialize from arbitrary data
//    init(userId: String, name: String, profilePicture: String, key: String = "") {
//        self.key = key
//        self.userId = userId
//        self.name = name
//        self.profilePicture = profilePicture
//        self.ref = nil
//    }
//    
//    init(snapshot: FDataSnapshot) {
//        key = snapshot.key
//        userId = snapshot.value["facebookID"] as! String
//        name = snapshot.value["name"] as! String
//        profilePicture = snapshot.value["profilePictureURL"] as! String
//        ref = snapshot.ref
//    }
//    
//    func toAnyObject() -> AnyObject {
//        return [
//            "facebookID": userId,
//            "name": name,
//            "profilePictureURL": profilePicture
//        ]
//    }
//    
//}
