//
//  Vehicule.swift
//  ESPIDY
//
//  Created by FreddyA on 11/24/16.
//  Copyright © 2016 Kretum. All rights reserved.
//

import Foundation
import SwiftyJSON

class Vehicle: ResponseJSONObjectSerializable {
    var id: Int?
    var brand: String?
    var model: String?
    var license_plates: String?
    
    required init?(json: JSON) {
        
        self.id = json["id"].int
        self.brand = json["brand"].string
        self.model = json["model"].string
        self.license_plates = json["license_plates"].string
        
    }
    
}
