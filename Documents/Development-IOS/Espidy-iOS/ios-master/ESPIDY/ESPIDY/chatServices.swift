//
//  chatServices.swift
//  ESPIDY
//
//  Created by Mac Hostienda Movil on 10/18/18.
//  Copyright © 2018 Kretum. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class ChatServices{
    
    
    func checkExistConver(shipment_id: String, completionHandler: @escaping (_ status: Bool?, _ idChat: Int?,_ result: [MessageModel]?) ->()){
        let url = "https://api.espidy.com/v1/conversations/exist/\(shipment_id)"
        var header = [String:String]()
        if let uid = Global_UserSesion?.uid, let accessToken = Global_UserSesion?.accessToken, let client = Global_UserSesion?.client{
            header = ["uid": uid,
                      "access-token" : accessToken,
                      "client" : client]
        }
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: header).validate().responseJSON {
            response in
            switch response.result{
            case .success:
                let json = JSON(response.result.value!)
                switch json["status"].intValue {
                case 200 :
                    if let contentDict = response.result.value as? Dictionary<String, Any>{
                        if let dict = contentDict["conversation"] as? [Dictionary<String, Any>]{
                            for indexList in dict{
                                let idConversation = indexList["id"] as? Int
                                if let dict2 = indexList["messages"] as? [Dictionary<String, Any>]{
                                    var array = [MessageModel]()
                                    for arrayMessages in dict2{
                                        array.append(MessageModel(messageDict: arrayMessages))
                                    }
                                    completionHandler(true,idConversation,array)
                                }
                            }
                        }
                    }
                    break
                    
                case 404 :
                    completionHandler(false,nil, nil)
                    break
                    
                default:
                    completionHandler(false, nil, nil)
                    break
                }
            case .failure:
                completionHandler(false, nil, nil)
                break
            }
        }
    }
    
    func createChat(shipment_id: String, message: String, completionHandler: @escaping (_ result: [MessageModel]?, _ error: String?) ->()){
        // /v1/conversations
        let url = "https://api.espidy.com/v1/conversations"


        let parameters : Parameters = ["shipment_id" : shipment_id , "message" : message]
        var header = [String:String]()
        if let uid = Global_UserSesion?.uid, let accessToken = Global_UserSesion?.accessToken, let client = Global_UserSesion?.client{
            header = ["uid": uid,
                      "access-token" : accessToken,
                      "client" : client]
        }
        
        Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: header).validate().responseJSON {
            response in
            
            switch response.result{
                case .success:
                    let json = JSON(response.result.value!)
                    switch json["status"].intValue {
                        case 200 :
                            if let contentDict = response.result.value as? Dictionary<String, Any>{
                                if let dict = contentDict["data"] as? Dictionary<String, Any>{
                                    //for indexList in dict{
                                        if let dict2 = dict["messages"] as? [Dictionary<String, Any>]{
                                            var array = [MessageModel]()
                                            for arrayMessages in dict2{
                                                array.append(MessageModel(messageDict: arrayMessages))
                                            }
                                            completionHandler(array,nil)
                                        }
                                    //}
                                }
                            }
                            
                        break
                    default:
                         completionHandler(nil, "No pudimos obtener la información")
                    }
                break
                
                case .failure:
                    completionHandler(nil, "No pudimos obtener la información")
                break
            }
        }
    }
    
    func sendMessage(conversation_id: Int, message: String, completionHandler: @escaping ( _ status: Int?) ->()){
        let url = "https://api.espidy.com/v1/messages"
        
        let parameters : Parameters = ["conversation_id" : conversation_id , "message" : message]
        var header = [String:String]()
        if let uid = Global_UserSesion?.uid, let accessToken = Global_UserSesion?.accessToken, let client = Global_UserSesion?.client{
            header = ["uid": uid,
                      "access-token" : accessToken,
                      "client" : client]
        }
        Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: header).validate().responseJSON {
            response in
            switch response.result{
                
            case .success(_):
                if let value = response.result.value {
                    let json = JSON(value)
                    completionHandler(json["status"].intValue)
                }
                break
            case .failure(_):
                completionHandler(500)
                break
            }
        }
        
    }
    
    
    
    func showConversation(conversation_id: String, completionHandler: @escaping (_ status: Int?,_ result: [MessageModel]?) ->()){
        let url = "https://api.espidy.com/v1/conversations/\(conversation_id)"
        var header = [String:String]()
        if let uid = Global_UserSesion?.uid, let accessToken = Global_UserSesion?.accessToken, let client = Global_UserSesion?.client{
            header = ["uid": uid,
                      "access-token" : accessToken,
                      "client" : client]
        }
        
        Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: header).validate().responseJSON {
            response in
            switch response.result{
            case .success:
                let json = JSON(response.result.value!)
                switch json["status"].intValue {
                case 200 :
                    if let contentDict = response.result.value as? Dictionary<String, Any>{
                        if let dict = contentDict["conversation"] as? Dictionary<String, Any>{
                            //for indexList in dict{
                                if let dict2 = dict["messages"] as? [Dictionary<String, Any>]{
                                    var array = [MessageModel]()
                                    for arrayMessages in dict2{
                                        array.append(MessageModel(messageDict: arrayMessages))
                                    }
                                    completionHandler(200,array)
                                }
                            //}
                        }
                    }
                    break
                    
                case 404 :
                    completionHandler(404, nil)
                    break
                    
                default:
                    completionHandler(404, nil)
                    break
                }
            case .failure:
                completionHandler(500, nil)
                break
            }
        }
        
    }
}
