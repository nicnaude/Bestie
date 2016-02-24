import UIKit
import JSQMessagesViewController

class Message: JSQMessage {
    
    var senderUID: String
    var receiverUID: String
    var textBody: String
    var time: String
    
    init(senderUID: String, receiverUID: String, textBody: String, time: String) {
        self.senderUID = senderUID
        self.receiverUID = receiverUID
        self.textBody = textBody
        self.time = time
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
