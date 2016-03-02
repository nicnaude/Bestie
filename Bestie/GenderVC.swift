//
//  GenderVC.swift
//  Bestie
//
//  Created by Michael Saltzman on 3/1/16.
//  Copyright © 2016 Nicholas Naudé. All rights reserved.
//

import UIKit
import Firebase

class GenderVC: UIViewController {
    
    //    var ref = Firebase(url: "https://bestieapp.firebaseio.com/")
    //    var defaults = NSUserDefaults.standardUserDefaults()
    var selectedGender = String()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        view?.backgroundColor = UIColor.bestiePurple()
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onBoyButtonTapped(sender: UIButton) {
        
        CurrentUser.gender = "male"
        
        //        let currentUserID = defaults.valueForKey("User ID") as! String
        //        let gender = ["gender": "male" as String]
        //        let userRef = ref.childByAppendingPath("/users")
        //        userRef.childByAppendingPath(currentUserID).updateChildValues(gender)
    }
    
    @IBAction func onGirlsButtonTapped(sender: UIButton) {
        
        CurrentUser.gender = "female"
        
        //        let currentUserID = defaults.valueForKey("User ID") as! String
        //        let gender = ["gender": "female" as String]
        //        let userRef = ref.childByAppendingPath("/users")
        //        userRef.childByAppendingPath(currentUserID).setValue(gender)
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    //    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    //        let nav = segue.destinationViewController as! UINavigationController
    //        let destinationVc = nav.topViewController as! MainfeedVC
    //        destinationVc.gender = selectedGender
    //    }
    
    
}
