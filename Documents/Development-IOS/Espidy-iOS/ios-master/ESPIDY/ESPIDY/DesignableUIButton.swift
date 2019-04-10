//
//  DesignableUIButton.swift
//  ESPIDY
//
//  Created by FreddyA on 8/29/16.
//  Copyright © 2016 Kretum. All rights reserved.
//

import UIKit

@IBDesignable class DesignableUIButton: UIButton {
    
    @IBInspectable var borderColor: UIColor = UIColor.clear {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var shadowColor: UIColor = UIColor.clear {
        didSet {
            layer.shadowColor = shadowColor.cgColor
        }
    }
    
    @IBInspectable var shadowRadius: CGFloat = 0 {
        didSet {
            layer.shadowRadius = shadowRadius
        }
    }
    
    @IBInspectable var shadowOpacity: CGFloat = 0 {
        didSet {
            layer.shadowOpacity = Float(shadowOpacity)
        }
    }
    
    @IBInspectable var shadowOffsetY: CGFloat = 0 {
        didSet {
            layer.shadowOffset.height = shadowOffsetY
        }
    }

//    override func drawRect(rect: CGRect) {
//        super.drawRect(rect)
//        backgroundColor = UIColor.ESPIDYColorGreenL()
//        titleLabel?.textColor = UIColor.ESPIDYColorLight()
//        titleLabel?.font = UIFont(name: "Montserrat-Bold", size: 15)
//    }
    
}