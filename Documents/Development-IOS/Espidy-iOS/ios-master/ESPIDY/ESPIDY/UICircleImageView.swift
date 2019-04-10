//
//  UICircleImageView.swift
//  ESPIDY
//
//  Created by Gabriel Alejandro Afonso Goncalves on 4/28/18.
//  Copyright © 2018 Kretum. All rights reserved.
//

import UIKit

class UICircleImageView: UIImageView {
    
    func addCircleShadow(_ shadowRadius: CGFloat = 2, shadowOpacity: Float = 0.3, shadowColor: CGColor = UIColor.black.cgColor, shadowOffset: CGSize = CGSize.zero) {
        // Use UIImageView.hashvalue as background view tag (should be unique)
        let background: UIView = superview?.viewWithTag(hashValue) ?? UIView()
        background.frame = frame
        background.backgroundColor = backgroundColor
        background.tag = hashValue
        background.applyCircleShadow(shadowRadius, shadowOpacity: shadowOpacity, shadowColor: shadowColor, shadowOffset: shadowOffset)
        layer.cornerRadius = background.layer.cornerRadius
        layer.masksToBounds = true
        superview?.insertSubview(background, belowSubview: self)
    }
}
