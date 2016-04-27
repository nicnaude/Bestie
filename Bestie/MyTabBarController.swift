//
//  myTabBarController.swift
//  Bestie
//
//  Created by Nicholas Naudé on 27/04/2016.
//  Copyright © 2016 Nicholas Naudé. All rights reserved.
//

import UIKit

class MyTabBarController: UITabBarController {
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBar.barTintColor = UIColor.bestiePurple()
        UITabBar.appearance().tintColor = UIColor.whiteColor()
        self.tabBar.setValue(true, forKey: "_hidesShadow")
        
        for item in self.tabBar.items! as [UITabBarItem] {
            if let image = item.image {
                item.image = image.imageWithColor(UIColor(red:0.34, green:0.16, blue:0.66, alpha:1.0)).imageWithRenderingMode(.AlwaysOriginal)
            }
        }
    }
} //