//
//  Pickup_location.swift
//  ESPIDY
//
//  Created by FreddyA on 10/3/16.
//  Copyright © 2016 Kretum. All rights reserved.
//

import Foundation
import SwiftyJSON

class EspidyLocation: ResponseJSONObjectSerializable {
    var id: Int?
    var location: CLLocationCoordinate2D?
    var lat: String?
    var lng: String?
    var address: String?
    
    required init?(json: JSON) {
        //        self.status = json["status"].string
        //        self.errors = json["errors"].arrayValue.map {$0.string!}
        
        self.id = json["id"].int
        self.lat = json["lat"].string
        self.lng = json["lng"].string
        self.address = json["address"].string
        
        if let lat = self.lat, let lng = self.lng {
            let latitude = CLLocationDegrees(Float(lat)!)
            let longitude = CLLocationDegrees(Float(lng)!)
            self.location = CLLocationCoordinate2DMake(latitude, longitude)
        }
    }
    
    required init() {
    }
    
    init(location: CLLocationCoordinate2D?, address: String) {
        if let newLocation = location {
            self.location = newLocation
            self.lat = String(Float(newLocation.latitude))
            self.lng = String(Float(newLocation.longitude))
        }
        
        self.address = address
    }
}
