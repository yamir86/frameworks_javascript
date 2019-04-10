//
//  MainViewController.swift
//  ESPIDY
//
//  Created by FreddyA on 9/3/16.
//  Copyright © 2016 Kretum. All rights reserved.
//  7.784233, -72.206090

import UIKit
import MapKit
import Firebase
import CoreLocation
import VisualEffectView
import FirebaseMessaging
import FirebaseInstanceID
import IQKeyboardManagerSwift

//enum viewControllerId: String {
//    case PaymentsViewController = "paymentsViewController"
//    case HistoryViewController = "historyViewController"
//    case SettingsViewController = "settingsViewController"
//}

protocol MainViewControllerPushNotificationDelegate: class {
    func recivedPushDriverAcepted(_ shipment_id: String)
}

class MainViewController: UIViewController, SlideMenuDelegate {
    
    static let RefreshNotification = "RefreshNotification"
    
    weak var delegate: MainViewControllerPushNotificationDelegate?
    
    let mainStoryboard = UIStoryboard(name: Storyboard.Main.rawValue, bundle: nil)
    
    let imageSelectVehicle = ["food-select-mainview", "moto-select-mainview", "car-select-mainview"]
    let imageUnSelectVehicle = ["food-unselect-mainview", "moto-unselect-mainview", "car-unselect-mainview"]
//    let textVehicle = ["BIKE", "MOTORCYCLE", "CAR"]
    
    let locationManager = CLLocationManager()
    var location: CLLocation?
    var IsoCountryCode: String?
    var fetcher: GMSAutocompleteFetcher?
    
    let markerPickUp: GMSMarker = {
        var mark = GMSMarker()
        mark.iconView = PinMain(frame: CGRect(x: 0, y: 0, width: 136, height: 43))
        return mark
    }()
    
    let markerDropOff: GMSMarker = {
        var mark = GMSMarker()
        var pin = PinMain(frame: CGRect(x: 0, y: 0, width: 136, height: 43))
        pin.labelTitle.text = "DROP OFF".localized
        mark.iconView = pin
        return mark
    }()
    
    lazy var placesCollectionView: PlacesColletionView = {
        let places = PlacesColletionView()
        places.mainViewController = self
        places.delegate = self
        places.collectionView.alpha = 0
        return places
    }()
    
    var isSelectedPickUp = true
    
    var constraintTopViewPickUpLocation: NSLayoutConstraint?
    
    var blurView: VisualEffectView?
    
    var timer = Timer()
    
    var contador = 0
    // MARK: - Outlets
    @IBOutlet weak var barButtonItemMenu: UIBarButtonItem!
    @IBOutlet weak var collectionViewVehicles: UICollectionView!
    @IBOutlet weak var viewPickUpLocation: DesignableUIView!
    @IBOutlet weak var viewDropOffLocation: DesignableUIView!
    @IBOutlet weak var imageViewPinPickUp: UIImageView!
    @IBOutlet weak var imageViewPinDropOff: UIImageView!
    @IBOutlet weak var viewGoogleMap: GMSMapView!
    @IBOutlet var textFieldPickUp: UITextField!
    @IBOutlet var textFieldDropOff: UITextField!
    @IBOutlet var constraintBottomViewDropOff: NSLayoutConstraint!
    @IBOutlet weak var viewContentCollectionView: UIView!
    @IBOutlet weak var buttonPickup: UIButton!
    
    var nav: UINavigationController?
    
    // MARK: - Life cycle View
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 44))
        titleLabel.text = "espidy"
        titleLabel.textColor = UIColor.ESPIDYColorLight()
        titleLabel.font = UIFont(name: "Aclonica-Regular", size: 17)
        titleLabel.textAlignment = .center
        navigationItem.titleView = titleLabel
        
        NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.receivedNotification(_:)), name: NSNotification.Name(rawValue: MainViewController.RefreshNotification), object: nil)
        
        setupView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isExistsCreditCard()
        nav = self.navigationController
        
        getLocation()
        
//        PENDING
//        DRIVER_ACCEPTED
//        CANCELLED_BY_USER
//        CANCELLED_BY_DRIVER
//        SERVICE_IN_PROGRESS
//        COMPLETE_SERVICE
        
//        updateDriverLocation()
        if Global_UserSesion!.isShipmentActive {
            if Global_UserSesion?.personable_id != "Driver" {
                switch Global_UserSesion!.statusShipment {
                case "PENDING":
                    handlePickUpNow(true)
                case "DRIVER_ACCEPTED", "SERVICE_IN_PROGRESS":
                    let shipmentProgressViewController = self.storyboard!.instantiateViewController(withIdentifier: "shipmentProgressViewController") as! ShipmentProgressViewController
                    shipmentProgressViewController.titleNavigationBar = "SHIPMENT IN PROGRESS".localized
                    shipmentProgressViewController.mainViewController = self
                    shipmentProgressViewController.shipment = Global_UserSesion?.shipmentActive
                    navigationController?.setViewControllers([shipmentProgressViewController], animated: true)
                default:
                    break
                }
            } else {
                switch Global_UserSesion!.statusShipment {
                case "DRIVER_ACCEPTED", "SERVICE_IN_PROGRESS":
                    Global_UserSesion?.newService = false
                    let shipmentProgressViewController = self.storyboard!.instantiateViewController(withIdentifier: "shipmentProgressViewController") as! ShipmentProgressViewController
                    shipmentProgressViewController.titleNavigationBar = "SHIPMENT IN PROGRESS".localized
                    shipmentProgressViewController.mainViewController = self
                    shipmentProgressViewController.shipment = Global_UserSesion?.shipmentActive
                    navigationController?.setViewControllers([shipmentProgressViewController], animated: true)
                default:
                    break
                }
            }
        } else {
            if Global_UserSesion?.personable_id == "Driver" {
                if notificationPushLaunchingApp {
                    notificationPushLaunchingApp = false
                    if let dataUserInfo = dataUserInfo {
                        if Global_UserSesion!.newService {
                            Global_UserSesion?.newService = false
                            EspidyApiManager.sharedInstance.shipmentId(dataUserInfo["shipment_id"] as! String, completionHandler: { (result) in
                                guard result.error == nil else {
                                    // TODO: display error
                                    Global_UserSesion?.newService = true
                                    return
                                }
                                if let shipmentId = result.value {
                                    if shipmentId.status != "error" {
                                        self.requestService.shipment = shipmentId
                                        self.requestService.showView()
                                    } else {
                                        Global_UserSesion?.newService = true
                                    }
                                } else {
                                    Global_UserSesion?.newService = true
                                }
                            })
                        }
                    }
                }
            }
        }
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
    
    // MARK: - Request Service
    lazy var requestService: RequestService = {
        let request = RequestService()
        request.delegate = self
        return request
    }()
    
    // MARK: - Methods
    func setupView() {
       
        viewGoogleMap.delegate = self
        locationManager.delegate = self
        
        if Global_UserSesion?.personable_id != "Driver" {
        
//            // Set up the autocomplete filter.
            let filter = GMSAutocompleteFilter()
            filter.type = GMSPlacesAutocompleteTypeFilter.address
//            filter.country = "VE"
            fetcher = GMSAutocompleteFetcher(bounds: nil, filter: filter)
            fetcher?.delegate = self
            
            markerPickUp.map = viewGoogleMap
            
            let heightControls = CGFloat(234)
            viewGoogleMap.padding = UIEdgeInsets(top: self.topLayoutGuide.length, left: 0, bottom: heightControls, right: 0)
            
            let selectedIndexPath = IndexPath(item: 1, section: 0)
            collectionViewVehicles.selectItem(at: selectedIndexPath, animated: false, scrollPosition: UICollectionViewScrollPosition())
            
            let tapGestureViewPickUp = UITapGestureRecognizer(target: self, action: #selector(handleTapPickUp))
            let tapGestureDropOff = UITapGestureRecognizer(target: self, action: #selector(handleTapDropOff))
            
            viewPickUpLocation.addGestureRecognizer(tapGestureViewPickUp)
            viewDropOffLocation.addGestureRecognizer(tapGestureDropOff)
            
            activateViewLocation("viewPickUpLocation")
            textFieldPickUp.keyboardToolbar.doneBarButton.setTarget(self, action: #selector(self.doneAction(_:)))
            textFieldPickUp.clearButtonMode = .whileEditing
            textFieldDropOff.keyboardToolbar.doneBarButton.setTarget(self, action: #selector(self.doneAction(_:)))
            textFieldDropOff.clearButtonMode = .whileEditing
        } else {
            viewPickUpLocation.isHidden = true
            viewDropOffLocation.isHidden = true
            viewContentCollectionView.isHidden = true
            buttonPickup.isHidden = true
            viewGoogleMap.padding = UIEdgeInsets(top: self.topLayoutGuide.length, left: 0, bottom: self.bottomLayoutGuide.length, right: 0)
            
            timer = Timer.scheduledTimer(timeInterval: 120.0, target: self, selector: #selector(updateDriverLocation), userInfo: nil, repeats: true)
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
//            locationManager.delegate = self
            locationManager.distanceFilter = 5
            locationManager.startUpdatingLocation()
        }
    }
    
    @objc func handleTapPickUp(_ sender: UITapGestureRecognizer) {
//        activateViewLocation("viewPickUpLocation")
//        textFieldPickUp.becomeFirstResponder()
    }
    
    @objc func handleTapDropOff(_ sender: UITapGestureRecognizer) {
//        activateViewLocation("viewDropOffLocation")
//        textFieldDropOff.becomeFirstResponder()
    }
    
    @objc func doneAction(_ sender : UITextField) {
        guard !constraintBottomViewDropOff.isActive else {
            return
        }
        
        constraintTopViewPickUpLocation?.isActive = false
        constraintBottomViewDropOff.isActive = true
        blurView?.blurRadius = 4
        
        UIView.animate(withDuration: 0.4, delay: 0.05, options: UIViewAnimationOptions(), animations: {
            self.blurView?.blurRadius = 1
            if self.textFieldDropOff.text!.isNotEmpty {
                self.isSelectedPickUp = false
                let bounds = GMSCoordinateBounds(coordinate: self.markerPickUp.position, coordinate: self.markerDropOff.position)
                let insets = UIEdgeInsetsMake(60, 100, 30, 100)
                let camera = self.viewGoogleMap.camera(for: bounds, insets: insets)
                if let camera = camera {
                    self.viewGoogleMap.camera = camera
                } else {
                    self.viewGoogleMap.camera = GMSCameraPosition(target: self.markerPickUp.position,
                                                                  zoom: 15, bearing: 0, viewingAngle: 0)
                }
            } else {
                self.viewGoogleMap.camera = GMSCameraPosition(target: self.markerPickUp.position,
                                                              zoom: 15, bearing: 0, viewingAngle: 0)
            }
            self.view.layoutIfNeeded()
        }, completion: { (true) in
            self.blurView?.removeFromSuperview()
            self.activateViewLocation("viewPickUpLocation")
        })
    }
    
    func activateViewLocation(_ viewLocation: String) {
        if viewLocation == "viewPickUpLocation" {
            UIView.animate(withDuration: 0.3, delay: 0.1, options: UIViewAnimationOptions(), animations: {
                self.view.bringSubview(toFront: self.viewPickUpLocation)
                self.activateShadow(self.viewPickUpLocation, offSet: CGSize(width: 3, height: 3))
                self.deActivateShadow(self.viewDropOffLocation)
                self.imageViewPinPickUp.tintColor = UIColor.ESPIDYColorDark()
                self.textFieldPickUp.textColor = UIColor.ESPIDYColorDark()
                self.imageViewPinDropOff.tintColor = UIColor.ESPIDYColorBorderView()
                self.textFieldDropOff.textColor = UIColor.ESPIDYColorBorderView()
                
                }, completion: nil)
            
            isSelectedPickUp = true
            
        } else if viewLocation == "viewDropOffLocation" {
            UIView.animate(withDuration: 0.3, delay: 0.1, options: UIViewAnimationOptions(), animations: {
                self.view.bringSubview(toFront: self.viewDropOffLocation)
                self.activateShadow(self.viewDropOffLocation, offSet: CGSize(width: 3, height: -3))
                self.deActivateShadow(self.viewPickUpLocation)
                self.imageViewPinPickUp.tintColor = UIColor.ESPIDYColorBorderView()
                self.textFieldPickUp.textColor = UIColor.ESPIDYColorBorderView()
                self.imageViewPinDropOff.tintColor = UIColor.ESPIDYColorDark()
                self.textFieldDropOff.textColor = UIColor.ESPIDYColorDark()
                
                }, completion: nil)
            
            isSelectedPickUp = false
            
        }
    }
    
    func activateShadow(_ view: UIView, offSet: CGSize) {
        view.layer.shadowColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.25).cgColor
        view.layer.shadowOffset = offSet
        view.layer.shadowRadius = 4
        view.layer.shadowOpacity = 4
    }
    
    func deActivateShadow(_ view: UIView) {
        view.layer.shadowColor = UIColor.clear.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 0)
        view.layer.shadowRadius = 0
        view.layer.shadowOpacity = 0
    }
    
    func reverseGeocodeCoordinate(_ coordinate: CLLocationCoordinate2D) {
        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
            if let address = response?.firstResult() {
                let lines = address.lines! as [String]
                if self.isSelectedPickUp {
                    self.textFieldPickUp.text = lines.joined(separator: "\n")
                }
            }
        }
    }

    @objc func receivedNotification(_ notification: Notification) {
        DispatchQueue.main.async {
            guard let userInfo = notification.userInfo,
                let shipment_id = userInfo["shipment_id"] as? String,
                let shipment_status = userInfo["shipment_status"] as? String else {
                    print("No userInfo found in notification")
                    return
            }
            
            switch Global_UserSesion!.personable_id! {
            case "Driver":
                switch shipment_status {
                case "PENDING":
                    if Global_UserSesion!.newService {
                        Global_UserSesion?.newService = false
                        EspidyApiManager.sharedInstance.shipmentId(shipment_id, completionHandler: { (result) in
                            guard result.error == nil else {
                                // TODO: display error
                                Global_UserSesion?.newService = true
//                                print("AlertMessageError \(result.error)")
                                return
                            }
                            if let shipmentId = result.value {
                                if shipmentId.status != "error" {
                                    self.requestService.shipment = shipmentId
                                    self.requestService.showView()
                                } else {
//                                    print("AlertMessageError \(shipmentId)")
                                    Global_UserSesion?.newService = true
                                }
                            } else {
                                Global_UserSesion?.newService = true
                            }
                        })
                    }
                case "CANCELLED_BY_USER":
                    break
                default:
                    break
                }
                
            case "Client":
                switch shipment_status {
                case "DRIVER_ACCEPTED":
                    if self.contador == 0{
                        self.delegate?.recivedPushDriverAcepted(shipment_id)
                    }else{
                        print("Contador ---> \(self.contador)")
                    }
                    self.contador = self.contador + 1
                    
                    break
                case "SERVICE_IN_PROGRESS":
                    break
                case "COMPLETE_SERVICE", "PAYMENT_SUCCEEDED", "PAYMENT_CASH":
                    break
                case "CANCELLED_BY_DRIVER":
                    break
                default:
                    break
                }
            default:
                break
            }
            
        }
    }

    
    func handlePickUpNow(_ isShipmentActive: Bool)  {
        let confirmShippingViewController = self.storyboard!.instantiateViewController(withIdentifier: "confirmShippingViewController") as! ConfirmShippingViewController
        confirmShippingViewController.titleNavigationBar = "CONFIRM YOUR SHIPPING".localized
        confirmShippingViewController.mainViewController = self
        
        if isShipmentActive {
            confirmShippingViewController.shipment = Global_UserSesion?.shipmentActive
        } else {
            let indexPaths = collectionViewVehicles.indexPathsForSelectedItems
            let indexPath = indexPaths![0] as IndexPath
            
//            if markerDropOff.position.latitude == -180.0 && markerDropOff.position.longitude == -180.0
            
            if textFieldDropOff.text!.isEmpty {
                let shipment = Shipment(shippingMethod: ShippingMethod.allValues[indexPath.item],
                                        pickup_location: EspidyLocation(location: markerPickUp.position, address: textFieldPickUp.text ?? ""),
                                        dropoff_location: nil)
                confirmShippingViewController.shipment = shipment
                
            } else if markerDropOff.position.latitude == -180.0 && markerDropOff.position.longitude == -180.0 {
                let shipment = Shipment(shippingMethod: ShippingMethod.allValues[indexPath.item],
                                        pickup_location: EspidyLocation(location: markerPickUp.position, address: textFieldPickUp.text ?? ""),
                                        dropoff_location: EspidyLocation(location: nil, address: textFieldDropOff.text ?? ""))
                confirmShippingViewController.shipment = shipment
            } else {
                let shipment = Shipment(shippingMethod: ShippingMethod.allValues[indexPath.item],
                                        pickup_location: EspidyLocation(location: markerPickUp.position, address: textFieldPickUp.text ?? ""),
                                        dropoff_location: EspidyLocation(location: markerDropOff.position, address: textFieldDropOff.text ?? ""))
                confirmShippingViewController.shipment = shipment
            }
        }
        
        navigationController?.pushViewController(confirmShippingViewController, animated: true)
    }
    
    @objc func updateDriverLocation() {
        if Global_UserSesion?.personable_id == "Driver" {
            if let driverlocation = location?.coordinate {
                EspidyApiManager.sharedInstance.trackingDriver("", driverLocation: driverlocation, completionHandler: { (error) in
                    if error != nil {
                        print("error postTrackingDriverLocation \(error)")
//                    } else {
//                        print("Update Driver Location Success!!")
                    }
                })
            }
        }
    }
    
    // MARK: - Actions
    @IBAction func buttonPickUp(_ sender: DesignableUIButton) {
        if Global_UserSesion?.personable_id != "Driver" {
            if (textFieldPickUp.text ?? "").isEmpty || (textFieldDropOff.text ?? "").isEmpty {
                let alertView = UIAlertController(title: "Error!", message: "Enter Pick Up and Drop Off Address".localized, preferredStyle: .alert)
                alertView.addAction(UIAlertAction(title: "Ok", style: .default) { (result: UIAlertAction) -> Void in
                    self.textFieldPickUp.becomeFirstResponder()
                    })
                present(alertView, animated: true, completion: nil)
            } else {
                handlePickUpNow(false)
            }
        }
    }
    
    @IBAction func handleTextFieldChange(_ sender: UITextField) {
//        placeAutocomplete(sender.text!)
    }

}

// MARK: - CollectionViewVehicleService
extension MainViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ShippingMethod.allValues.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCellVehicle
        cell.imageVehicle.image = UIImage(named: imageUnSelectVehicle[indexPath.item])
        cell.imageVehicle.highlightedImage = UIImage(named: imageSelectVehicle[indexPath.item])
        cell.labelVehicle.text = ShippingMethod.allValues[indexPath.item].method
        cell.activeService = ShippingMethod.allValues[indexPath.item].active
        return cell
    }
}

extension MainViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionViewVehicles.frame.width / 3, height: collectionViewVehicles.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

// MARK: - CLLocationManagerDelegate
extension MainViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            // Start getting update of user's location
            startLocationManager()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let newLocation = locations.last {
            var isFirstTime = false
            if location == nil {
                isFirstTime = true
            }
            location = newLocation
            if isFirstTime {
                updateDriverLocation()
            }
            
            viewGoogleMap.camera = GMSCameraPosition(target: newLocation.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
            viewGoogleMap.isMyLocationEnabled = true
            viewGoogleMap.settings.myLocationButton = true
            
            if Global_UserSesion?.personable_id != "Driver" {
                markerPickUp.position = CLLocationCoordinate2DMake(newLocation.coordinate.latitude, newLocation.coordinate.longitude)
                locationManager.stopUpdatingLocation()
            }
        }
    }
}

// MARK: - GMSMapViewDelegate
extension MainViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        if isSelectedPickUp && Global_UserSesion?.personable_id != "Driver" {
            reverseGeocodeCoordinate(position.target)
//            markerPickUp.position = position.target
        }
    }
    
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        if isSelectedPickUp && Global_UserSesion?.personable_id != "Driver" {
//            reverseGeocodeCoordinate(position.target)
            markerPickUp.position = position.target
        }
    }
}

// MARK: - PlacesColletionViewDelegate
extension MainViewController: PlacesColletionViewDelegate {
    
    
    
    func didSelectedCell(_ placePrediction: GMSAutocompletePrediction) {
        let placesClient = GMSPlacesClient()
        
        
        placesClient.lookUpPlaceID(placePrediction.placeID!, callback: { (place: GMSPlace?, error: Error?) -> Void in
            if let error = error {
                print("lookup place id query error: \(error.localizedDescription)")
                return
            }
            
            if let place = place {
                if self.isSelectedPickUp {
                    self.textFieldPickUp.text = placePrediction.attributedFullText.string
                    self.viewGoogleMap.camera = GMSCameraPosition(target: place.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
                    self.markerPickUp.position = place.coordinate
                } else {
                    self.textFieldDropOff.text = placePrediction.attributedFullText.string
                    self.viewGoogleMap.camera = GMSCameraPosition(target: place.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
                    self.markerDropOff.map = self.viewGoogleMap
                    self.markerDropOff.position = place.coordinate
                }
            }
        })
        
        placesCollectionView.handleDismiss()
    }
}

// MARK: - UITextFieldDelegate
extension MainViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        //filter autocomplete
        if IsoCountryCode == nil {
            if Global_UserSesion?.personable_id != "Driver" {
                if let myLocation = location {
                    
                    let radius = Double(100 * 1000) //radius in meters (100km)
                    let region = MKCoordinateRegionMakeWithDistance(myLocation.coordinate, radius * 2, radius * 2)
                    let northEast = CLLocationCoordinate2DMake(region.center.latitude - region.span.latitudeDelta/2,
                                                               region.center.longitude - region.span.longitudeDelta/2)
                    let southWest = CLLocationCoordinate2DMake(region.center.latitude + region.span.latitudeDelta/2,
                                                               region.center.longitude + region.span.longitudeDelta/2)
                    
                    let bounds = GMSCoordinateBounds(coordinate: northEast, coordinate: southWest)
                    
//                    let geocoder = CLGeocoder()
//                    geocoder.reverseGeocodeLocation(myLocation) { (placemarks, error) in
//                        if placemarks?.count > 0 {
                            self.IsoCountryCode = String(describing: bounds) //placemarks![0].ISOcountryCode
//                            print("ISOCountryCode: \(self.IsoCountryCode)")
//                        }
//                    }
                    
                    // Set up the autocomplete filter.
                    let filter = GMSAutocompleteFilter()
                    filter.type = GMSPlacesAutocompleteTypeFilter.noFilter
//                    filter.country = IsoCountryCode
//                    fetcher?.autocompleteFilter = filter
                    fetcher = GMSAutocompleteFetcher(bounds: bounds, filter: filter)
                    fetcher?.delegate = self
                }
            }
        }
        
        if textField == textFieldPickUp {
            activateViewLocation("viewPickUpLocation")
        } else {
            activateViewLocation("viewDropOffLocation")
        }
        
        viewGoogleMap.settings.scrollGestures = false
        viewGoogleMap.settings.zoomGestures = false

        if constraintBottomViewDropOff.isActive {
            constraintBottomViewDropOff.isActive = false
            constraintTopViewPickUpLocation = NSLayoutConstraint(
                item: viewPickUpLocation,
                attribute: .top,
                relatedBy: .equal,
                toItem: self.topLayoutGuide,
                attribute: .bottom,
                multiplier: 1,
                constant: 8)
            constraintTopViewPickUpLocation?.isActive = true
            
            blurView = VisualEffectView(frame: viewGoogleMap.bounds)
            blurView?.blurRadius = 1
            blurView?.colorTint = UIColor.white
            blurView?.colorTintAlpha = 0.2
            blurView?.scale = 1
            viewGoogleMap.addSubview(blurView!)
            viewGoogleMap.bringSubview(toFront: blurView!)
            
            UIView.animate(withDuration: 0.5,
                                       delay: 0.1,
                                       options: UIViewAnimationOptions(),
                                       animations: {
                                        
                                        self.blurView?.blurRadius = 4
                                        self.view.layoutIfNeeded()
                                        
                }, completion: nil)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == textFieldDropOff && (textField.text?.isEmpty)! {
            markerDropOff.map = nil
        }
        viewGoogleMap.settings.scrollGestures = true
        viewGoogleMap.settings.zoomGestures = true
        placesCollectionView.handleDismiss()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        
        if newString.isNotEmpty {
            fetcher?.sourceTextHasChanged(newString)
        } else {
            placesCollectionView.handleDismiss()
        }
        
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        placesCollectionView.handleDismiss()
        return true
    }
}

// MARK: - GMSAutocompleteFetcherDelegate
extension MainViewController: GMSAutocompleteFetcherDelegate {
    func didAutocomplete(with predictions: [GMSAutocompletePrediction]) {
        placesCollectionView.places = predictions
        placesCollectionView.collectionView.reloadData()
        

        if self.isSelectedPickUp {
            if textFieldPickUp!.text!.isNotEmpty {
//                if placesCollectionView.collectionView.alpha == 0 {
                if !placesCollectionView.isVisible {
                    placesCollectionView.showPlaces()
                    UIView.animate(withDuration: 0.4,
                                               delay: 0.05,
                                               options: UIViewAnimationOptions(),
                                               animations: {
                                                
                                                self.placesCollectionView.collectionView.alpha = 1
                        }, completion: nil)
                }
            } else {
                placesCollectionView.handleDismiss()
            }
        } else {
            if textFieldDropOff!.text!.isNotEmpty {
//                if placesCollectionView.collectionView.alpha == 0 {
                if !placesCollectionView.isVisible {
                    placesCollectionView.showPlaces()
                    UIView.animate(withDuration: 0.4,
                                               delay: 0.05,
                                               options: UIViewAnimationOptions(),
                                               animations: {
                                                
                                                self.placesCollectionView.collectionView.alpha = 1
                        }, completion: nil)
                }
            } else {
                placesCollectionView.handleDismiss()
            }
        }
    }
    
    func didFailAutocompleteWithError(_ error: Error) {
//        print(error.localizedDescription)
    }
}

// MARK: - RequestServiceDelegate
extension MainViewController: RequestServiceDelegate {
    func acceptedService(_ shipment: Shipment) {
        shipment.driver = Global_UserSesion
        shipment.driver?.espidyLocation = EspidyLocation(location: (self.location?.coordinate)!, address: "")
        
        self.becomeFirstResponder()
        
        let shipmentProgressViewController = self.storyboard!.instantiateViewController(withIdentifier: "shipmentProgressViewController") as! ShipmentProgressViewController
        shipmentProgressViewController.mainViewController = self
        shipmentProgressViewController.titleNavigationBar = "SHIPMENT IN PROGRESS".localized
        shipmentProgressViewController.shipment = shipment
        
        UIApplication.shared.keyWindow?.rootViewController = nav
        nav!.setViewControllers([shipmentProgressViewController], animated: true)
        //        self.navigationController?.setViewControllers([shipmentProgressViewController], animated: true)

    }
   
}
