//
//  Message.swift
//  Bestie
//
//  Created by Michael Saltzman on 2/24/16.
//  Copyright © 2016 Nicholas Naudé. All rights reserved.
//

import UIKit

class Message: NSObject {
    
    var sentUserId = String()
    var messageContent = String()
    // var messageTimeStamp = NSDate – We will implement this once we get everything else to work.
    
    init(sentUserId: String, messageContent: String) {
        super.init()
        self.sentUserId = sentUserId
        self.messageContent = messageContent
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
