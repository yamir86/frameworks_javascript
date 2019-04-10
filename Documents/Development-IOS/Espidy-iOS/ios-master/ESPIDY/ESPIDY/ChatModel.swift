//
//  ChatModel.swift
//  ESPIDY
//
//  Created by Mac Hostienda Movil on 10/19/18.
//  Copyright © 2018 Kretum. All rights reserved.
//

import Foundation
import SwiftyJSON
import Firebase
import FirebaseInstanceID

class ChatModel: NSObject, NSCoding, ResponseJSONObjectSerializable {
    
    var id : Int?
    var is_open: Bool?
    var created_at: String?
    var updated_at : String?
    
    var user_id: Int?
    var shipment_id: Int?
    

    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.id, forKey: "id")
        aCoder.encode(self.is_open, forKey: "is_open")
        aCoder.encode(self.created_at, forKey: "created_at")
        aCoder.encode(self.updated_at, forKey: "updated_at")
        aCoder.encode(self.user_id, forKey: "user_id")
        aCoder.encode(self.shipment_id, forKey: "shipment_id")
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.id = aDecoder.decodeInteger(forKey: "id")
        self.is_open = aDecoder.decodeObject(forKey: "is_open") as? Bool
        self.created_at = aDecoder.decodeObject(forKey: "created_at") as? String
        self.updated_at = aDecoder.decodeObject(forKey: "updated_at") as? String
        self.user_id = aDecoder.decodeInteger(forKey: "user_id")
        self.shipment_id = aDecoder.decodeInteger(forKey: "shipment_id")
    }
    
    required init?(json: JSON) {
        
        if let dataId = json["data"]["id"].int {
            self.id = dataId
            self.is_open = json["data"]["is_open"].bool
            self.created_at = json["data"]["created_at"].string
            self.updated_at = json["data"]["updated_at"].string
            self.user_id = json["data"]["user_id"].int
            self.shipment_id = json["data"]["shipment_id"].int
            
//            self.messages = [MessageModel]()
//            if let resultadoJSON = json["data"]["messages"].array{
//                for (_, resultadoJSON) in resultadoJSON.enumerated(){
//                    if let newMessage = MessageModel(json: resultadoJSON){
//                        self.messages?.append(newMessage)
//                    }
//                }
//            }
        }
        
    }
}
