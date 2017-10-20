//
//  MMToolPane.swift
//  Meme1.0
//
//  Created by Karthik Sankar on 9/4/17.
//  Copyright © 2017 Karthik Sankar. All rights reserved.
//

import UIKit
@IBDesignable

class MMToolPane: UIView {
    
    // Corner Radius and Bounds Ovveride when drawn on screen
    override func awakeFromNib() {
        layer.cornerRadius = 10.0           // Default Corener Radius
        layer.masksToBounds = true
    }
}

// Extension for Tool Pane
extension MMToolPane {
    // Set Corner Radius
    @IBInspectable var cornerRadius:CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
}
