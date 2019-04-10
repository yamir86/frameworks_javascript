//
//  RequestService.swift
//  ESPIDY
//
//  Created by FreddyA on 10/29/16.
//  Copyright © 2016 Kretum. All rights reserved.
//

import PKHUD
import UIKit
import Foundation
import LTMorphingLabel

protocol RequestServiceDelegate: class {
    func acceptedService(_ shipment: Shipment)
}

class RequestService: NSObject {
    
    var delegate: RequestServiceDelegate?
    
    var countdown = 0
    
    var timer = Timer()
    
    var shipment: Shipment? {
        didSet {
            labelAddress.text = shipment?.pickup_location?.address
        }
    }
    
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
        label.text = "NEW SERVICE".localized + "\n" + "REQUESTED IN".localized
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
    
    let labelAddress: UILabel = {
        let label = UILabel()
        label.text = "PARQUE INDUSTRIAL MILLA 8. CIUDAD DE PANAMA"
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
    
    let stackViewCountdown: UIStackView = {
        var sv = UIStackView()
        sv.axis = UILayoutConstraintAxis.vertical
        sv.distribution = UIStackViewDistribution.equalSpacing
        sv.alignment = UIStackViewAlignment.center
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    let containerViewCountdown: UIView = {
        var view = UIView()
        view.layer.cornerRadius = 35
        view.backgroundColor = UIColor.black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var labelSecondsCountdown: LTMorphingLabel = {
        let label = LTMorphingLabel()
        label.text = String(self.countdown)
        label.font = UIFont(name: "Montserrat-Bold", size: 22)
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let labelSecond: UILabel = {
        let label = UILabel()
        label.text = "SEG"
        label.font = UIFont(name: "Montserrat-Regular", size: 13)
        label.textColor = UIColor.white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let labelServiceMissed: UILabel = {
        let label = UILabel()
        label.text = "MISSED SERVICES: 0".localized
        label.font = UIFont(name: "Montserrat-Regular", size: 13)
        label.textColor = UIColor.ESPIDYColorBorderView()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
        stackViewRequestService.addArrangedSubview(labelAddress)
        stackViewRequestService.addArrangedSubview(viewSeparator1)
        stackViewRequestService.addArrangedSubview(containerViewCountdown)
        containerViewCountdown.addSubview(stackViewCountdown)
        stackViewCountdown.addArrangedSubview(labelSecondsCountdown)
        stackViewCountdown.addArrangedSubview(labelSecond)
        stackViewRequestService.addArrangedSubview(labelServiceMissed)
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
        
        labelAddress.widthAnchor.constraint(equalToConstant: 180).isActive = true
        
        viewSeparator1.widthAnchor.constraint(equalToConstant: 150).isActive = true
        viewSeparator1.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        
        containerViewCountdown.widthAnchor.constraint(equalToConstant: 70).isActive = true
        containerViewCountdown.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        stackViewCountdown.centerXAnchor.constraint(equalTo: containerViewCountdown.centerXAnchor).isActive = true
        stackViewCountdown.centerYAnchor.constraint(equalTo: containerViewCountdown.centerYAnchor).isActive = true
        
        labelServiceMissed.widthAnchor.constraint(equalToConstant: 200).isActive = true
        
    }
    
    func showView() {
        
        if let window = UIApplication.shared.keyWindow {
            
            window.addSubview(blackView)
            window.addSubview(containerView)
            
            let width: CGFloat = CGFloat(window.frame.width - 16)
            let height: CGFloat = CGFloat(window.frame.height - 80)
            containerView.frame = CGRect(x: 8, y: window.frame.height, width: width, height: height)
            
            blackView.frame = window.frame
            blackView.alpha = 0
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                self.blackView.alpha = 1
                
                self.containerView.frame = CGRect(x: 8, y: 40, width: width, height: height)
                
                }, completion: nil)
            
            countdown = 30
            labelSecondsCountdown.text = String(countdown)
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCount), userInfo: nil, repeats: true)
            
        }
    }
    
    func showDialog() {
        let alert = UIAlertController(title: "¡ATENTION!", message: "Shipment has already been taken or cancelled".localized, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: {
            action in
        }))
        UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
    }
    
    
    
    @objc func updateCount() {
        if countdown > 0 {
            countdown = countdown - 1
            labelSecondsCountdown.text = ""
            labelSecondsCountdown.text = String(countdown)
        } else {
            handleReject()
        }
    }
    
    func handleDismiss(_ accepted: Bool) {
        timer.invalidate()
        if accepted {
            HUD.show(.rotatingImage(UIImage(named: "progressHUD")))
            EspidyApiManager.sharedInstance.shipmentAcceptId(String(self.shipment!.id!), completionHandler: { (error) in
                if error == nil {
                    HUD.flash(.success, delay: 1.0) { _ in
                        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                            self.blackView.alpha = 0
                            
                            self.containerView.frame = CGRect(x: 8,
                                                              y: (self.containerView.frame.height + 80),
                                                              width: self.containerView.frame.width,
                                                              height: self.containerView.frame.height)
                            
                        }) { (completed: Bool) in
                            self.delegate?.acceptedService(self.shipment!)
                        }
                    }
                } else {
                    HUD.flash(.error, delay: 1.0) { _ in
                        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                            self.blackView.alpha = 0
                            
                            self.containerView.frame = CGRect(x: 8,
                                                              y: (self.containerView.frame.height + 80),
                                                              width: self.containerView.frame.width,
                                                              height: self.containerView.frame.height)
                            
                        }) { (completed: Bool) in
                            self.showDialog()
                            Global_UserSesion?.newService = true
                        }
                    }
                }
                
            })
        } else {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                self.blackView.alpha = 0
                
                self.containerView.frame = CGRect(x: 8,
                                                  y: (self.containerView.frame.height + 80),
                                                  width: self.containerView.frame.width,
                                                  height: self.containerView.frame.height)
                
            }) { (completed: Bool) in
            }
        }
    }
    
    @objc func handleReject() {
        Global_UserSesion?.newService = true
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

