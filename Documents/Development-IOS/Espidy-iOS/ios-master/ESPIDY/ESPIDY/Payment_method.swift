//
//  Payment_method.swift
//  ESPIDY
//
//  Created by Mac Hostienda Movil on 10/2/18.
//  Copyright © 2018 Kretum. All rights reserved.
//

import Foundation
import SwiftyJSON

class Payment_method : ResponseJSONObjectSerializable{
    var id: Int?
    var name: String?
    var created_at: String?
    var updated_at: String?
    //var created_date :Date = Date()
    //var updated_date :Date = Date()
    
    required init?(json: JSON) {
        self.id = json["id"].int
        self.name = json["name"].string
        self.created_at = json["created_at"].string
        self.updated_at = json["updated_at"].string
    }
    
    required init() {
    }
}
