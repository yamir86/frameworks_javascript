//
//  InstanPayDelivery.swift
//  ESPIDY
//
//  Created by MUJICAM on 10/23/18.
//  Copyright © 2018 Kretum. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class InstanPayDeliveryServices{
    
    
//OnlyDriver----------------------------------------------------------------------------------------------------------------
    func instant_purchases(shipment_id: String, amount: String, completionHandler: @escaping (_ status: Int?, _ message: String?) ->()){
        let parameters : Parameters = ["shipment_id" : shipment_id, "amount" : amount]
        let url = "https://api.espidy.com/v1/instant_purchases"
        var header = [String:String]()
        if let uid = Global_UserSesion?.uid, let accessToken = Global_UserSesion?.accessToken, let client = Global_UserSesion?.client{
            header = ["uid": uid,
                      "access-token" : accessToken,
                      "client" : client]
        }
        
        Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: header).validate().responseJSON {
            response in
           
            switch response.result {
            case .success(_):
                if let resp = response.result.value{
                    let json = JSON(resp)
                    completionHandler(json["status"].intValue, json["message"].stringValue)
                }else{
                    print("---> error InstanPayDeliveryServices instant_purchases")
                    completionHandler(500, "error conection".localized)
                }
            case .failure(_):
                 completionHandler(500, "error conection".localized)
                break
                
            }
            
        }
        
    }
    
    
//Only Client----------------------------------------------------------------------------------------------------------------
    func aceptInstant_purchases(shipment_id: String, completionHandler: @escaping (_ status: Int?, _ message: String?) ->()){
        let url = "https://api.espidy.com/v1/instant_purchases/\(shipment_id)/accept"
        var header = [String:String]()
        if let uid = Global_UserSesion?.uid, let accessToken = Global_UserSesion?.accessToken, let client = Global_UserSesion?.client{
            header = ["uid": uid,
                      "access-token" : accessToken,
                      "client" : client]
        }
        
                Alamofire.request(url, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: header).validate().responseJSON {
                    response in
        
                    switch response.result {
        
                    case .success(_):
                        if let resp = response.result.value{
                            let json = JSON(resp)
                            completionHandler(json["status"].intValue, json["message"].stringValue)
                        }else{
                            print("---> error InstanPayDeliveryServices aceptInstant_purchases")
                            completionHandler(500, "error conection".localized)
                        }
                    case .failure(_):
                        completionHandler(500, "error conection".localized)
                    }
        
                }
    }
    
    func cancelInstant_purchases(shipment_id: String, completionHandler: @escaping (_ status: Int?, _ message: String?) ->()){
        let url = "https://api.espidy.com/v1/instant_purchases/\(shipment_id)/cancel"
        var header = [String:String]()
        if let uid = Global_UserSesion?.uid, let accessToken = Global_UserSesion?.accessToken, let client = Global_UserSesion?.client{
            header = ["uid": uid,
                      "access-token" : accessToken,
                      "client" : client]
        }
        
        Alamofire.request(url, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: header).validate().responseJSON {
            response in

            switch response.result {

            case .success(_):
                if let resp = response.result.value{
                    let json = JSON(resp)
                    completionHandler(json["status"].intValue, json["message"].stringValue)
                }else{
                    print("---> error InstanPayDeliveryServices cancelInstant_purchases")
                    completionHandler(500, "error conection".localized)
                }
                
            case .failure(_):
                completionHandler(500, "error conection".localized)
            }

        }
        
    }
    
    
}
