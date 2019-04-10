//
//  Shipment.swift
//  ESPIDY
//
//  Created by FreddyA on 10/3/16.
//  Copyright © 2016 Kretum. All rights reserved.
//

import Foundation
import SwiftyJSON

enum ShippingMethod: String {
    case Food
    case Motorcycle
    case Car
    
    static let allValues = [Food, Motorcycle, Car]
    
    var method: String {
        switch self {
        case .Food:
            return "BIKE".localized
        case .Motorcycle:
            return "MOTORCYCLE".localized
        case .Car:
            return "CAR".localized
        }
    }
    
    var active: Bool {
        switch self {
        case .Food:
            return false
        case .Motorcycle:
            return true
        case .Car:
            return true
        }
    }
}

class Shipment: ResponseJSONObjectSerializable {
    var id: Int?
    var client_id: Int?
    var client: User?
    var pickup_location: EspidyLocation?
    var pickup_location_id: Int?
    var dropoff_location: EspidyLocation?
    var dropoff_location_id: Int?
    var items: Int?
    var description: String?
    var shippingMethod: ShippingMethod?
    var shipping_method_id: Int?
    var status: String?
    var driver: User?
    var driver_id: Int?
    var rating_client: Int?
    var rating_driver: Int?
    var comment_client: String?
    var comment_driver: String?
    var cost: Double?
    var delivery_time: Int?
    var payment_method_id: Int?
    var credit_card_id: Int?
    var created_at : String?
    var date :Date = Date()
    var payment_method: Payment_method?
    var distance : Float?
    var dateString : String?
    required init?(json: JSON) {
//        self.status = json["status"].string
//        self.errors = json["errors"].arrayValue.map {$0.string!}
        
        self.id = json["id"].int
        self.client_id = json["client_id"].int
        self.pickup_location_id = json["pickup_location_id"].int
        self.dropoff_location_id = json["dropoff_location_id"].int
        self.items = json["items"].int
        self.description = json["description"].string
        self.shipping_method_id = json["shipping_method_id"].int
        self.status = json["status"].string
        self.driver_id = json["driver_id"].int
        self.rating_client = json["rating_client"].int
        self.rating_driver = json["rating_driver"].int
        self.comment_client = json["comment_client"].string
        self.comment_driver = json["comment_driver"].string
        self.cost = json["cost"].double
        self.delivery_time = json["delivery_time"].int
        self.payment_method_id = json["payment_method_id"].int
        self.credit_card_id = json["credit_card_id"].int
        self.created_at = json["created_at"].string
        self.distance = json["distance"].float
        
        //client & driver & pickUpLocation & dropOffLocation
        if let shipmentJSON = json.dictionary {
            if let jsonClient = shipmentJSON["client"] {
                self.client = User(json: jsonClient)
            }
            
            if let jsonDriver = shipmentJSON["driver"] {
                self.driver = User(json: jsonDriver)
            }
            
            if let jsonPickupLocation = shipmentJSON["pickup_location"] {
                self.pickup_location = EspidyLocation(json: jsonPickupLocation)
            }
            
            if let jsonDropoffLocation = shipmentJSON["dropoff_location"] {
                self.dropoff_location = EspidyLocation(json: jsonDropoffLocation)
            }
            if let jsonPayment_method = shipmentJSON["payment_method"]{
                self.payment_method = Payment_method(json: jsonPayment_method)
            }
        }
        
        if let shippingMethodId = self.shipping_method_id {
            self.shippingMethod = ShippingMethod.allValues[shippingMethodId - 1]
        } else {
//            print("error self.shipping_method_id = nil")
            self.shippingMethod = ShippingMethod.allValues[1]
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/mm/yyyy"
        if let fecha = created_at, let date = dateFormatter.date(from: fecha) {
            self.date = date
        }
        
        if let fecha = created_at {
            self.dateString = convertDateFormaterDDMMYYYY(fecha)
        }
        
    }
    
    required init() {
    }
    
    init(shippingMethod: ShippingMethod, driver: User, delivery_time: Int, cost: Double) {
        self.shippingMethod = shippingMethod
        self.driver = driver
        self.delivery_time = delivery_time
        self.cost = cost
    }
    
    init(shippingMethod: ShippingMethod, pickup_location: EspidyLocation, dropoff_location: EspidyLocation?) {
        self.shippingMethod = shippingMethod
        self.pickup_location = pickup_location
        self.dropoff_location = dropoff_location
    }
}

//
func convertDateFormaterDDMMYYYY(_ date: String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
    let localdate = dateFormatter.date(from: date)
    dateFormatter.dateFormat = "dd-MM-yyyy h:mm a"
    dateFormatter.amSymbol = "AM"
    dateFormatter.pmSymbol = "PM"
    if let fechaString = localdate{
        return dateFormatter.string(from: fechaString)
    }else{
        return date
    }
}








