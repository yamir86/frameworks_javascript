//
//  User.swift
//  ESPIDY
//
//  Created by FreddyA on 9/6/16.
//  Copyright © 2016 Kretum. All rights reserved.
//

import Foundation
import SwiftyJSON
import Firebase
import FirebaseInstanceID

class User: NSObject, NSCoding, ResponseJSONObjectSerializable {
    
    var id: Int?
    var name: String?
    var image: String?
    var avatar_file_size = 0
    var email: String?
    var phone: String?
    var password: String?
    var personable_id: String?
    var accessToken: String?
    var calification: Float?
    var client: String?
    var uid: String?
    var status: String?
    var full_messages: [String]?
    var errors: [String]?
    var shipmentFeedback = 0
    
    var vehicles: [Vehicle]?
    
    var token_fcm: String?
    
    var isInvisible = true
    
    var isShipmentActive = false
    var statusShipment = ""
    var shipmentActive: Shipment?
    var newService = true
    
    var espidyLocation: EspidyLocation?
    
    init(name: String, image: String, email: String?) {
        self.name = name
        self.image = image
        self.email = email
    }
    
    required init?(json: JSON) {
        self.status = json["status"].string
        self.full_messages = json["errors"]["full_messages"].arrayValue.map {$0.string!}
        
        self.errors = json["errors"].arrayValue.map {$0.string!}
        
        if let dataId = json["data"]["id"].int {
            self.id = dataId
            self.name = json["data"]["name"].string
            self.email = json["data"]["email"].string
            self.phone = json["data"]["phone"].string
            self.personable_id = json["data"]["personable_id"].string
            self.image = json["data"]["image"].string
            
            if let avatarFileSize = json["data"]["avatar_file_size"].int {
                self.avatar_file_size = avatarFileSize
            } else {
                self.avatar_file_size = 0
            }
            
            self.token_fcm = json["data"]["token_fcm"].string
            
//            self.calification = json["data"]["calification"].float
            if let calif = json["data"]["calification"].string {
                self.calification = Float(calif)
            } else {
                self.calification = 0
            }
            
            
            //vehicle
            self.vehicles = [Vehicle]()
            if let resultadoJSON = json["data"]["vehicle"].array {
                for (_, resultadoJSON) in resultadoJSON.enumerated() {
                    if let newVehicle = Vehicle(json: resultadoJSON) {
                        self.vehicles?.append(newVehicle)
                    }
                }
            }
            
        } else {
            self.id = json["id"].int
            self.name = json["name"].string
            self.email = json["email"].string
            self.phone = json["phone"].string
            self.personable_id = json["personable_id"].string
            self.image = json["image"].string
            
            if let avatarFileSize = json["avatar_file_size"].int {
                self.avatar_file_size = avatarFileSize
            } else {
                self.avatar_file_size = 0
            }
            
            self.token_fcm = json["token_fcm"].string
            
//            self.calification = json["calification"].float
            if let calif = json["calification"].string {
                self.calification = Float(calif)
            } else {
                self.calification = 0
            }
            
            //vehicle
            self.vehicles = [Vehicle]()
            if let resultadoJSON = json["vehicle"].array {
                for (_, resultadoJSON) in resultadoJSON.enumerated() {
                    if let newVehicle = Vehicle(json: resultadoJSON) {
                        self.vehicles?.append(newVehicle)
                    }
                }
            }
        }
        
        
    }
    
    
    
    required init(coder aDecoder: NSCoder) {
        self.id = aDecoder.decodeInteger(forKey: "id")
        self.name = aDecoder.decodeObject(forKey: "name") as? String
        self.email = aDecoder.decodeObject(forKey: "email") as? String
        self.phone = aDecoder.decodeObject(forKey: "phone") as? String
        self.personable_id = aDecoder.decodeObject(forKey: "personable_id") as? String
        self.image = aDecoder.decodeObject(forKey: "image") as? String
        self.avatar_file_size = aDecoder.decodeInteger(forKey: "avatar_file_size")
        self.accessToken = aDecoder.decodeObject(forKey: "accessToken") as? String
        self.client = aDecoder.decodeObject(forKey: "client") as? String
        self.uid = aDecoder.decodeObject(forKey: "uid") as? String
        self.token_fcm = aDecoder.decodeObject(forKey: "token_fcm") as? String
        self.password = aDecoder.decodeObject(forKey: "password") as? String
        self.shipmentFeedback = aDecoder.decodeInteger(forKey: "shipmentFeedback")
        
        if let isInvisible = aDecoder.decodeObject(forKey: "isInvisible") as? Bool {
            self.isInvisible = isInvisible
        } else {
            self.isInvisible = aDecoder.decodeBool(forKey: "isInvisible")
        }
        
        if let isShipmentActive = aDecoder.decodeObject(forKey: "isShipmentActive") as? Bool {
            self.isShipmentActive = isShipmentActive
        } else {
            self.isShipmentActive = aDecoder.decodeBool(forKey: "isShipmentActive")
        }
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.id!, forKey: "id")
        aCoder.encode(self.name, forKey: "name")
        aCoder.encode(self.email, forKey: "email")
        aCoder.encode(self.phone, forKey: "phone")
        aCoder.encode(self.personable_id, forKey: "personable_id")
        aCoder.encode(self.image, forKey: "image")
        aCoder.encode(self.avatar_file_size, forKey: "avatar_file_size")
        aCoder.encode(self.accessToken, forKey: "accessToken")
        aCoder.encode(self.client, forKey: "client")
        aCoder.encode(self.uid, forKey: "uid")
        aCoder.encode(self.token_fcm, forKey: "token_fcm")
        aCoder.encode(self.password, forKey: "password")
        aCoder.encode(self.isInvisible, forKey: "isInvisible")
        aCoder.encode(self.isShipmentActive, forKey: "isShipmentActive")
        aCoder.encode(self.statusShipment, forKey: "statusShipment")
        aCoder.encode(self.shipmentFeedback, forKey: "shipmentFeedback")
    }
}
