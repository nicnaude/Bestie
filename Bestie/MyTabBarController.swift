//
//  myTabBarController.swift
//  Bestie
//
//  Created by Nicholas Naudé on 27/04/2016.
//  Copyright © 2016 Nicholas Naudé. All rights reserved.
//

import UIKit

class MyTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.bestiePurple()], for:UIControlState())
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.bestieDarkPurple()], for:.selected)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBar.barTintColor = UIColor.white
        UITabBar.appearance().tintColor = UIColor.bestieDarkPurple()
        
        if storyboard == "Main.storyboard" {
            self.tabBar.setValue(true, forKey: "_hidesShadow")
        } else {
            self.tabBar.setValue(false, forKey: "_hidesShadow")
        }//
        
        
        
        for item in self.tabBar.items! as [UITabBarItem] {
            if let image = item.image {
                item.image = image.imageWithColor(UIColor.bestiePurple()).withRenderingMode(.alwaysOriginal)
            }
        }
    }//
    
} // The End
