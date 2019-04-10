//
//  ConfirmShippingViewController.swift
//  ESPIDY
//
//  Created by FreddyA on 9/14/16.
//  Copyright © 2016 Kretum. All rights reserved.
// NXB-hy-LjM

import UIKit
import PKHUD
import Firebase
import Alamofire
import ActiveLabel
import FirebaseInstanceID
import CoreLocation

class ConfirmShippingViewController: UIViewController, LoadingServiceDelegate {
    
    var titleNavigationBar: String?
    var shipment: Shipment?
    weak var mainViewController: MainViewController?
    
    @IBOutlet weak var imageViewVehicle: UIImageView!
    @IBOutlet weak var labelVehicleService: UILabel!
    @IBOutlet weak var labelDetailServiceVehicle: UILabel!
    @IBOutlet weak var labelNumberItems: UILabel!
    @IBOutlet weak var stepperItems: UIStepper!
    @IBOutlet weak var textFieldDescription: UITextField!
    @IBOutlet weak var labelTermsConditions: ActiveLabel!
    @IBOutlet weak var labelTypePayment: UILabel!
    @IBOutlet weak var imageViewTypePayment: UIImageView!
    @IBOutlet weak var viewSelectTypePayment: UIView!
    @IBOutlet weak var labelEstimatedCost: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    lazy var paymentTypePickerView: PaymentTypePickerView = {
        let paymentType = PaymentTypePickerView()
        paymentType.delegate = self
        return paymentType
    }()
    var payment: Int = 0
    var shipMethodID: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let titleNavigationBar = titleNavigationBar {
            let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 44))
            titleLabel.text = titleNavigationBar
            titleLabel.textColor = UIColor.white
            titleLabel.font = UIFont(name: "Montserrat-Regular", size: 15)
            titleLabel.textAlignment = .center
            navigationItem.titleView = titleLabel
        }
        
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if Global_UserSesion!.isShipmentActive {
            switch Global_UserSesion!.statusShipment {
            case "PENDING":
                confirmOrder(true)
            default:
                break
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Methods
    func setupView() {
        
        stepperItems.wraps = true
        stepperItems.autorepeat = true
        stepperItems.maximumValue = 10
        stepperItems.minimumValue = 1
        
        if let shipment = shipment {
            
            if let shippingMethod = shipment.shippingMethod {
                switch shippingMethod {
                case .Food:
                    imageViewVehicle.image = UIImage(named: "bike-green")
                    self.shipMethodID = 1
                case .Motorcycle:
                    imageViewVehicle.image = UIImage(named: "moto-green")
                    self.shipMethodID = 2
                case .Car:
                    imageViewVehicle.image = UIImage(named: "car-green")
                    self.shipMethodID = 3
                }
                labelVehicleService.text = "IN".localized + " \(shippingMethod.method)"
            }
            
            if let shipmentDescription = shipment.description {
                textFieldDescription.text = shipmentDescription
            } else {
                textFieldDescription.text = ""
            }
            
            if let shipmentItems = shipment.items {
                labelNumberItems.text = String(shipmentItems)
            } else {
                labelNumberItems.text = "1"
                stepperItems.value = 1
            }
            
            if shipment.dropoff_location != nil {
                calculateEstimatedCost()
            }
            
        }
        
        let tapGestureViewPaymentType = UITapGestureRecognizer(target: self, action: #selector(handleTapPaymentType))
        viewSelectTypePayment.addGestureRecognizer(tapGestureViewPaymentType)
        
        termsConditionsSetup()
    }
    
    func termsConditionsSetup() {
        let customType0 = ActiveType.custom(pattern: "\\sTERMS\\b")
        let customType1 = ActiveType.custom(pattern: "\\sAND\\b")
        let customType2 = ActiveType.custom(pattern: "\\sCONDITIONS\\b")
        
        let customType3 = ActiveType.custom(pattern: "\\sTÉRMINOS\\b")
        let customType4 = ActiveType.custom(pattern: "\\sY\\b")
        let customType5 = ActiveType.custom(pattern: "\\sCONDICIONES\\b")
        
        labelTermsConditions.enabledTypes.append(customType0)
        labelTermsConditions.enabledTypes.append(customType1)
        labelTermsConditions.enabledTypes.append(customType2)
        labelTermsConditions.enabledTypes.append(customType3)
        labelTermsConditions.enabledTypes.append(customType4)
        labelTermsConditions.enabledTypes.append(customType5)
        
        labelTermsConditions.customize { label in
            label.text = "IF YOU CONFIRM THIS SHIPMENT, YOU AGREE TO THE TERMS AND CONDITIONS OF ESPIDY".localized
            label.numberOfLines = 0
            label.lineSpacing = 4
            
            label.textColor = UIColor.black
            
            //Custom types
            label.customColor[customType0] = UIColor.ESPIDYColorGreenL()
            label.customSelectedColor[customType0] = UIColor.ESPIDYColorGreenL()
            label.customColor[customType1] = UIColor.ESPIDYColorGreenL()
            label.customSelectedColor[customType1] = UIColor.ESPIDYColorGreenL()
            label.customColor[customType2] = UIColor.ESPIDYColorGreenL()
            label.customSelectedColor[customType2] = UIColor.ESPIDYColorGreenL()
            label.customColor[customType3] = UIColor.ESPIDYColorGreenL()
            label.customSelectedColor[customType3] = UIColor.ESPIDYColorGreenL()
            label.customColor[customType4] = UIColor.ESPIDYColorGreenL()
            label.customSelectedColor[customType4] = UIColor.ESPIDYColorGreenL()
            label.customColor[customType5] = UIColor.ESPIDYColorGreenL()
            label.customSelectedColor[customType5] = UIColor.ESPIDYColorGreenL()
            
            label.handleCustomTap(for: customType0) { (string) in
                self.openUrlTermsConditions()
            }
            label.handleCustomTap(for: customType1) { (string) in
                self.openUrlTermsConditions()
            }
            label.handleCustomTap(for: customType2) { (string) in
                self.openUrlTermsConditions()
            }
            label.handleCustomTap(for: customType3) { (string) in
                self.openUrlTermsConditions()
            }
            label.handleCustomTap(for: customType4) { (string) in
                self.openUrlTermsConditions()
            }
            label.handleCustomTap(for: customType5) { (string) in
                self.openUrlTermsConditions()
            }
        }
        
    }
    
    func openUrlTermsConditions() {
        guard let url = URL(string: "https://espidy.com/termsandconditions.html")else{ return }
        if #available(iOS 10.0, *){
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }else{
            UIApplication.shared.openURL(url)
        }        
    }

    func confirmOrder(_ isShipmentActive: Bool) {
        
        FIRMessaging.messaging()
        
        if !isShipmentActive {
//            validar tc
//            checkCreditCard()
            
            shipment?.description = textFieldDescription.text
            shipment?.items = Int(labelNumberItems.text!)
            shipment?.payment_method_id = Global_creditCards[payment].payment_method_id
            
            if let creditCardId = Global_creditCards[payment].id {
                shipment?.credit_card_id = creditCardId
            } else {
                shipment?.credit_card_id = 0
            }
            
            requestShipment(String(self.shipMethodID), //shipment!.shippingMethod!.hashValue + 1 //(OLD)
                                 items: String(shipment!.items!),
                                 description: shipment!.description!,
                                 pickup_location: shipment!.pickup_location!,
                                 dropoff_location: shipment?.dropoff_location,
                                 payment_method_id: shipment!.payment_method_id!,
                                 credit_card_id: shipment!.credit_card_id!)
            
        } else {
            loadingService.shipment = shipment
            loadingService.showView()
        }
    }
    
//    func checkCreditCard() {
//        HUD.show(.RotatingImage(UIImage(named: "progressHUD")))
//        EspidyApiManager.sharedInstance.getCreditCards { (result) in
//            guard result.error == nil else {
//                // TODO: display error
////                print("AlertMessageError \(result.error)")
//                return
//            }
//            
//            if let fetchedCreditCards = result.value {
//                if fetchedCreditCards.count > 0 {
//                    self.shipment?.description = self.textFieldDescription.text
//                    self.shipment?.items = Int(self.labelNumberItems.text!)
//                    
//                    self.requestShipment(String(self.shipment!.shippingMethod!.hashValue + 1),
//                        items: String(self.shipment!.items!),
//                        description: self.shipment!.description!,
//                        pickup_location: self.shipment!.pickup_location!,
//                        dropoff_location: self.shipment?.dropoff_location)
//                } else {
//                    HUD.flash(.Error, delay: 1.0) { _ in
//                        let alertController = UIAlertController(title: "Error", message: "You must add a credit card to request a service. Add one to continue".localized, preferredStyle: .Alert)
//                        
//                        let okAction = UIAlertAction(title: "OK", style: .Default) { (result : UIAlertAction) -> Void in }
//                        
//                        alertController.addAction(okAction)
//                        self.presentViewController(alertController, animated: true, completion: nil)
//                    }
//                }
//            }
//        }
//    }
    
    
    func requestShipment(_ shipping_method_id: String,
                         items: String,
                         description: String,
                         pickup_location: EspidyLocation,
                         dropoff_location: EspidyLocation?,
                         payment_method_id: Int,
                         credit_card_id: Int) {
        
        HUD.show(.rotatingImage(UIImage(named: "progressHUD")))
        EspidyApiManager.sharedInstance.requestShipment(shipping_method_id,
                                                            items: items,
                                                            description: description,
                                                            pickup_location: pickup_location,
                                                            dropoff_location: dropoff_location,
                                                            payment_method_id: payment_method_id,
                                                            credit_card_id: credit_card_id) { result in
            guard result.error == nil else {
                // TODO: display error
                print("requestShipment Error \(result.error)")
                HUD.flash(.error, delay: 1.0) { _ in
                }
                return
            }
            if let newShipment = result.value {
                if newShipment.status != "error" {
                    
                    self.shipment!.id = newShipment.id
                    self.shipment!.pickup_location_id = newShipment.pickup_location_id
                    self.shipment!.dropoff_location_id = newShipment.dropoff_location_id
                    self.shipment!.status = newShipment.status
                    
                    //                    self.labelInfo.text = "id: \(self.shipment!.id!), Status \(self.shipment!.status!) "
                    
                    HUD.flash(.success, delay: 1.0) { _ in
                        self.loadingService.shipment = self.shipment
                        self.loadingService.showView()
                    }
                    
                } else {
                    HUD.flash(.error, delay: 1.0) { _ in
                    }
//                    print("requestShipment Error \(newShipment)")
                }
            }
        }
    }
    
    @objc func handleTapPaymentType() {
        UIView.transition(with: viewSelectTypePayment,
                                  duration: 0.2,
                                  options: .transitionCrossDissolve, 
                                  animations: {
            self.viewSelectTypePayment.alpha = 0.2
            }) { (_) in
                self.viewSelectTypePayment.alpha = 1
                
                self.paymentTypePickerView.payment = self.payment
                self.paymentTypePickerView.showPickerView()
        }
    }
    
    func calculateEstimatedCost() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        
        if let shipment = self.shipment,
            let pickup_location = shipment.pickup_location?.location,
            let dropoff_location = shipment.dropoff_location?.location {
            
            let baseURLString = "https://maps.googleapis.com/maps/api/directions/json"
            let origin = "\(pickup_location.latitude), \(pickup_location.longitude)"
            let destination = "\(dropoff_location.latitude), \(dropoff_location.longitude)"
            let mode = "driving"
            let apiKey = googleMapsApiKey
            
            let test1 = CLLocation(latitude: pickup_location.latitude, longitude: pickup_location.longitude)
            let test2 = CLLocation(latitude: dropoff_location.latitude, longitude: dropoff_location.longitude)
            let distance = test1.distance(from: test2) / 1000
            
            let parameters: Parameters = [
                "origin": origin as AnyObject,
                "destination": destination as AnyObject,
                "mode": mode as AnyObject,
                "key": apiKey as AnyObject
            ]
            
            Alamofire.request(baseURLString, method: .get, parameters: parameters)
                .responseObject { (response: DataResponse<MapsDirections>) in
                    
                    guard response.result.error == nil else {
                        print("AlertMessageError \(String(describing: response.result.error))")
                        self.activityIndicator.stopAnimating()
                        self.activityIndicator.isHidden = true
                        self.labelEstimatedCost.text = "-"
                        return
                    }
                    
                    if let newMapsDirections = response.result.value {
                        if let durationSeconds = newMapsDirections.durationSeconds, let distanceMeters = newMapsDirections.distanceMeters {
                            
                            let estimatedTime = Int(durationSeconds / 60)
                            let estimatedDistance = Float(distanceMeters / 1000)
                            
                            EspidyApiManager.sharedInstance.estimatedCost(km: String(estimatedDistance),
                                                                          time: String(estimatedTime),
                                                                          method: self.shipMethodID,
                                                                          completionHandler: { (result) in
                                                                            guard result?.error == nil else {
                                                                                print("AlertMessageError \(String(describing: result?.error))")
                                                                                self.activityIndicator.stopAnimating()
                                                                                self.activityIndicator.isHidden = true
                                                                                self.labelEstimatedCost.text = "-"
                                                                                return
                                                                            }
                                                                            
                                                                            if let newMapsDirections = result?.value {
                                                                                if let estimatedCostRequested = newMapsDirections.estimatedCost {
                                                                                    self.activityIndicator.stopAnimating()
                                                                                    self.activityIndicator.isHidden = true
                                                                                    self.labelEstimatedCost.text = "\(estimatedCostRequested) DOP"
                                                                                } else {
                                                                                    self.activityIndicator.stopAnimating()
                                                                                    self.activityIndicator.isHidden = true
                                                                                    self.labelEstimatedCost.text = "-"
                                                                                }
                                                                            } else {
                                                                                self.activityIndicator.stopAnimating()
                                                                                self.activityIndicator.isHidden = true
                                                                                self.labelEstimatedCost.text = "-"
                                                                            }
                            })
                        } else {
                            self.activityIndicator.stopAnimating()
                            self.activityIndicator.isHidden = true
                            self.labelEstimatedCost.text = "-"
                        }
                    } else {
                        self.activityIndicator.stopAnimating()
                        self.activityIndicator.isHidden = true
                        self.labelEstimatedCost.text = "-"
                    }
            }
        } else {
            activityIndicator.stopAnimating()
            activityIndicator.isHidden = true
            labelEstimatedCost.text = "-"
        }
    }
    
    //MARK: - Actions
    @IBAction func stepperItems(_ sender: UIStepper) {
        labelNumberItems.text = Int(sender.value).description
    }
    
    lazy var loadingService: LoadingService = {
        let loading = LoadingService()
        loading.delegate = self
        loading.mainViewController = self.mainViewController
        return loading
    }()
    
    //accion confirmar orden
    @IBAction func handleConfirmOrder(_ sender: UIButton) {
        //se valida si se ha registrado alguna tarjeta de credito
        //confirmOrder(false) se comenta por motivos de prueba
        if existPayMethod {
            confirmOrder(false)
        }else{
            let storyboard = UIStoryboard(name: Storyboard.FlowLoginRegister.rawValue, bundle: nil)
            let registerCardViewController = storyboard.instantiateViewController(withIdentifier: "RegisterCardViewController") as! RegisterCardViewController
            registerCardViewController.titleNavigationBar = "ADD A NEW CREDIT CARD!".localized
            registerCardViewController.info0 = ""
            registerCardViewController.info1 = "OR COMPLETE THE FIELDS PRESENTED BELOW".localized
            registerCardViewController.titleButton = "ADD!".localized
            registerCardViewController.delegate = self
            self.navigationController?.navigationBar.tintColor = UIColor.white
            self.navigationController?.pushViewController(registerCardViewController, animated: true)
        }
    }
    
    // MARK: - LoadingServiceDelegate
    func acceptedService(_ shipment: Shipment) {
        let shipmentProgressViewController = self.storyboard!.instantiateViewController(withIdentifier: "shipmentProgressViewController") as! ShipmentProgressViewController
        shipmentProgressViewController.titleNavigationBar = "SHIPMENT IN PROGRESS".localized
        shipmentProgressViewController.shipment = shipment
        shipmentProgressViewController.mainViewController = mainViewController
        navigationController?.setViewControllers([shipmentProgressViewController], animated: true)
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

extension ConfirmShippingViewController: PaymentTypePickerViewDelegate {
    func handleUpdatePaymentType(_ payment: Int) {
        self.payment = payment
        if Global_creditCards[payment].payment_method_id == 1 {
            imageViewTypePayment.image =  UIImage(named: "ic-tdc")
            labelTypePayment.text = "TDC"
        } else {
            imageViewTypePayment.image =  UIImage(named: "ic-cash")
            labelTypePayment.text = "CASH"
        }
    }
}

extension ConfirmShippingViewController: RegisterCardViewControllerDelegate {
    func successRegister() {
        isExistsCreditCard()
        navigationController?.popViewController(animated: true)
    }
}
