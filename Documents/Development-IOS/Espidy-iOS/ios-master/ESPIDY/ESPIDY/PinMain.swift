//
//  PinPickUp.swift
//  ESPIDY
//
//  Created by FreddyA on 9/18/16.
//  Copyright © 2016 Kretum. All rights reserved.
//

import UIKit

class PinMain: UIView {
    
    let imageViewIcon: UIImageView = {
        let icon = UIImageView()
        icon.image = UIImage(named: "PIN-pickuphere")
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false
        return icon
    }()
    
    var labelTitle: UILabel = {
        let label = UILabel()
        label.text = "PICK UP HERE".localized
        label.font = UIFont(name: "Montserrat-Regular", size: 14)
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    func setupViews() {
        addSubview(imageViewIcon)
        addSubview(labelTitle)
        
        imageViewIcon.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        imageViewIcon.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        imageViewIcon.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        imageViewIcon.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        labelTitle.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        labelTitle.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        labelTitle.topAnchor.constraint(equalTo: self.topAnchor, constant: 7).isActive = true
        
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
