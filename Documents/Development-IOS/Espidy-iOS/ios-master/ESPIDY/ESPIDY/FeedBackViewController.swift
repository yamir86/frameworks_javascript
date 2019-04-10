//
//  FeedBackViewController.swift
//  ESPIDY
//
//  Created by FreddyA on 9/19/16.
//  Copyright © 2016 Kretum. All rights reserved.
//

import UIKit
import PKHUD
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


class FeedBackViewController: UIViewController {
    
    var shipment: Shipment?
    
    weak var mainViewController: MainViewController?
    
    var nvc: UINavigationController?
    
    var starDriver: [UIImageView]?
    var starFeedback: [UIButton]?
    
    @IBOutlet weak var imageViewDriver: UICircleImageView!
    @IBOutlet weak var labelPersonableId: UILabel!
    @IBOutlet weak var labelDriverName: UILabel!
    @IBOutlet weak var labelLabelModel: UILabel!
    @IBOutlet weak var labelModel: UILabel!
    @IBOutlet weak var labelLabelTag: UILabel!
    @IBOutlet weak var labelTag: UILabel!
    @IBOutlet weak var imageViewStarDriver0: UIImageView!
    @IBOutlet weak var imageViewStarDriver1: UIImageView!
    @IBOutlet weak var imageViewStarDriver2: UIImageView!
    @IBOutlet weak var imageViewStarDriver3: UIImageView!
    @IBOutlet weak var imageViewStarDriver4: UIImageView!
    @IBOutlet weak var imageViewVehicle: UIImageView!
    @IBOutlet weak var labelTime: UILabel!
    @IBOutlet weak var labelPrice: UILabel!
    @IBOutlet weak var textFieldComment: UITextField!
    @IBOutlet weak var buttonStarFeedback0: UIButton!
    @IBOutlet weak var buttonStarFeedback1: UIButton!
    @IBOutlet weak var buttonStarFeedback2: UIButton!
    @IBOutlet weak var buttonStarFeedback3: UIButton!
    @IBOutlet weak var buttonStarFeedback4: UIButton!
    @IBOutlet weak var navigationItemTitle: UINavigationItem!
    @IBOutlet weak var constraintHeightViewTag: NSLayoutConstraint!
    @IBOutlet weak var viewTag: UIView!
    @IBOutlet weak var imagePaymentType: UIImageView!
    @IBOutlet weak var labelPaymentType: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 44))
        titleLabel.text = "SEND FEEDBACK".localized
        titleLabel.textColor = UIColor.white
        titleLabel.font = UIFont(name: "Montserrat-Regular", size: 15)
        titleLabel.textAlignment = .center
        navigationItemTitle.titleView = titleLabel
        
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        view.layoutIfNeeded()
        
        imageViewDriver.layer.cornerRadius = 34
        imageViewDriver.layer.masksToBounds = true
        //        imageViewDriver.clipsToBounds = true
        // TODO: revisar sombra
        let shadowColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.25).cgColor
        imageViewDriver.applyCircleShadow(4, shadowOpacity: 4, shadowColor: shadowColor, shadowOffset: CGSize(width: 3, height: 3))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    // MARK: - Methods
    func setupView() {
        
        starDriver = [imageViewStarDriver0,
                      imageViewStarDriver1,
                      imageViewStarDriver2,
                      imageViewStarDriver3,
                      imageViewStarDriver4]
        
        starFeedback = [buttonStarFeedback0,
                        buttonStarFeedback1,
                        buttonStarFeedback2,
                        buttonStarFeedback3,
                        buttonStarFeedback4]
        
        if let shippingMethod = shipment!.shippingMethod {
            switch shippingMethod {
            case .Food:
                imageViewVehicle.image = UIImage(named: "bike-green") //cambiar
            case .Motorcycle:
                imageViewVehicle.image = UIImage(named: "moto-green")
            case .Car:
                imageViewVehicle.image = UIImage(named: "car-green")
            }
        }
        
        if let deliveryTime = shipment!.delivery_time {
            labelTime.text = "\(deliveryTime) m."
        } else {
            labelTime.text = "-"
        }
        
        if let costService = shipment!.cost {
            let nf = NumberFormatter()
            nf.numberStyle = NumberFormatter.Style.decimal
            nf.maximumFractionDigits = 2
            if let costS = nf.string(from: NSNumber(value: costService)) {
                labelPrice.text = "\(costS) DOP"
            } else {
                labelPrice.text = "-"
            }
        } else {
            labelPrice.text = "-"
        }
        
        if Global_UserSesion?.personable_id == "Driver" {
            
            labelPersonableId.text = "CLIENT:".localized
            labelModel.text = ""
            labelLabelModel.text = "REQUEST SERVICE".localized
            
            constraintHeightViewTag.constant = 0
            viewTag.isHidden = true
            
            if let imageProfile = shipment!.client?.image {
                if shipment!.client?.avatar_file_size > 0 {
                    imageViewDriver?.kf.indicatorType = .activity
                    imageViewDriver?.kf.setImage(with: URL(string: imageProfile)!,
                                                placeholder: UIImage(named: "avatar-men"),
                                                options: nil,
                                                progressBlock: nil,
                                                completionHandler: nil)
                } else {
                    imageViewDriver.image = UIImage(named: "avatar-user-tracking-men")
                }
            } else {
                imageViewDriver.image = UIImage(named: "avatar-user-tracking-men")
            }
            
            labelDriverName.text = shipment?.client?.name
            
            if let calification = shipment?.client?.calification {
                for (i, star) in starDriver!.enumerated() {
                    if i <= (Int(calification) - 1) {
                        star.isHighlighted = true
                    } else {
                        star.isHighlighted = false
                    }
                }
            }
            
            if shipment!.payment_method_id! == 1 {
                imagePaymentType.image = UIImage(named: "ic-tdc")
                labelPaymentType.text = "CLIENT PAYMENT: CREDIT CARD"
            } else {
                imagePaymentType.image = UIImage(named: "ic-cash")
                labelPaymentType.text = "CLIENT PAYMENT: CASH"
            }
            
        } else {
            
            labelPersonableId.text = "DRIVER:".localized
            labelLabelModel.text = "MODEL:".localized
            
            if shipment!.driver?.vehicles?.count > 0 {
                if let vehicle = shipment!.driver?.vehicles?[0] {
                    labelModel?.text = vehicle.model
                    labelTag?.text = vehicle.license_plates
                } else {
                    labelModel?.text = "-"
                    labelTag?.text = "-"
                }
            } else {
                labelModel?.text = "-"
                labelTag?.text = "-"
            }

            constraintHeightViewTag.constant = 16
            viewTag.isHidden = false
            
            if let imageProfile = shipment!.driver?.image {
                if shipment!.driver?.avatar_file_size > 0 {
                    imageViewDriver?.kf.indicatorType = .activity
                    imageViewDriver?.kf.setImage(with: URL(string: imageProfile)!,
                                                placeholder: UIImage(named: "avatar-men"),
                                                options: nil,
                                                progressBlock: nil,
                                                completionHandler: nil)
                } else {
                    imageViewDriver.image = UIImage(named: "avatar-user-tracking-men")
                }
            } else {
                imageViewDriver.image = UIImage(named: "avatar-user-tracking-men")
            }
            
            labelDriverName.text = shipment?.driver?.name
            
            if let calification = shipment?.driver?.calification {
                for (i, star) in starDriver!.enumerated() {
                    if i <= (Int(calification) - 1) {
                        star.isHighlighted = true
                    } else {
                        star.isHighlighted = false
                    }
                }
            }
            
            imagePaymentType.isHidden = true
            labelPaymentType.text = ""
            labelPaymentType.isHidden = true
        }
        
    }
    
    func selectedStar(_ index: Int) {
        if starFeedback![index].isSelected {
            for i in index...4 {
                starFeedback![i].isSelected = false
            }
        } else {
            for i in 0...index {
                starFeedback![i].isSelected = true
            }
        }
    }
    
    // MARK: - Actions
    @IBAction func buttonSubmit(_ sender: UIButton) {
        
        HUD.show(.rotatingImage(UIImage(named: "progressHUD")))
        var countStars = 0
        for (_, star) in starFeedback!.enumerated() {
            if star.isSelected {
                countStars = countStars + 1
            }
        }
        
        EspidyApiManager.sharedInstance.shipmentRateServiceId(String(shipment!.id!), rating: String(countStars),
                                                                  comment: textFieldComment.text!,
                                                                  completionHandler: { (error) in
            if error == nil {
                
                HUD.flash(.success, delay: 1.0) { _ in
                    Global_UserSesion?.newService = true
                    let storyboard = UIStoryboard(name: Storyboard.Main.rawValue, bundle: nil)
                    let mainViewController = storyboard.instantiateViewController(withIdentifier: "mainViewController") as! MainViewController
                    //        navigationController?.setViewControllers([mainViewController], animated: true)
                    self.nvc?.viewControllers = [mainViewController]
                    self.mainViewController!.locationManager.startUpdatingLocation()
                    self.mainViewController!.textFieldDropOff.text = ""
                    self.mainViewController!.markerDropOff.map = nil
                    self.dismiss(animated: true, completion: nil)
                }
                
            } else {
                // TODO: display error
                HUD.flash(.error, delay: 1.0) { _ in
//                    print("AlertMessageError \(error)")
                }
            }
        })
        
    }
    
    @IBAction func buttonStarFeedback(_ sender: UIButton) {
        selectedStar(sender.tag)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
