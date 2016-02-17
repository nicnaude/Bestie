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
    let ref = Firebase(url: "https://bestieapp.firebaseio.com/users/uid/name/")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // this allows persistent storage offline - code might need to go in all views 
//        Firebase.defaultConfig().persistenceEnabled = true
    

    }
    
    
    @IBAction func onUpdateButtonTapped(sender: UIButton) {
        ref.setValue(testTextField.text)
        testTextField.text = ""
    }
    
    
    // MARK: - TableViewControllers
    
} // end of VC
