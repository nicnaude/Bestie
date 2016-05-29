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
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.bestiePurple()], forState:.Normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName: UIColor.bestieDarkPurple()], forState:.Selected)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBar.barTintColor = UIColor.whiteColor()
        UITabBar.appearance().tintColor = UIColor.bestieDarkPurple()
        self.tabBar.setValue(true, forKey: "_hidesShadow")
        
        for item in self.tabBar.items! as [UITabBarItem] {
            if let image = item.image {
                item.image = image.imageWithColor(UIColor.bestiePurple()).imageWithRenderingMode(.AlwaysOriginal)
            }
        }
    }
} //