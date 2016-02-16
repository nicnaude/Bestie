//
//  MainFeedVC.swift
//  Bestie
//
//  Created by Nicholas Naudé and Michael Saltzman on 13/02/2016.
//  Copyright © 2016 Nicholas Naudé and Michael Saltzman. All rights reserved.
//

import UIKit
import Firebase

class MainfeedVC: UIViewController {
    
    @IBOutlet weak var headerTextLabel: UILabel!
    @IBOutlet weak var testTextField: UITextField!
    
    // this creates a connection to Firebase.
    let ref = Firebase(url: "https://bestieapp.firebaseio.com")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // send a test to fireBase to see if it works!
        ref.setValue("Hello, Firebase totally works.")
        
        ref.observeEventType(.Value, withBlock: {snapshot in
            let message = snapshot.value as! String
            self.headerTextLabel.text = message
        })
    } // end of viewDidLoad
    
    
    @IBAction func onUpdateButtonTapped(sender: UIButton) {
        ref.setValue(testTextField.text)
        testTextField.text = ""
    }
    
    
    // MARK: - TableViewControllers
    
} // end of VC
