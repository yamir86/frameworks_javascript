//
//  AlertSetYourselfAway.swift
//  ESPIDY
//
//  Created by FreddyA on 1/9/17.
//  Copyright © 2017 Kretum. All rights reserved.
//

import UIKit
import Foundation

protocol AlertSetYourselfAwayDelegate: class {
    func acceptedChange()
}

class AlertSetYourselfAway: NSObject {
    
    var delegate: AlertSetYourselfAwayDelegate?
    
    let blackView: UIView = {
        var view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        return view
    }()
    
    let containerView: UIView = {
        var view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }()
    
    let stackViewRequestService: UIStackView = {
        var sv = UIStackView()
        sv.backgroundColor = UIColor.yellow
        sv.axis = UILayoutConstraintAxis.vertical
        sv.distribution = UIStackViewDistribution.equalSpacing
        sv.alignment = UIStackViewAlignment.center
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    let labelTitle: UILabel = {
        let label = UILabel()
        label.text = "SET YOURSELF AWAY".localized
        label.font = UIFont(name: "Montserrat-Bold", size: 19)
        label.textColor = UIColor.ESPIDYColorRedL()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let viewSeparator0: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.ESPIDYColorBorderView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let labelInformation: UILabel = {
        let label = UILabel()
        label.text = "ARE YOU SURE YOU DON'T WANT TO MAKE MORE MONEY?".localized
        label.font = UIFont(name: "Montserrat-Regular", size: 15)
        label.textColor = UIColor.ESPIDYColorDark()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let viewSeparator1: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.ESPIDYColorBorderView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var buttonAccept: UIButton = {
        var button = UIButton(type: .system)
        button.setTitle("ACCEPT!".localized, for: UIControlState())
        button.backgroundColor = UIColor.ESPIDYColorGreenL()
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.titleLabel?.font = UIFont(name: "Montserrat-Bold", size: 17)
        button.addTarget(self, action: #selector(handleAcceptService), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var buttonReject: UIButton = {
        var button = UIButton(type: .system)
        button.setTitle("REJECT!".localized, for: UIControlState())
        button.setTitleColor(UIColor.ESPIDYColorBorderView(), for: UIControlState())
        button.titleLabel?.font = UIFont(name: "Montserrat-Bold", size: 17)
        button.addTarget(self, action: #selector(handleReject), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    func setupViews() {
        
        containerView.addSubview(stackViewRequestService)
        stackViewRequestService.addArrangedSubview(labelTitle)
        stackViewRequestService.addArrangedSubview(viewSeparator0)
        stackViewRequestService.addArrangedSubview(labelInformation)
        stackViewRequestService.addArrangedSubview(viewSeparator1)
        containerView.addSubview(buttonAccept)
        containerView.addSubview(buttonReject)
        
        buttonReject.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        buttonReject.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        buttonReject.heightAnchor.constraint(equalToConstant: 60).isActive = true
        buttonReject.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        
        buttonAccept.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        buttonAccept.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        buttonAccept.heightAnchor.constraint(equalToConstant: 60).isActive = true
        buttonAccept.bottomAnchor.constraint(equalTo: buttonReject.topAnchor).isActive = true
        
        stackViewRequestService.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        stackViewRequestService.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
        stackViewRequestService.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 32).isActive = true
        stackViewRequestService.bottomAnchor.constraint(equalTo: buttonAccept.topAnchor, constant: -32).isActive = true
        
        labelTitle.widthAnchor.constraint(equalToConstant: 200).isActive = true
        
        viewSeparator0.widthAnchor.constraint(equalToConstant: 150).isActive = true
        viewSeparator0.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        
        labelInformation.widthAnchor.constraint(equalToConstant: 180).isActive = true
        
        viewSeparator1.widthAnchor.constraint(equalToConstant: 150).isActive = true
        viewSeparator1.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        
    }
    
    func showView() {
        
        if let window = UIApplication.shared.keyWindow {
            
            window.addSubview(blackView)
            window.addSubview(containerView)
            
            let width: CGFloat = CGFloat(window.frame.width - 16)
            let height: CGFloat = CGFloat(window.frame.height - 160)
            containerView.frame = CGRect(x: 8, y: window.frame.height, width: width, height: height)
            
            blackView.frame = window.frame
            blackView.alpha = 0
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                self.blackView.alpha = 1
                
                self.containerView.frame = CGRect(x: 8, y: (window.frame.height - height) / 2, width: width, height: height)
                
                }, completion: nil)
            
        }
    }
    
    func handleDismiss(_ accepted: Bool) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.blackView.alpha = 0
            
            self.containerView.frame = CGRect(x: 8, y: self.blackView.frame.height, width: self.containerView.frame.width, height: self.containerView.frame.height)
            
        }) { (completed: Bool) in
            if !accepted {
                self.delegate?.acceptedChange()
            }
        }
    }
    
    @objc func handleReject() {
        handleDismiss(false)
    }
    
    @objc func handleAcceptService() {
        handleDismiss(true)
    }
    
    override init() {
        super.init()
        
        setupViews()
    }
    
}

