//
//  ShipmentProgressViewController.swift
//  ESPIDY
//
//  Created by FreddyA on 9/19/16.
//  Copyright © 2016 Kretum. All rights reserved.
//

import UIKit
import PKHUD
import MessageUI
import Alamofire
import Kingfisher
import CoreLocation

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


class ShipmentProgressViewController: UIViewController, SlideMenuDelegate {
    
    static let RefreshNotification = "RefreshNotification"
    static let responseInstantPurchaseNotification = "responseInstantPurchaseNotification"
    weak var mainViewController: MainViewController?
    
    var composeVC: MFMessageComposeViewController?
    var isSendingMSM = false
    
    var titleNavigationBar: String?
    
    var shipment: Shipment?
    
    var starUser: [UIImageView]?
    
    var pickUpLocation: CLLocationCoordinate2D?
    var dropOffLocation: CLLocationCoordinate2D?
    var driverLocation: CLLocationCoordinate2D?
    
    var xViewCenter = CGFloat(0)
    var xViewLeft = CGFloat(0)
    
    var timer = Timer()
    
    let locationManager = CLLocationManager()
    var location: CLLocation?
    var phoneUser: String?
    
    var serviceInProgress = false
    
    // MarkerDriver
    let viewPinDriver: PinDriver = {
        var pin = PinDriver(frame: CGRect(x: 0, y: 0, width: 52, height: 84))
        return pin
    }()
    
    let viewPinDestiny: PinDestiny = {
        var pin = PinDestiny(frame: CGRect(x: 0, y: 0, width: 43, height: 69))
        return pin
    }()
    
    lazy var markerDriver: GMSMarker = {
        var mark = GMSMarker()
        mark.iconView = self.viewPinDriver
        mark.map = self.viewGoogleMap
        return mark
    }()
    
    lazy var markerDestiny: GMSMarker = {
        var mark = GMSMarker()
        mark.iconView = self.viewPinDestiny
        mark.map = self.viewGoogleMap
        return mark
    }()
    
    @IBOutlet weak var imageViewAvatar: UICircleImageView!
    @IBOutlet weak var labelPersonableId: UILabel!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelModel: UILabel!
    @IBOutlet weak var labelModelLabel: UILabel!
    @IBOutlet weak var labelTag: UILabel!
    @IBOutlet weak var stackViewTag: UIStackView!
    @IBOutlet weak var constraintHeightStackViewTag: NSLayoutConstraint!
    @IBOutlet weak var imageViewStar0: UIImageView!
    @IBOutlet weak var imageViewStar1: UIImageView!
    @IBOutlet weak var imageViewStar2: UIImageView!
    @IBOutlet weak var imageViewStar3: UIImageView!
    @IBOutlet weak var imageViewStar4: UIImageView!
    @IBOutlet weak var viewGoogleMap: GMSMapView!
    @IBOutlet weak var buttonGoogleMap: UIButton!
    @IBOutlet weak var constraintHeightViewSwipe: NSLayoutConstraint!
    @IBOutlet weak var constraintWidthButtonCall3: NSLayoutConstraint!
    @IBOutlet weak var constraintWidthButtonCall2: NSLayoutConstraint!
    @IBOutlet weak var constraintWidthButtonMessage3: NSLayoutConstraint!
    @IBOutlet weak var constraintWidthButtonMessage2: NSLayoutConstraint!
    @IBOutlet weak var viewSwipe: UIView!
    @IBOutlet weak var labelViewSwipe: UILabel!
    @IBOutlet weak var imageViewViewSwipe: UIImageView!
    @IBOutlet weak var labelEstimatedTime: UILabel!
    @IBOutlet weak var labelCommentClientToDriver: UILabel!
    @IBOutlet weak var viewCommentClientToDriver: UIView!
    
    @IBOutlet weak var btnAmount: UIButton!
    @IBOutlet weak var btnPause: UIButton!
    @IBOutlet weak var btnMessage: UIButton!
    @IBOutlet weak var imagePaimentMethod: UIImageView!
    
    
    //presneter
    fileprivate let presenter = ChangeStateShipmentPresenter(service: ChangeStateShipmentServices())
    
    // MARK: - Life cycle View
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
        
        NotificationCenter.default.addObserver(self,selector: #selector(ShipmentProgressViewController.receivedNotification(_:)), name: NSNotification.Name(rawValue: "RefreshNotification"), object: nil)
        xViewCenter = self.view.center.x
        
        setupView()
        presenter.attachView(view: self)
    }
    
    func setShipmentMethod(){
        if let payment = shipment?.payment_method_id{
            if  payment == 2{//efectivo 2
                self.imagePaimentMethod.image = UIImage(named: "ic-cash-green")
            }else{// TDC
                self.imagePaimentMethod.image = UIImage(named: "ic-tdc")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        view.layoutIfNeeded()
        setShipmentMethod()
        let isDriver = Global_UserSesion?.personable_id == "Driver"
        //viewCommentClientToDriver.isHidden = !isDriver
        
        if isDriver {
            getLocation()
            if let comentClient = shipment?.comment_client {
                self.labelCommentClientToDriver.text = comentClient
            }else{
                self.labelCommentClientToDriver.text = "No Comments".localized
            }
        }else{
            self.hideButtonsOnlyClient()
            
            if let comentClient = shipment?.comment_client {
                self.labelCommentClientToDriver.text = comentClient
            }else{
                self.labelCommentClientToDriver.text = "No Comments".localized
            }
        }
        
        self.imageViewViewSwipe.layoutIfNeeded()
        
        imageViewAvatar.layer.cornerRadius = 23
        imageViewAvatar.layer.masksToBounds = true
        // TODO: revisar sombra
        let shadowColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.25).cgColor
        imageViewAvatar.applyCircleShadow(4, shadowOpacity: 4, shadowColor: shadowColor, shadowOffset: CGSize(width: 3, height: 3))
        
        updateGoogleMapCamera(driverLocation)
        self.changeImageMessage()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Slide Menu
    lazy var slideMenu: SlideMenu = {
        let menu = SlideMenu()
        menu.delegate = self
        return menu
    }()
    
    @IBAction func handleShowMenu(_ sender: UIBarButtonItem) {
        if Global_UserSesion != nil {
            slideMenu.user = Global_UserSesion
        }
        slideMenu.showMenu()
    }
    
    func didTapMenu(_ menu: MenuName) {
        switch menu {
        case .Cancel:
            break
        case .Payments:
            let paymentsViewController = self.storyboard!.instantiateViewController(withIdentifier: "paymentsViewController") as! PaymentsViewController
            paymentsViewController.titleNavigationBar = menu.name
            navigationController?.pushViewController(paymentsViewController, animated: true)
            //            paymentsViewController.modalTransitionStyle = .CrossDissolve
        //            self.presentViewController(paymentsViewController, animated: true, completion: nil)
        case .History:
            let historyViewController = self.storyboard!.instantiateViewController(withIdentifier: "historyViewController") as! HistoryViewController
            historyViewController.titleNavigationBar = menu.name
            navigationController?.pushViewController(historyViewController, animated: true)
        case .Help:
//            print("Menu Help")
            break
        case .Settings:
            let settingsViewController = self.storyboard!.instantiateViewController(withIdentifier: "settingsViewController") as! SettingsViewController
            settingsViewController.titleNavigationBar = menu.name
            navigationController?.pushViewController(settingsViewController, animated: true)
        case .RedeemCode:
            let modalViewController = storyboard?.instantiateViewController(withIdentifier: "RedeemCodeDialogViewController") as? RedeemCodeDialogViewController
            modalViewController?.modalPresentationStyle = .overCurrentContext
            
            if let vc = modalViewController {
                present(vc, animated: true, completion: nil)
            }
            print("CANJEAR CODIGO")
        }
    }
    
    // MARK: - Methods
    func setupView() {
        
        starUser = [
            imageViewStar0,
            imageViewStar1,
            imageViewStar2,
            imageViewStar3,
            imageViewStar4
        ]
        
        imageViewViewSwipe.tintColor = UIColor.ESPIDYColorGreenL()
        setShipmentMethod()
        switch Global_UserSesion!.statusShipment {
        case "DRIVER_ACCEPTED":
            if let imageProfile = shipment!.client?.image {
                if shipment!.client?.avatar_file_size > 0 {
                    viewPinDestiny.imageProfile = imageProfile
                } else {
                    viewPinDestiny.imageProfile = "DefaultPinDestinyImage"
                }
            } else {
                viewPinDestiny.imageProfile = "DefaultPinDestinyImage"
            }
            markerDestiny.position = (shipment!.pickup_location?.location)!
        case "SERVICE_IN_PROGRESS":
            serviceInProgress = true
            viewPinDestiny.imageProfile = "globo"
            if shipment!.dropoff_location?.location != nil {
                markerDestiny.position = (shipment!.dropoff_location?.location)!
            } else {
                markerDestiny.map = nil
            }
            
            labelViewSwipe.text = "SWIPE TO FINISH!".localized
            labelViewSwipe.textColor = UIColor.ESPIDYColorRedL()
            imageViewViewSwipe.tintColor = UIColor.ESPIDYColorRedL()
            viewSwipe.tag = 1

        default:
            if let imageProfile = shipment!.client?.image {
                if shipment!.client?.avatar_file_size > 0 {
                    viewPinDestiny.imageProfile = imageProfile
                } else {
                    viewPinDestiny.imageProfile = "DefaultPinDestinyImage"
                }
            } else {
                viewPinDestiny.imageProfile = "DefaultPinDestinyImage"
            }
            markerDestiny.position = (shipment!.pickup_location?.location)!
        }
        
        Global_UserSesion?.statusShipment = ""
        Global_UserSesion?.isShipmentActive = false
       
        if let imageProfile = shipment!.driver?.image {
            if shipment!.driver?.avatar_file_size > 0 {
                viewPinDriver.imageProfile = imageProfile
            } else {
                viewPinDriver.imageProfile = "DefaultPinDriverImage"
            }
        } else {
            viewPinDriver.imageProfile = "DefaultPinDriverImage"
        }
        pickUpLocation = shipment!.pickup_location?.location
        dropOffLocation = shipment!.dropoff_location?.location
        if dropOffLocation != nil {
            calculateEstimatedTime()
        } else {
            labelEstimatedTime.text = "-"
        }
        
        if Global_UserSesion?.personable_id == "Driver" {
//            constraintWidthButtonCall2.isActive = false
//            constraintWidthButtonMessage2.isActive = false
            
            constraintHeightStackViewTag.constant = 0
            stackViewTag.isHidden = true
            
            labelModel.text = ""
            labelModelLabel.text = "REQUEST SERVICE".localized
            
            labelPersonableId.text = "CLIENT:".localized
            
            labelName?.text = shipment!.client?.name
            if let calification = shipment?.client?.calification {
                for (i, star) in starUser!.enumerated() {
                    if i <= (Int(calification) - 1) {
                        star.isHighlighted = true
                    } else {
                        star.isHighlighted = false
                    }
                }
            }
            
            if let imageProfile = shipment!.client?.image {
                if shipment!.client?.avatar_file_size > 0 {
                    imageViewAvatar?.kf.indicatorType = .activity
                    imageViewAvatar?.kf.setImage(with: URL(string: imageProfile)!)
                    
                } else {
                    imageViewAvatar.image = UIImage(named: "avatar-user-tracking-men")
                }
            } else {
                imageViewAvatar.image = UIImage(named: "avatar-user-tracking-men")
            }
            
            phoneUser = shipment!.client?.phone //phoneClient

        } else {
//            constraintWidthButtonCall3.isActive = false
//            constraintWidthButtonMessage3.isActive = false
            
            constraintHeightViewSwipe.constant = 0
            
            buttonGoogleMap.isHidden = true
            viewSwipe.isHidden = true
            self.hideButtonsOnlyClient()
            labelPersonableId.text = "DRIVER:".localized
            
            labelName?.text = shipment!.driver?.name
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
            
            if let calification = shipment!.driver?.calification {
                for (i, star) in starUser!.enumerated() {
                    if i <= (Int(calification) - 1) {
                        star.isHighlighted = true
                    } else {
                        star.isHighlighted = false
                    }
                }
            }
            
            if let imageProfile = shipment!.driver?.image {
                if shipment!.driver?.avatar_file_size > 0 {
                    imageViewAvatar?.kf.indicatorType = .activity
                    imageViewAvatar?.kf.setImage(with: URL(string: imageProfile)!)
                } else {
                    imageViewAvatar.image = UIImage(named: "avatar-user-tracking-men")
                }
            } else {
                imageViewAvatar.image = UIImage(named: "avatar-user-tracking-men")
            }
            
            phoneUser = shipment!.driver?.phone //phoneClient
        }

        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(updateDriverLocation), userInfo: nil, repeats: true)
        
        viewGoogleMap.delegate = self
        locationManager.delegate = self
    }
    
    func calculateEstimatedTime() {
        let estimatedTimeURLString = "https://maps.googleapis.com/maps/api/directions/json"
        let origin = "\(pickUpLocation!.latitude), \(pickUpLocation!.longitude)"
        let destination = "\(dropOffLocation!.latitude), \(dropOffLocation!.longitude)"
        let mode = "driving"
        let apiKey = googleMapsApiKey
        
        let parameters: Parameters = [
            "origin": origin as AnyObject,
            "destination": destination as AnyObject,
            "mode": mode as AnyObject,
            "key": apiKey as AnyObject
        ]
        
        Alamofire.request(estimatedTimeURLString, method: .get, parameters: parameters)
            .responseObject { (response: DataResponse<MapsDirections>) in
                guard response.result.error == nil else {
                    // TODO: display error
                    //                    print("AlertMessageError \(response.result.error)")
                    return
                }
                
                if let newMapsDirections = response.result.value {
                    if let durationText  = newMapsDirections.durationText {
                        self.labelEstimatedTime.text = durationText
                    } else {
                        self.labelEstimatedTime.text = "-"
                    }
                }
        }
    }
    
    func getLocation() {
        let authStatus = CLLocationManager.authorizationStatus()
        
        if authStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
            return
        }
        
        if authStatus == .denied || authStatus == .restricted {
            showLocationServicesDeniedAlert()
            return
        }
        
        startLocationManager()
    }
    
    func showLocationServicesDeniedAlert() {
        let alert = UIAlertController(title: "Location Services Disabled",
                                      message: "Please enable location services for this app in Settings.",
                                      preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func startLocationManager() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.distanceFilter = 5
            locationManager.startUpdatingLocation()
        }
    }
    
    func updateGoogleMapCamera(_ locationDriver: CLLocationCoordinate2D?) {
        if serviceInProgress {
            if dropOffLocation != nil {
                if locationDriver != nil {
                    updateViewGoogleMap(dropOffLocation!, coordinateDriver: locationDriver!)
                } else {
                    viewGoogleMap.camera = GMSCameraPosition(target: dropOffLocation!, zoom: 15, bearing: 0, viewingAngle: 0)
                }
            } else {
                if locationDriver != nil {
                    updateViewGoogleMap(pickUpLocation!, coordinateDriver: locationDriver!)
                } else {
                    viewGoogleMap.camera = GMSCameraPosition(target: pickUpLocation!, zoom: 15, bearing: 0, viewingAngle: 0)
                }
            }
        } else {
            if locationDriver != nil {
                updateViewGoogleMap(pickUpLocation!, coordinateDriver: locationDriver!)
            } else {
                viewGoogleMap.camera = GMSCameraPosition(target: pickUpLocation!, zoom: 15, bearing: 0, viewingAngle: 0)
            }
        }
    }
    
    func updateViewGoogleMap(_ coordinate: CLLocationCoordinate2D, coordinateDriver: CLLocationCoordinate2D) {
        let bounds = GMSCoordinateBounds(coordinate: coordinate, coordinate: coordinateDriver)
        let insets = UIEdgeInsetsMake(70, 90, 30, 90)
        let camera = viewGoogleMap.camera(for: bounds, insets: insets)!
        viewGoogleMap.camera = camera
        viewGoogleMap.isMyLocationEnabled = true
        viewGoogleMap.settings.myLocationButton = true
        
        markerDriver.position = CLLocationCoordinate2DMake(coordinateDriver.latitude, coordinateDriver.longitude)
        driverLocation = coordinateDriver //location!.coordinate
    }
    
    func changeImageMessage(){
        if isNewMessage { //Tiene mensajes sin ver
            self.btnMessage.setImage(UIImage(named: "icon-mensaje-notification"), for: .normal)
        }else{ // no tiene mensajes sin ver
            self.btnMessage.setImage(UIImage(named: "icon-message-tracking"), for: .normal)
        }
    }
    
    @objc func receivedNotification(_ notification: Notification) {
        guard let typeUser = Global_UserSesion!.personable_id else{
            print("Error ---> Global_UserSesion!.personable_id on Appdelegate line 244")
            return
        }
        DispatchQueue.main.async {
            
            self.changeImageMessage()
            
            if let userInfo = notification.userInfo, let shipment_id = userInfo["shipment_id"] as? String, let shipment_status = userInfo["shipment_status"] as? String  {
                switch typeUser {
                case "Driver":
                    switch shipment_status {
                    case "PENDING":
                        break
                    case "CANCELLED_BY_USER":
                        let alert = UIAlertController(title: "Shipped Canceled".localized,
                                                      message: "The shipment has been canceled by the client.".localized,
                                                      preferredStyle: .alert)
                        
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: { (alert) in
                            self.handleCancelShipment()
                        })
                        alert.addAction(okAction)
                        
                        self.present(alert, animated: true, completion: nil)
                    default:
                        break
                    }
                    
                case "Client":
                    switch shipment_status {
                    case "DRIVER_ACCEPTED":
                        break
                    case "SERVICE_IN_PROGRESS":
                        self.handleServiceInProgress()
                        if (self.btnPause.currentImage == UIImage(named: "iconPause")){
                            let alert = UIAlertController(title: nil,
                                                          message: "The shipment has been resumed".localized,
                                                          preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        }
                        
                    case "COMPLETE_SERVICE", "PAYMENT_SUCCEEDED", "PAYMENT_CASH":
                        if self.isSendingMSM {
                            self.isSendingMSM = false
                            self.composeVC?.dismiss(animated: true, completion: nil)
                        }
                        self.handleSwipeToFinish()
                    case "CANCELLED_BY_DRIVER":
                        let alert = UIAlertController(title: "Shipped Canceled".localized,
                                                      message: "The shipment has been canceled by the driver.".localized,
                                                      preferredStyle: .alert)
                        
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: { (alert) in
                            self.handleCancelShipment()
                        })
                        alert.addAction(okAction)
                        
                        self.present(alert, animated: true, completion: nil)
                        
                    case "SERVICE_IN_PAUSE":
                        let alert = UIAlertController(title: nil,
                                                      message: "The shipment has been paused".localized,
                                                      preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        self.btnPause.setImage(UIImage(named: "iconPause"), for: .normal)
                        
                    default:
                        break
                    }
                    
                default:
                    break
                }
                
            }else{//AQUI MUJICAM
                /*
                let alert = UIAlertController(title: "You have received a message".localized,
                                              message: "Do you want to see the message?".localized,
                                              preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: { (alert) in
                    self.viewMessageChat()
                })
                
                let noAction = UIAlertAction(title: "No", style: .default, handler: nil)
                alert.addAction(okAction)
                alert.addAction(noAction)
                
                self.present(alert, animated: true, completion: nil)
                */
                
                if let userInfo = notification.userInfo, let transmitter_id = userInfo["transmitter"] as? String, let conversation_id = userInfo["conversation_id"] as? String { //for chat
                     NotificationCenter.default.post(name: Notification.Name(rawValue: ChatViewController.ChatRefreshNotification),object: nil,userInfo: ["transmitter_id": transmitter_id, "conversation_id": conversation_id])
                } else if let userInfo = notification.userInfo, let instant_purchase_id = userInfo["instant_purchase_id"] as? String, let amount = userInfo["amount"] as? String {
                    switch typeUser {
                        case "Client":
                            let modalViewController = self.storyboard?.instantiateViewController(withIdentifier: "DialogPayDeliveryViewController") as? DialogPayDeliveryViewController
                            modalViewController?.modalPresentationStyle = .overCurrentContext
                            modalViewController?.amount = amount
                            modalViewController?.instant_purchase_id = instant_purchase_id
                            
                            if let vc = modalViewController {
                                self.present(vc, animated: true, completion: nil)
                            }
                        break
                    default:
                        break
                    }
                }else if let userInfo = notification.userInfo, let status = userInfo["status"] as? String{
                    switch typeUser {
                        case "Driver":
                            print("---> instant_purchase_id: \(status)")
                            let alert = UIAlertController(title: nil, message: status.localized,preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                            self.present(alert, animated: true, completion: nil)
                        break
                    default:
                        break
                    }
                }
                
 
            }
        }
    }
    
    func viewMessageChat(){
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        nextViewController.shipment  = self.shipment
        //nextViewController.selectOperation = array[indexPath.row]
        self.navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    func handleSwipeToFinish() {
        timer.invalidate()
        guard let id = self.shipment?.id else{
            print("---> Return handleSwipeToFinish ")
            return
        }
        getShipmentId(String(id))
    }
    
    func getShipmentId(_ idShipment: String) {
        if !HUD.isVisible {
            HUD.show(.rotatingImage(UIImage(named: "progressHUD")))
        }
        EspidyApiManager.sharedInstance.shipmentId(idShipment) { result in
            guard result.error == nil else {
                HUD.flash(.error, delay: 1.0) { _ in
                    print("Error getShipmentId \(result.error)")
                }
                return
            }
            if let shipmentId = result.value {
                if shipmentId.status != "error" {
                    HUD.flash(.success, delay: 1.0) { _ in
                        let feedBackViewController = self.storyboard!.instantiateViewController(withIdentifier: "feedBackViewController") as! FeedBackViewController
                        feedBackViewController.shipment = shipmentId
                        feedBackViewController.mainViewController = self.mainViewController
                        feedBackViewController.nvc = self.navigationController
                        self.present(feedBackViewController, animated: true, completion: nil)
                        NotificationCenter.default.removeObserver(self)
                    }
                } else {
                    HUD.flash(.error, delay: 1.0) { _ in
                        print("AlertMessageError \(shipmentId)")
                    }
                }
            }
        }
    }
    
    
    
    func hideButtonsOnlyClient(){
        self.btnPause.isHidden = true
        self.btnAmount.isHidden = true
    }
    
    @objc func updateDriverLocation() {
        setShipmentMethod()
        if Global_UserSesion?.personable_id == "Driver" {
            self.btnPause.isHidden = false
            self.btnAmount.isHidden = false
            EspidyApiManager.sharedInstance.trackingDriver(String(shipment?.id ?? 0), driverLocation: driverLocation!, completionHandler: { (error) in
                if error != nil {
                    print("error postTrackingDriverLocation \(error)")
                }
            })
        } else {
            self.btnPause.isHidden = true
            self.btnAmount.isHidden = true
            EspidyApiManager.sharedInstance.locationDriver(String(shipment!.driver!.id!)) { result in
                guard result.error == nil else {
                    // TODO: display error
//                    print("AlertMessageError \(result.error)")
                    return
                }
                
                if let newDriverLocation = result.value {
                    if newDriverLocation.lat != nil {
                        self.shipment!.driver?.espidyLocation = newDriverLocation
                        self.markerDriver.position = (self.shipment?.driver?.espidyLocation!.location)!
                        self.driverLocation = newDriverLocation.location
                        
                        self.updateGoogleMapCamera(self.driverLocation)
                    }
                }
            }
        }
    }
    
    func handleCancelShipment() {
        timer.invalidate()
        Global_UserSesion?.newService = true
        let storyboard = UIStoryboard(name: Storyboard.Main.rawValue, bundle: nil)
        let mainViewController2 = storyboard.instantiateViewController(withIdentifier: "mainViewController") as! MainViewController
        mainViewController2.locationManager.startUpdatingLocation()
//        mainViewController2.textFieldDropOff.text = ""
//        mainViewController2.markerDropOff.map =  nil
        self.navigationController?.setViewControllers([mainViewController2], animated: true)
        NotificationCenter.default.removeObserver(self)
    }
    
    func handleServiceInProgress() {
        
        serviceInProgress = true
        self.viewPinDestiny.imageProfile = "globo"
        if self.shipment!.dropoff_location?.location != nil {
            self.markerDestiny.position = (self.shipment!.dropoff_location?.location)!
        } else {
            self.markerDestiny.map = nil
        }
        updateGoogleMapCamera(driverLocation)
        self.btnPause.setImage(UIImage(named: "iconPause"), for: .normal)
    }
    
    // MARK: - Actions
    @IBAction func buttonCall(_ sender: UIButton) {
        if let phone = phoneUser {
            let url = URL(string: "tel://\(phone)")!
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:])
            }
        }
    }
    
    @IBAction func buttonMessage(_ sender: UIButton) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        nextViewController.shipment  = self.shipment
        //nextViewController.selectOperation = array[indexPath.row]
        navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    @IBAction func buttonGoogleMaps(_ sender: UIButton) {
            if  let pickUp_Location = pickUpLocation, let dropOff_Location = dropOffLocation {
                let pickUpLatitude = String(Double(pickUp_Location.latitude))
                let pickUpLongitude = String(Double(pickUp_Location.longitude))
                let dropOffLatitude = String(Double(dropOff_Location.latitude))
                let dropOffLongitude = String(Double(dropOff_Location.longitude))
                if let url = URL(string: "https://www.google.es/maps/dir/'\(pickUpLatitude),\(pickUpLongitude)'/'\(dropOffLatitude),\(dropOffLongitude)'") {
                    UIApplication.shared.open(url, options: [:])
                }
            }
    }
    
    @IBAction func buttonCancel(_ sender: UIButton) {
        
        EspidyApiManager.sharedInstance.shipmentCancelId(String(shipment!.id!), completionHandler: { (error) in
            if error != nil {
//                print("error cancel order \(error)")
            } else {
                self.handleCancelShipment()
            }
        })
        
    }
    
    @IBAction func handlePan(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: self.view)
        
        if let view = sender.view {
            if translation.x > 0 {
                view.center = CGPoint(x: view.center.x + translation.x, y: view.center.y)
                xViewLeft = xViewLeft + translation.x
            }
        }
        sender.setTranslation(CGPoint.zero, in: self.view)
        
        if sender.state == UIGestureRecognizerState.ended {
            let triggerValue = (xViewCenter * 2) / 3.5
            if xViewLeft >= triggerValue {
                UIView.animate(withDuration: 0.5, delay: 0.2, usingSpringWithDamping: 1, initialSpringVelocity: 1,
                   options: .curveEaseOut,
                   animations: {
                    sender.view!.center = CGPoint(x: self.xViewCenter * 3, y: sender.view!.center.y)
                }) { (completed: Bool) in
                    if self.viewSwipe.tag == 0 {
                        HUD.show(.rotatingImage(UIImage(named: "progressHUD")))
                        EspidyApiManager.sharedInstance.shipmentStartId(String(self.shipment!.id!),
                                                                            completionHandler: { (error) in
                            if error == nil {
                                HUD.flash(.success, delay: 1.0) { _ in
                                    self.setupFinishShipmentButton(withPanGesture: sender)
                                    
                                    self.handleServiceInProgress()
                                }
                            } else {
                                HUD.flash(.error, delay: 1.0) { _ in
                                    self.setupFinishShipmentButton(withPanGesture: sender)
                                }
                            }
                        })
                    } else {
                        HUD.show(.rotatingImage(UIImage(named: "progressHUD")))
                        EspidyApiManager.sharedInstance.shipmentFinishId(String(self.shipment!.id!),
                                                                             dropOff_location: self.driverLocation!,
                                                                             completionHandler: { (error) in
                            if error == nil {
                                self.handleSwipeToFinish()
                            } else {
                                HUD.flash(.error, delay: 1.0) { _ in
                                    self.setupFinishShipmentButton(withPanGesture: sender)
                                }
                            }
                        })
                    }
                    self.xViewLeft = 0
                }
            } else {
                UIView.animate(withDuration: 0.3, delay: 0.1, usingSpringWithDamping: 1, initialSpringVelocity: 3,
                    options: .curveEaseOut,
                    animations: {
                        sender.view!.center = CGPoint(x: self.xViewCenter, y: sender.view!.center.y)
                }) { (completed: Bool) in
                    self.xViewLeft = 0
                }
            }
        }
    }
    

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    }
    
    
    func changeIconButonPause(){
        if btnPause.currentImage == UIImage(named: "iconPause"){
            self.btnPause.setImage(UIImage(named: "iconPlay"), for: .normal)
            if let id = shipment?.id {
                self.pauseShipment(id: String(id))
            }
            
        }else{
            self.btnPause.setImage(UIImage(named: "iconPause"), for: .normal)
            if let id = shipment?.id {
                self.continueShipment(id: String(id))
            }
        }
    }
    
    // MARK: - Action Button Pause
    @IBAction func actionPause(_ sender: UIButton) {
        print("Realizar peticion al servidor")
        self.changeIconButonPause()
        
    }
    
    // MARK: - Action Show Dialog Amount
    @IBAction func actionShowDialog(_ sender: UIButton) {
        let modalViewController = storyboard?.instantiateViewController(withIdentifier: "AmountPaymentDialogViewController") as? AmountPaymentDialogViewController
        modalViewController?.modalPresentationStyle = .overCurrentContext
        modalViewController?.shipment = self.shipment
        if let vc = modalViewController {
            present(vc, animated: true, completion: nil)
        }
    }
    
    
    
    
}

// MARK: - CLLocationManagerDelegate
extension ShipmentProgressViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .authorizedWhenInUse {
            // Start getting update of user's location
            startLocationManager()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let newLocation = locations.last {
            if Global_UserSesion?.personable_id == "Driver" {
                location = newLocation
                
                updateGoogleMapCamera(newLocation.coordinate)
                
            }
        }
    }
}

private extension ShipmentProgressViewController {
    
    func setupFinishShipmentButton(withPanGesture sender: UIPanGestureRecognizer) {
        self.view.layoutIfNeeded()
        
        self.labelViewSwipe.text = "SWIPE TO FINISH!".localized
        self.labelViewSwipe.textColor = UIColor.ESPIDYColorRedL()
        self.imageViewViewSwipe.tintColor = UIColor.ESPIDYColorRedL()
        sender.view!.center = CGPoint(x: self.xViewCenter, y: sender.view!.center.y)
        self.viewSwipe.tag = 1
    }
}

// MARK: - GMSMapViewDelegate
extension ShipmentProgressViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
    }
}

// MARK: - GMSMapViewDelegate
extension ShipmentProgressViewController: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        // Check the result or perform other tasks.
        isSendingMSM = false
        // Dismiss the message compose view controller.
        controller.dismiss(animated: true, completion: nil)
    }
}


extension ShipmentProgressViewController: ProtocolChangeStateShipment{
    func pauseShipment(id: String) {
        presenter.pauseQuery(id: id)
    }
    
    func continueShipment(id: String) {
        presenter.continueQuery(id: id)
    }
    
    func answerQuery(answerQuery: String) {
        print("Respuesta ---> \(answerQuery)")
        switch answerQuery {
        case "SERVICE_IN_PAUSE":
            alertDialog(messageContent: "SERVICE_IN_PAUSE")
            break
            
        case "SERVICE_IN_PROGRESS":
            alertDialog(messageContent: "SERVICE_IN_PROGRESS")
            
            break
        default:
            alertDialog(messageContent: answerQuery.localized)
            if btnPause.currentImage == UIImage(named: "iconPlay"){
                self.btnPause.setImage(UIImage(named: "iconPause"), for: .normal)
            }else{
                self.btnPause.setImage(UIImage(named: "iconPause"), for: .normal)
            }
            break
        }
    }
    
    func alertDialog(messageContent: String){
        let alert = UIAlertController(title: "¡ATENTION!".localized, message: messageContent.localized, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

//crear protocolo para poner esta imagen en el boton icon-mensaje-notification
