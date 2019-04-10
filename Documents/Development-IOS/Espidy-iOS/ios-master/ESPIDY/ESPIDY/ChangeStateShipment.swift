//
//  ChangeStateShipment.swift
//  ESPIDY
//
//  Created by MUJICAM on 10/21/18.
//  Copyright © 2018 Kretum. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class ChangeStateShipmentServices{
    
    func pauseShipment(shipment_id: String, completionHandler: @escaping ( _ message: String?) ->()){
        let url = "https://api.espidy.com/v1/shipments/\(shipment_id)/pause"
        
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
                let json = JSON(response.result.value!)
                completionHandler(json["status"].stringValue)
                print("parar aqui")
                break
            case .failure(_):
                var errorMessage = "error conection"
                if let data = response.data{
                    let json = try? JSON(data: data)
                    if let message : String = json?["errors"]["shipment"][0].stringValue{
                        if !message.isEmpty{
                            errorMessage = message
                        }
                    }
                    
                }
                completionHandler(errorMessage)
                break
            }
        }
        
    }
    
    func continueShipment(shipment_id: String, completionHandler: @escaping ( _ message: String?) ->()){
        let url = "https://api.espidy.com/v1/shipments/\(shipment_id)/continue"
        
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
                let json = JSON(response.result.value!)
                completionHandler(json["status"].stringValue)
                print("parar aqui")
                break
            case .failure(_):
                var errorMessage = "error conection"
                if let data = response.data{
                    let json = try? JSON(data: data)
                    if let message : String = json?["errors"]["shipment"][0].stringValue{
                        if !message.isEmpty{
                            errorMessage = message
                        }
                    }
                    
                }
                completionHandler(errorMessage)
                break
            }
            
        }
        
    }

}
