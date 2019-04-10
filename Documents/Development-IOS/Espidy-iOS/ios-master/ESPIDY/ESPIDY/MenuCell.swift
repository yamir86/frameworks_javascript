//
//  MenuCell.swift
//  ESPIDY
//
//  Created by FreddyA on 9/5/16.
//  Copyright © 2016 Kretum. All rights reserved.
//

import UIKit

class BaseCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    func setupViews() {
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class MenuCell: BaseCell {
    
    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? UIColor.ESPIDYColorSlideMenuSelect() : UIColor.ESPIDYColorSlideMenu()
            viewLineTop.isHidden = !isHighlighted
            viewLineBottom.isHidden = !isHighlighted
        }
    }
    
    var menu: Menu? {
        didSet {
            labelNameMenu.text = menu?.name.name
            
            if let imageName = menu?.imageName {
                imageViewIcon.image = UIImage(named: imageName)?.withRenderingMode(.alwaysOriginal)
//                imageViewIcon.tintColor = UIColor.darkGrayColor()
            }
        }
    }
    
    let imageViewIcon: UIImageView = {
        let icon = UIImageView()
        icon.image = UIImage(named: "icon-payments-menu")
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false
        return icon
    }()
    
    let labelNameMenu: UILabel = {
        let name = UILabel()
        name.text = "PAYMENTS"
        name.font = UIFont(name: "Montserrat-Regular", size: 14)
        name.textColor = UIColor.white
        name.translatesAutoresizingMaskIntoConstraints = false
        return name
    }()
    
    let viewLineTop: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 24, g: 24, b: 28)
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let viewLineBottom: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 43, g: 43, b: 53)
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func setupViews() {
        super.setupViews()
        
        self.backgroundColor = UIColor.ESPIDYColorSlideMenu()
        
        addSubview(viewLineTop)
        addSubview(imageViewIcon)
        addSubview(labelNameMenu)
        addSubview(viewLineBottom)
        
        viewLineTop.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        viewLineTop.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        viewLineTop.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        
        imageViewIcon.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20).isActive = true
        imageViewIcon.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        imageViewIcon.widthAnchor.constraint(equalToConstant: 29).isActive = true
        imageViewIcon.heightAnchor.constraint(equalToConstant: 29).isActive = true
        
        labelNameMenu.leftAnchor.constraint(equalTo: imageViewIcon.rightAnchor, constant: 20).isActive = true
        labelNameMenu.bottomAnchor.constraint(equalTo: imageViewIcon.bottomAnchor, constant: -2).isActive = true
        
        viewLineBottom.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        viewLineBottom.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        viewLineBottom.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        
    }
}
