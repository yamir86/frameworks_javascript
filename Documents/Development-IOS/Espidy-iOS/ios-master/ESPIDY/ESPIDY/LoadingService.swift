//
//  LoadingService.swift
//  ESPIDY
//
//  Created by FreddyA on 9/18/16.
//  Copyright © 2016 Kretum. All rights reserved.
//

import UIKit
import PKHUD

protocol LoadingServiceDelegate: class {
    func acceptedService(_ shipment: Shipment)
}

class LoadingService: NSObject, MainViewControllerPushNotificationDelegate {
    
    var delegate: LoadingServiceDelegate?
    
    var shipment: Shipment?
    
    weak var mainViewController: MainViewController? {
        didSet {
            mainViewController?.delegate = self
        }
    }
    
    let blackView: UIView = {
        var view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        return view
    }()
    
    let contentView: UIView = {
        var view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }()
   
    let imageViewEspidyIcon: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "globo")
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    let labelInfo: UILabel = {
        let label = UILabel()
        label.text = "WAIT A FEW SECONDS".localized + "\n" + "WE'RE LOOKING SOMEBODY".localized + "\n" + "NEAR TO YOU".localized
        label.font = UIFont(name: "Montserrat-Regular", size: 17)
        label.textColor = UIColor.ESPIDYColorDark()
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
    
    let viewSeparator1: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.ESPIDYColorBorderView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var buttonCancelOrder: UIButton = {
        var button = UIButton(type: .system)
        button.setTitle("CANCEL ORDER!".localized, for: UIControlState())
        button.setTitleColor(UIColor.ESPIDYColorBorderView(), for: UIControlState())
        button.titleLabel?.font = UIFont(name: "Montserrat-Regular", size: 17)
        button.addTarget(self, action: #selector(handleCancelOrder), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
   
    func setupViews() {
        contentView.addSubview(imageViewEspidyIcon)
        contentView.addSubview(viewSeparator0)
        contentView.addSubview(labelInfo)
        contentView.addSubview(viewSeparator1)
        contentView.addSubview(buttonCancelOrder)
        
        buttonCancelOrder.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        buttonCancelOrder.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        buttonCancelOrder.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        viewSeparator1.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        viewSeparator1.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 1/2).isActive = true
        viewSeparator1.heightAnchor.constraint(equalToConstant: 1).isActive = true
        viewSeparator1.bottomAnchor.constraint(equalTo: buttonCancelOrder.topAnchor, constant: -32).isActive = true
        
        labelInfo.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 8).isActive = true
        labelInfo.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -8).isActive = true
        labelInfo.bottomAnchor.constraint(equalTo: viewSeparator1.topAnchor, constant: -40).isActive = true
        
        viewSeparator0.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        viewSeparator0.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 1/2).isActive = true
        viewSeparator0.heightAnchor.constraint(equalToConstant: 1).isActive = true
        viewSeparator0.bottomAnchor.constraint(equalTo: labelInfo.topAnchor, constant: -40).isActive = true
        
//        imageViewEspidyIcon.centerXAnchor.constraintEqualToAnchor(contentView.centerXAnchor).active = true
//        imageViewEspidyIcon.topAnchor.constraintEqualToAnchor(contentView.topAnchor, constant: 16).active = true
    }
    
    func showView() {
        if let window = UIApplication.shared.keyWindow {
            
            if Global_UserSesion!.isShipmentActive {
                switch Global_UserSesion!.statusShipment {
                case "PENDING":
                    Global_UserSesion?.statusShipment = ""
                    Global_UserSesion?.isShipmentActive = false
                default:
                    break
                }
            }
            
            window.addSubview(blackView)
            window.addSubview(contentView)
            
            contentView.addSubview(imageViewEspidyIcon)
            
            let width: CGFloat = CGFloat(window.frame.width - 16)
            let height: CGFloat = CGFloat(window.frame.height - 80)
            contentView.frame = CGRect(x: 8, y: window.frame.height, width: width, height: height)
            
            blackView.frame = window.frame
            blackView.alpha = 0
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                self.blackView.alpha = 1
                
                self.contentView.frame = CGRect(x: 8, y: 32, width: width, height: height)
                
                }, completion: nil)
            
            imageViewEspidyIcon.frame = CGRect(x: ((width / 2) - (81 / 2)), y: 16, width: 81, height: 90)
            
            UIView.animate(withDuration: 0.8, delay: 0.4,
                options: [.repeat, .autoreverse], animations: {
                
                    self.imageViewEspidyIcon.frame = CGRect(x: ((width / 2) - (81 / 2)), y: (height - 365), width: 81, height: 90)
                    
                }, completion: nil)
        }
    }
    
    func getShipmentId(_ idShipment: String) {
        HUD.show(.rotatingImage(UIImage(named: "progressHUD")))
        EspidyApiManager.sharedInstance.shipmentId(idShipment) { result in
            guard result.error == nil else {
                // TODO: display error
                HUD.flash(.error, delay: 1.0) { _ in
                    print("AlertMessageError \(result.error)")
                }
                self.handleCancelOrder()
                return
            }
            if let shipmentId = result.value {
                if shipmentId.status != "error" {
                    Global_UserSesion?.shipmentActive = nil
                    self.shipment = nil
                    self.shipment = shipmentId
                    
                    HUD.flash(.success, delay: 1.0) { _ in
                        self.handleDismiss(true)
                    }
                } else {
                    HUD.flash(.error, delay: 1.0) { _ in
                        print("AlertMessageError \(shipmentId)")
                    }
                }
            }
        }
    }
    
    func handleDismiss(_ acepted: Bool) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.blackView.alpha = 0
            
            self.contentView.frame = CGRect(x: 8, y: (self.contentView.frame.height + 80), width: self.contentView.frame.width, height: self.contentView.frame.height)
            
        }) { (completed: Bool) in
            if acepted {
                if let shipment = self.shipment{
                    self.delegate?.acceptedService(shipment)
                }
            }
        }
    }
    
    //AQUI SE CANCELA LA ORDEN MIGUEL
    @objc func handleCancelOrder() {
        HUD.show(.rotatingImage(UIImage(named: "progressHUD")))
        if let shipmentId = shipment!.id {
            EspidyApiManager.sharedInstance.shipmentCancelId(String(shipmentId), completionHandler: { (error) in
                if error != nil {
                    HUD.flash(.error, delay: 1.0) { _ in
                        print("error cancel order \(error)")
                    }
                } else {
                    HUD.flash(.success, delay: 1.0) { _ in
                        self.handleDismiss(false)
                    }
                }
            })
        } else {
            HUD.flash(.error, delay: 1.0) { _ in
                print("shipmentId is nil")
            }
        }
    }
    
    func recivedPushDriverAcepted(_ shipment_id: String) {
        getShipmentId(shipment_id)
    }
    
    override init() {
        super.init()
        setupViews()
    }
    
}

