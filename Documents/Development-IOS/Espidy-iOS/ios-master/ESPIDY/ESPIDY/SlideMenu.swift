//
//  SlideMenu.swift
//  ESPIDY
//
//  Created by FreddyA on 9/5/16.
//  Copyright © 2016 Kretum. All rights reserved.
//

import UIKit
import Kingfisher
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


protocol SlideMenuDelegate: class {
    func didTapMenu(_ menu: MenuName)
}

class SlideMenu: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    weak var delegate: SlideMenuDelegate?
    var user: User? {
        didSet {
            labelName.text = user?.name
            setupProfileImage()
        }
    }
    
    func setupProfileImage() {
        if user?.avatar_file_size > 0 {
            if let profileImageUrl = user?.image {
                imageViewProfile.kf.indicatorType = .activity
                imageViewProfile.kf.setImage(with: URL(string: profileImageUrl)!,
                                             placeholder: UIImage(named: "avatar-men"),
                                             options: nil,
                                             progressBlock: nil,
                                             completionHandler: nil)
                
//                imageViewProfile.loadImageUsingUrlString(profileImageUrl)
            }
        }
    }
    
    lazy var blackView: UIView = {
        var view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
        return view
    }()
    
    let contentView: UIView = {
        var view = UIView()
        view.backgroundColor = UIColor.ESPIDYColorSlideMenu()
        return view
    }()
    
    let contentImageViewProfile: UIView = {
        var view = UIView()
        view.layer.cornerRadius = 42
        view.backgroundColor = UIColor(r: 69, g: 68, b: 76)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let imageViewProfile: CustomImageView = {
        let image = CustomImageView()
        image.image = UIImage(named: "avatar-men")
        image.layer.cornerRadius = 35
        image.layer.masksToBounds = true
        image.contentMode = .scaleAspectFill
//        image.contentMode = .ScaleAspectFit
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    let labelName: UILabel = {
        let name = UILabel()
        name.text = "Jhon Snow"
        name.font = UIFont(name: "Montserrat-Bold", size: 18)
        name.textColor = UIColor.ESPIDYColorRedL()
        name.translatesAutoresizingMaskIntoConstraints = false
        return name
    }()

    let labelWelcome: UILabel = {
        let welcome = UILabel()
        welcome.text = "WELCOME!".localized
        welcome.font = UIFont(name: "Montserrat-Regular", size: 15)
        welcome.textColor = UIColor.white
        welcome.translatesAutoresizingMaskIntoConstraints = false
        return welcome
    }()
    
    let viewSeparator: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 69, g: 69, b: 75)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        cv.backgroundColor = UIColor.whiteColor()
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    let viewSeparatorVersion: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.ESPIDYColorSlideMenuSelect()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let labelVersion: UILabel = {
        let version = UILabel()
        if let versionApp = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
           let buildApp = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            version.text = "VERSION \(versionApp) \(buildApp)"
        } else {
            version.text = "VERSION"
        }
        version.font = UIFont(name: "Montserrat-Regular", size: 11)
        version.textColor = UIColor.ESPIDYColorUnSelected()
        version.textAlignment = .center
        version.translatesAutoresizingMaskIntoConstraints = false
        return version
    }()
    
    let cellId = "cellId"
    let cellHeight: CGFloat = 60
    
    let menus: [Menu] = {
        
        var menu: [Menu]
        
        let menuPayments = Menu(name: .Payments, imageName: "icon-payments-menu")
        let menuHistory = Menu(name: .History, imageName: "icon-history-menu")
        let menuHelp = Menu(name: .Help, imageName: "icon-help-menu")
        let menuSettings = Menu(name: .Settings, imageName: "icon-settings-menu")
        let menuRedeemCode = Menu(name: .RedeemCode, imageName: "iconGiftCode")

        if Global_UserSesion?.personable_id != "Driver" {
            menu = [menuPayments, menuHistory, menuSettings, menuRedeemCode]
        } else {
            menu = [menuHistory, menuSettings]
        }
        
        return menu
    }()
    
    func setupViews() {
        contentView.addSubview(contentImageViewProfile)
        contentImageViewProfile.addSubview(imageViewProfile)
        contentView.addSubview(labelName)
        contentView.addSubview(labelWelcome)
        contentView.addSubview(viewSeparator)
        contentView.addSubview(collectionView)
        contentView.addSubview(viewSeparatorVersion)
        contentView.addSubview(labelVersion)
        
        contentImageViewProfile.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20).isActive = true
        contentImageViewProfile.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 36).isActive = true
        contentImageViewProfile.widthAnchor.constraint(equalToConstant: 84).isActive = true
        contentImageViewProfile.heightAnchor.constraint(equalToConstant: 84).isActive = true
        
        imageViewProfile.centerXAnchor.constraint(equalTo: contentImageViewProfile.centerXAnchor).isActive = true
        imageViewProfile.centerYAnchor.constraint(equalTo: contentImageViewProfile.centerYAnchor).isActive = true
        imageViewProfile.widthAnchor.constraint(equalToConstant: 70).isActive = true
        imageViewProfile.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        labelName.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20).isActive = true
        labelName.topAnchor.constraint(equalTo: contentImageViewProfile.bottomAnchor, constant: 16).isActive = true
        
        labelWelcome.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20).isActive = true
        labelWelcome.topAnchor.constraint(equalTo: labelName.bottomAnchor, constant: 10).isActive = true
        
        viewSeparator.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 20).isActive = true
        viewSeparator.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -20).isActive = true
        viewSeparator.topAnchor.constraint(equalTo: labelWelcome.bottomAnchor, constant: 16).isActive = true
        viewSeparator.heightAnchor.constraint(equalToConstant: 1).isActive = true

        collectionView.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: viewSeparator.bottomAnchor, constant: 20).isActive = true
        collectionView.widthAnchor.constraint(equalTo: contentView.widthAnchor, constant: -1).isActive = true
        let height: CGFloat = CGFloat(menus.count) * cellHeight
        collectionView.heightAnchor.constraint(equalToConstant: height).isActive = true
        
        labelVersion.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        labelVersion.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20).isActive = true
        
        viewSeparatorVersion.leftAnchor.constraint(equalTo: contentView.leftAnchor).isActive = true
        viewSeparatorVersion.rightAnchor.constraint(equalTo: contentView.rightAnchor).isActive  = true
        viewSeparatorVersion.bottomAnchor.constraint(equalTo: labelVersion.topAnchor, constant: -20).isActive = true
        viewSeparatorVersion.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
    }
    
    func showMenu() {
        //show menu
        
        if let window = UIApplication.shared.keyWindow {
            
            window.addSubview(blackView)
            window.addSubview(contentView)
            
            let width: CGFloat = CGFloat((window.frame.width * 3) / 4)
            contentView.frame = CGRect(x: -width, y: 0, width: width, height: window.frame.height)
            
            blackView.frame = window.frame
            blackView.alpha = 0
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                self.blackView.alpha = 1
                
                self.contentView.frame = CGRect(x: 0, y: 0, width: self.contentView.frame.width, height: self.contentView.frame.height)
                
                }, completion: nil)
        }
    }
    
    @objc func handleDismiss(_ menu: Menu) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.blackView.alpha = 0

            self.contentView.frame = CGRect(x: -self.contentView.frame.width, y: 0, width: self.contentView.frame.width, height: self.contentView.frame.height)
            
        }) { (completed: Bool) in
            if menu.name != .Cancel {
                self.delegate?.didTapMenu(menu.name)
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return menus.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! MenuCell
        
        let menu = menus[indexPath.item]
        cell.menu = menu
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let menu = self.menus[indexPath.item]
        handleDismiss(menu)
    }
 
    override init() {
        super.init()
        
        setupViews()
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(MenuCell.self, forCellWithReuseIdentifier: cellId)
    }
    
}
