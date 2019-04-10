//
//  PinDestiny.swift
//  ESPIDY
//
//  Created by FreddyA on 9/21/16.
//  Copyright © 2016 Kretum. All rights reserved.
//

import UIKit

class PinDestiny: UIView {
    
    var imageProfile: String? {
        didSet {
            if imageProfile! == "globo" {
                imageViewIcon.image = UIImage(named: imageProfile!)
            } else if imageProfile! == "DefaultPinDestinyImage" {
                imageViewIcon.image = UIImage(named: "avatar-user-tracking-men")
            } else {
                imageViewIcon.kf.indicatorType = .activity
                imageViewIcon.kf.setImage(with: URL(string: (imageProfile)!))
            }
        }
    }
    
    let imageViewPin: UIImageView = {
        let icon = UIImageView()
        icon.image = UIImage(named: "pin-destiny-tracking")
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false
        return icon
    }()
    
    var imageViewIcon: UIImageView = {
        let icon = UIImageView()
        icon.image = UIImage(named: "globo")
        icon.backgroundColor = UIColor.white
        icon.contentMode = .scaleAspectFill
        icon.translatesAutoresizingMaskIntoConstraints = false
        icon.layer.cornerRadius = 15
        icon.layer.masksToBounds = true
        return icon
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    func setupViews() {
        addSubview(imageViewPin)
        addSubview(imageViewIcon)
        
        imageViewPin.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        imageViewPin.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        imageViewPin.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        imageViewPin.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
//        imageViewIcon.leftAnchor.constraintEqualToAnchor(self.leftAnchor, constant: 11).active = true
        
        imageViewIcon.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        
        imageViewIcon.topAnchor.constraint(equalTo: self.topAnchor, constant: 6).isActive = true
        imageViewIcon.widthAnchor.constraint(equalToConstant: 30).isActive = true
        imageViewIcon.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /*
     // Only override drawRect: if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func drawRect(rect: CGRect) {
     // Drawing code
     }
     */
    
}
