//
//  CodeService.swift
//  ESPIDY
//
//  Created by Mac Hostienda Movil on 10/2/18.
//  Copyright © 2018 Kretum. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class CodeService{
    func asingCode(client_id: Int, identifier: String, completionHandler: @escaping (_ result: Bool?, _ message: String?) ->()){
        let parameters : Parameters = ["client_id" : client_id, "identifier" : identifier]
        let url = "https://api.espidy.com/v1/codes/assign"
        var header = [String:String]()
        if let uid = Global_UserSesion?.uid, let accessToken = Global_UserSesion?.accessToken, let client = Global_UserSesion?.client{
            header = ["uid": uid,
                      "access-token" : accessToken,
                      "client" : client]
        }
        
        Alamofire.request(url, method: .post, parameters: parameters,encoding: JSONEncoding.default, headers: header).validate().responseJSON  {
            response in
            switch response.result{
            case .success:
                let json = JSON(response.result.value!)
                
                if (json["status"].boolValue){
                    
                    completionHandler(true, json["message"].stringValue)
                }else{
                    completionHandler(false, json["message"].stringValue)
                }
                break
                
            case .failure:
                   completionHandler(false, "Error de Conexion")
                break
            }
            
            
            
        }
        
    }
}
