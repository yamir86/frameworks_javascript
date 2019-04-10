//
//  DetailsHistoryViewController.swift
//  ESPIDY
//
//  Created by Mac Hostienda Movil on 9/6/18.
//  Copyright © 2018 Kretum. All rights reserved.
//

import UIKit
import MapKit

class DetailsHistoryViewController: UIViewController {

    @IBOutlet weak var viewGoogleMap: GMSMapView!
    
    var markerPickUpLocalitation : EspidyLocation?
    var markerDropOffLocalitation : EspidyLocation?
    
    var driverLocation: CLLocationCoordinate2D?
    
    // MarkerDriver
    let viewPinDriver: PinDriver = {
        var pin = PinDriver(frame: CGRect(x: 0, y: 0, width: 52, height: 84))
        return pin
    }()
    
    let viewPinDestiny: PinDestiny = {
        var pin = PinDestiny(frame: CGRect(x: 0, y: 0, width: 43, height: 69))
        return pin
    }()
    
    lazy var markerPickUp: GMSMarker = {
        var mark = GMSMarker()
        mark.iconView = self.viewPinDriver
        mark.map = self.viewGoogleMap
        return mark
    }()
    
    lazy var markerDropOff: GMSMarker = {
        var mark = GMSMarker()
        mark.iconView = self.viewPinDestiny
        mark.map = self.viewGoogleMap
        return mark
    }()
    
    /*
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
    */
    override func viewDidLoad() {
        super.viewDidLoad()

        
        if let markerPickUp = markerPickUpLocalitation?.location, let markerDropOff = markerDropOffLocalitation?.location{
            self.viewGoogleMap.camera = GMSCameraPosition(target: markerPickUp, zoom: 15, bearing: 0, viewingAngle: 0)
            self.markerPickUp.position = markerPickUp
            self.markerPickUp.map = viewGoogleMap
            
            self.viewGoogleMap.camera = GMSCameraPosition(target: markerDropOff, zoom: 15, bearing: 0, viewingAngle: 0)
            
            self.markerDropOff.position = markerDropOff
            self.markerDropOff.map = viewGoogleMap
            
            let bounds = GMSCoordinateBounds(coordinate: self.markerPickUp.position, coordinate: self.markerDropOff.position)
            let insets = UIEdgeInsetsMake(60, 100, 30, 100)
            let camera = self.viewGoogleMap.camera(for: bounds, insets: insets)
            if let camera = camera {
                self.viewGoogleMap.camera = camera
            } 
        }
        
        self.view.layoutIfNeeded()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


