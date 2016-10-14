//
//  GlobalDefinitions.swift
//  Bestie
//
//  Created by Nicholas Naudé on 13/02/2016.
//  Copyright © 2016 Nicholas Naudé. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore

// This is where we define global updates and

func maskRoundedImage(_ image: UIImage, radius: Float) -> UIImage {
    let imageView: UIImageView = UIImageView(image: image)
    var layer: CALayer = CALayer()
    layer = imageView.layer
    
    layer.masksToBounds = true
    layer.cornerRadius = CGFloat(radius)
    
    UIGraphicsBeginImageContext(imageView.bounds.size)
    layer.render(in: UIGraphicsGetCurrentContext()!)
    let roundedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return roundedImage!
}
