//
//  EspidyApiManager.swift
//  ESPIDY
//
//  Created by FreddyA on 9/24/16.
//  Copyright © 2016 Kretum. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class EspidyApiManager {
    static let sharedInstance = EspidyApiManager()
    var alamofireManager: Alamofire.SessionManager
    
    init () {
        var defaultHeaders = Alamofire.SessionManager.defaultHTTPHeaders
        
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = defaultHeaders
        
        alamofireManager = Alamofire.SessionManager(configuration: configuration)
    }
    
    // MARK: - User
    //postRegister
    func registerUser(_ email: String, password: String, name: String, phone: String, completionHandler: @escaping (Result<User>, _ headerFields: [String: String]) -> Void) {

        let parameters: Parameters = [
            "email": email,
            "password": password,
            "personable_type": "Client",
            "name": name,
            "phone": phone
        ]
        
        print("parameters \(parameters)")
        
        alamofireManager.request(EspidyRouter.postRegister(parameters: parameters))
            .responseObject { (response: DataResponse<User>) in
                
                print("response.request \(response.request!)")  // original URL request
                print("response.response \(response.response!)") // HTTP URL response
                print("response.data \(response.data!)")     // server data
                print("response.result \(response.result)")   // result of response serialization
                
                if let headerFields = response.response?.allHeaderFields as? [String: String] {
                    completionHandler(response.result, headerFields)
                }
        }
    }
    
    //postLoginFacebook
    func loginFacebook(_ email: String, password: String, name: String, phone: String, completionHandler: @escaping (Result<User>, _ headerFields: [String: String]) -> Void) {
        
        let parameters: Parameters = [
            "email": email,
            "password": password,
            "personable_type": "Client",
            "name": name,
            "phone": phone
        ]
        
        alamofireManager.request(EspidyRouter.postLoginFacebook(parameters: parameters))
            .responseObject { (response: DataResponse<User>) in
                
                if let headerFields = response.response?.allHeaderFields as? [String: String] {
                    completionHandler(response.result, headerFields)
                }
        }
        
    }
    
    //postSignIn
    func signIn(_ email: String, password: String, completionHandler: @escaping (Result<User>, _ headerFields: [String: String]) -> Void) {
        
        let parameters: Parameters = [
            "email": email,
            "password": password
        ]
        
        alamofireManager.request(EspidyRouter.postSignIn(parameters: parameters))
            .responseObject { (response: DataResponse<User>) in
                if let headerFields = response.response?.allHeaderFields as? [String: String] {
                    completionHandler(response.result, headerFields)
                }
        }
        
    }
    
    //deleteSignOut
    func signOut(_ completionHandler: @escaping (NSError?) -> Void) {
        
        print("accessToken \(Global_UserSesion?.accessToken)")
        print("client \(Global_UserSesion?.client)")
        print("uid \(Global_UserSesion?.uid)")
        
        alamofireManager.request(EspidyRouter.deleteSignOut())
            .validate()
            .responseJSON { response in
                
                print("response.request \(response.request)")   // original URL request
                print("allHTTPHeaderFields \(response.request?.allHTTPHeaderFields)")   // original URL request
                print("response.response \(response.response)") // URL response
                print("response.result \(response.result)")     // result of response serialization
                
                switch response.result {
                case .success:
                    completionHandler(nil)
                case .failure(let error):
                    completionHandler(error as NSError)
                }
            }
    }
    
    //patchUpdateUserWithImage
    func updateUserWithImage(_ name: String,
                                  email: String,
                                  phone: String,
                                  password: String,
                                  image: UIImage,
                                  isChangedImage: Bool,
                                  completionHandler: @escaping (Result<User>) -> Void) {
        var URL: String
        
        if Global_UserSesion?.personable_id == "Driver" {
            URL = "https://api.espidy.com/v1/drivers/\((Global_UserSesion?.id)!)"
        } else {
            URL = "https://api.espidy.com/v1/clients/\((Global_UserSesion?.id)!)"
        }
        //        let URLavatar = "https://api.espidy.com/v1/clients/\((Global_UserSesion?.id)!)/avatar"
        
        let parameters = [
            "name": name,
            "email": email,
            "phone": phone
        ]
        
        let headers:[String: String] = [
            "access-token": (Global_UserSesion?.accessToken)!,
            "uid": (Global_UserSesion?.uid)!,
            "client": (Global_UserSesion?.client)!
        ]
        
        Alamofire.upload(multipartFormData: { multipartFormData in
            if isChangedImage {
                if let imageData = UIImageJPEGRepresentation(image, 0.5) {
                    multipartFormData.append(imageData, withName: "avatar", fileName: "avatar.jpg", mimeType: "image/jpeg")
                }
            }
            
            for (key, value) in parameters {
                multipartFormData.append(value.data(using: String.Encoding.utf8)!, withName: key)
            }
        }, to: URL, method: .patch, headers: headers, encodingCompletion: { encodingResult in
            
            switch encodingResult {
            case .success(let upload, _, _):
                upload.responseObject { (response: DataResponse<User>) in
                    
                    //                    print("response.request \(response.request)")   // original URL request
                    //                    print("response.response \(response.response)") // URL response
                    //                    print("response.result \(response.result)")     // result of response serialization
                    
                    if let headerFields = response.response?.allHeaderFields as? [String: String] {
                        if headerFields["access-token"] != nil {
                            Global_UserSesion?.accessToken = headerFields["access-token"]
                            Global_UserSesion?.client = headerFields["client"]
                            Global_UserSesion?.uid = headerFields["uid"]
                            
                            //                                print("accessToken \(Global_UserSesion?.accessToken)")
                            //                                print("client \(Global_UserSesion?.client)")
                            //                                print("uid \(Global_UserSesion?.uid)")
                        }
                        
                        completionHandler(response.result)
                    }
                }
            case .failure(let encodingError):
                //                    print("Error: \(encodingError)")
                break
            }
        })
        
    }
    
    
    //patchUpdateUser
    func updateUser(_ name: String,
                         email: String,
                         phone: String,
                         password: String,
                         image: UIImage,
                         isChangedImage: Bool,
                         completionHandler: @escaping (Result<User>) -> Void) {
        
        let parameters: Parameters = [
            "name": name,
            "email": email,
            "phone": phone
        ]
        
        alamofireManager.request(EspidyRouter.patchUpdateUser(id: String((Global_UserSesion?.id)!), parameters: parameters))
            .responseObject { (response: DataResponse<User>) in
                
                if let headerFields = response.response?.allHeaderFields as? [String: String] {
                    
                    if headerFields["access-token"] != nil {
                        Global_UserSesion?.accessToken = headerFields["access-token"]
                        Global_UserSesion?.client = headerFields["client"]
                        Global_UserSesion?.uid = headerFields["uid"]
                    }
                    
                    completionHandler(response.result)
                }
        }
        
    }
    
    //patchUpdateUserTokenFCM
    func updateUserTokenFCM(_ token_fcm: String,
                         completionHandler: @escaping (Result<User>) -> Void) {
        
        let parameters: Parameters = [
            "token_fcm": token_fcm
        ]
        
        alamofireManager.request(EspidyRouter.patchUpdateUserTokenFCM(id: String((Global_UserSesion?.id)!), parameters: parameters))
            .responseObject { (response: DataResponse<User>) in
                
                if let headerFields = response.response?.allHeaderFields as? [String: String] {
                    
                    if headerFields["access-token"] != nil {
                        Global_UserSesion?.accessToken = headerFields["access-token"]
                        Global_UserSesion?.client = headerFields["client"]
                        Global_UserSesion?.uid = headerFields["uid"]
                    }
                    
                    completionHandler(response.result)
                }
        }
        
    }
    
    //postRememberPassword
    func rememberPassword(_ email: String, completionHandler: @escaping (Error?) -> Void) {
        
        let parameters: Parameters = [
            "email": email
        ]
        
        alamofireManager.request(EspidyRouter.postRememberPassword(parameters: parameters))
            .validate()
            .responseJSON { response in
                
                if let headerFields = response.response?.allHeaderFields as? [String: String] {
                    
                    if headerFields["access-token"] != nil {
                        Global_UserSesion?.accessToken = headerFields["access-token"]
                        Global_UserSesion?.client = headerFields["client"]
                        Global_UserSesion?.uid = headerFields["uid"]
                    }
                    
                    switch response.result {
                    case .success:
                        completionHandler(nil)
                    case .failure(let error):
                        completionHandler(error)
                    }
                    
                }
        }
    }
    
    // MARK: - Credit Cards
    //postRegisterCreditCard
    func registerCreditCard(_ fullname: String,
                                card_number: String,
                                cvc_number: String,
                                card_expiration_month: String,
                                card_expiration_year: String,
                                completionHandler: @escaping (Result<Credit_card>) -> Void) {
        
        let parameters: Parameters = [
            "fullname": fullname,
            "card_number": card_number,
            "cvc_number": cvc_number,
            "card_expiration_month": card_expiration_month,
            "card_expiration_year": card_expiration_year
        ]
        
        alamofireManager.request(EspidyRouter.postRegisterCreditCard(parameters: parameters))
            .responseObject { (response: DataResponse<Credit_card>)
                in
                if let headerFields = response.response?.allHeaderFields as? [String: String] {
                    
                    if headerFields["access-token"] != nil {
                        Global_UserSesion?.accessToken = headerFields["access-token"]
                        Global_UserSesion?.client = headerFields["client"]
                        Global_UserSesion?.uid = headerFields["uid"]
                    }
                    
                    completionHandler(response.result)
                }
        }
    }
    
    //getCreditCards
    func creditCards(_ completionHandler: @escaping (Result<[Credit_card]>) -> Void) {
        
        alamofireManager.request(EspidyRouter.getCreditCards())
            .responseArray { (response: DataResponse<[Credit_card]>) in
                
//                print("response.request \(response.request)")   // original URL request
//                print("response.response \(response.response)") // URL response
                print("response.result \(response.result)")     // result of response serialization

                if let headerFields = response.response?.allHeaderFields as? [String: String] {
                    
                    if headerFields["access-token"] != nil {
                        Global_UserSesion?.accessToken = headerFields["access-token"]
                        Global_UserSesion?.client = headerFields["client"]
                        Global_UserSesion?.uid = headerFields["uid"]
                    }
                    
                    completionHandler(response.result)
                }
        }
        
    }
    
    //deleteCreditCard
    func deleteCreditCard(_ idCreditCard: String, completionHandler: @escaping (Error?) -> Void) {
        
        alamofireManager.request(EspidyRouter.deleteCreditCard(id: idCreditCard))
            .validate()
            .responseJSON { response in
                
                if let headerFields = response.response?.allHeaderFields as? [String: String] {
                    
                    if headerFields["access-token"] != nil {
                        Global_UserSesion?.accessToken = headerFields["access-token"]
                        Global_UserSesion?.client = headerFields["client"]
                        Global_UserSesion?.uid = headerFields["uid"]
                    }
                    
                    switch response.result {
                    case .success:
                        completionHandler(nil)
                    case .failure(let error):
                        completionHandler(error)
                    }
                    
                }
                
        }
    }
    
    // MARK: - Shipments
    //postRequestShipment
    func requestShipment(_ shipping_method_id: String,
                                items: String,
                                description: String,
                                pickup_location: EspidyLocation,
                                dropoff_location: EspidyLocation?,
                                payment_method_id: Int,
                                credit_card_id: Int,
                                completionHandler: @escaping (Result<Shipment>) -> Void) {
        
        let latitudePickUp = String(Double(pickup_location.location!.latitude))
        let longitudePickUp = String(Double(pickup_location.location!.longitude))
        let addressPickUp = pickup_location.address!
        
        var parameters: Parameters
        
        if let dropOff = dropoff_location {
            if let newLatitude = dropOff.location?.latitude {
                if let newAddress = dropOff.address {
                    let latitudeDropOff = String(Double(newLatitude))
                    let longitudeDropOff = String(Double(dropOff.location!.longitude))
                    let addressDropOff = newAddress
                    
                    parameters = [
                        "shipping_method_id": shipping_method_id,
                        "items": items,
                        "description": description,
                        "pickup_location": ["lat": latitudePickUp, "lng": longitudePickUp, "address": addressPickUp],
                        "dropoff_location": ["lat": latitudeDropOff, "lng": longitudeDropOff, "address": addressDropOff],
                        "payment_method_id": payment_method_id,
                        "credit_card_id": credit_card_id
                    ]
                } else {
                    parameters = [
                        "shipping_method_id": shipping_method_id,
                        "items": items,
                        "description": description,
                        "pickup_location": ["lat": latitudePickUp, "lng": longitudePickUp, "address": addressPickUp],
                        "payment_method_id": payment_method_id,
                        "credit_card_id": credit_card_id
                    ]
                }
            } else {
                if let addressDropOff = dropOff.address {
                    parameters = [
                        "shipping_method_id": shipping_method_id,
                        "items": items,
                        "description": description,
                        "pickup_location": ["lat": latitudePickUp, "lng": longitudePickUp, "address": addressPickUp],
                        "dropoff_location": ["address": addressDropOff],
                        "payment_method_id": payment_method_id,
                        "credit_card_id": credit_card_id
                    ]
                } else {
                    parameters = [
                        "shipping_method_id": shipping_method_id,
                        "items": items,
                        "description": description,
                        "pickup_location": ["lat": latitudePickUp, "lng": longitudePickUp, "address": addressPickUp],
                        "payment_method_id": payment_method_id,
                        "credit_card_id": credit_card_id
                    ]
                }
            }
        } else {
            parameters = [
                "shipping_method_id": shipping_method_id,
                "items": items,
                "description": description,
                "pickup_location": ["lat": latitudePickUp, "lng": longitudePickUp, "address": addressPickUp],
                "payment_method_id": payment_method_id,
                "credit_card_id": credit_card_id
            ]
        }
        
        parameters["sound"] = "smack-that-bitch.caf"
        
        print("parameters \(parameters)")
        
        alamofireManager.request(EspidyRouter.postRequestShipments(parameters: parameters))
            .responseObject { (response: DataResponse<Shipment>) in
                
//                print("response.request \(response.request)")   // original URL request
//                print("response.response \(response.response)") // URL response
//                print("response.result \(response.result)")     // result of response serialization
                
                if let headerFields = response.response?.allHeaderFields as? [String: String] {
                    
                    if headerFields["access-token"] != nil {
                        Global_UserSesion?.accessToken = headerFields["access-token"]
                        Global_UserSesion?.client = headerFields["client"]
                        Global_UserSesion?.uid = headerFields["uid"]
                    }
                    
                    completionHandler(response.result)
                }
        }
    }
    
    //getShipments
    func shipments(_ completionHandler: @escaping (Result<[Shipment]>) -> Void) {
        alamofireManager.request(EspidyRouter.getShipments())
            .responseArray { (response: DataResponse<[Shipment]>) in
                
                if let headerFields = response.response?.allHeaderFields as? [String: String] {
                    
                    if headerFields["access-token"] != nil {
                        Global_UserSesion?.accessToken = headerFields["access-token"]
                        Global_UserSesion?.client = headerFields["client"]
                        Global_UserSesion?.uid = headerFields["uid"]
                    }
                   
                    completionHandler(response.result)
                }
        }
        
    }
    
    //getShipmentId
    func shipmentId(_ idShipment: String, completionHandler: @escaping (Result<Shipment>) -> Void) {
       
        alamofireManager.request(EspidyRouter.getShipmentId(id: idShipment)).responseObject { (response: DataResponse<Shipment>) in
                
                if let headerFields = response.response?.allHeaderFields as? [String: String] {
                    if headerFields["access-token"] != nil {
                        Global_UserSesion?.accessToken = headerFields["access-token"]
                        Global_UserSesion?.client = headerFields["client"]
                        Global_UserSesion?.uid = headerFields["uid"]
                    }
                    
                    completionHandler(response.result)
                }
        }
        
    }
    
    //postShipmentAcceptId
    func shipmentAcceptId(_ idShipment: String, completionHandler: @escaping (Error?) -> Void) {
        
        alamofireManager.request(EspidyRouter.postShipmentAcceptId(id: idShipment))
            .validate()
            .responseJSON { response in
                
                if let headerFields = response.response?.allHeaderFields as? [String: String] {
                    
                    if headerFields["access-token"] != nil {
                        Global_UserSesion?.accessToken = headerFields["access-token"]
                        Global_UserSesion?.client = headerFields["client"]
                        Global_UserSesion?.uid = headerFields["uid"]
                    }
                    
                    switch response.result {
                    case .success:
                        completionHandler(nil)
                    case .failure(let error):
                        completionHandler(error)
                    }
                    
                }
        }
    }
    
    //postShipmentStartId
    func shipmentStartId(_ idShipment: String, completionHandler: @escaping (Error?) -> Void) {
        
        alamofireManager.request(EspidyRouter.postShipmentStartId(id: idShipment))
            .validate()
            .responseJSON { response in
                
                if let headerFields = response.response?.allHeaderFields as? [String: String] {
                    
                    if headerFields["access-token"] != nil {
                        Global_UserSesion?.accessToken = headerFields["access-token"]
                        Global_UserSesion?.client = headerFields["client"]
                        Global_UserSesion?.uid = headerFields["uid"]
                    }
                    
                    switch response.result {
                    case .success:
                        completionHandler(nil)
                    case .failure(let error):
                        completionHandler(error)
                    }
                    
                }
        }
    }
    
    //postShipmentFinishId
    func shipmentFinishId(_ idShipment: String, dropOff_location: CLLocationCoordinate2D, completionHandler: @escaping (Error?) -> Void) {
        
        let latitudeDropOff = String(Double(dropOff_location.latitude))
        let longitudeDropOff = String(Double(dropOff_location.longitude))
        
        let parameters: Parameters = [
            "dropoff_location": [
                "name": "finish",
                "lat": latitudeDropOff,
                "lng": longitudeDropOff
            ]
        ]
        
        print("Finish parameters \(parameters)")
        
        alamofireManager.request(EspidyRouter.postShipmentFinishId(id: idShipment, parameters: parameters))
            .validate()
            .responseJSON { response in
                
//                print("response.request \(response.request)")   // original URL request
//                print("response.response \(response.response)") // URL response
//                print("response.result \(response.result)")     // result of response serialization
                
                if let headerFields = response.response?.allHeaderFields as? [String: String] {
                    
                    if headerFields["access-token"] != nil {
                        Global_UserSesion?.accessToken = headerFields["access-token"]
                        Global_UserSesion?.client = headerFields["client"]
                        Global_UserSesion?.uid = headerFields["uid"]
                        
//                        print("accessToken \(Global_UserSesion?.accessToken)")
//                        print("client \(Global_UserSesion?.client)")
//                        print("uid \(Global_UserSesion?.uid)")
                        
                    }
                    
                    switch response.result {
                    case .success:
                        completionHandler(nil)
                    case .failure(let error):
                        completionHandler(error)
                    }
                    
                }
        }
    }
    
    //postShipmentRateServiceId
    func shipmentRateServiceId(_ idShipment: String, rating: String, comment: String, completionHandler: @escaping (Error?) -> Void) {
        
        var parameters: Parameters
        
        if Global_UserSesion?.personable_id == "Driver" {
            parameters = [
                "rating_driver": rating,
                "comment_driver": comment
            ]
        } else {
            parameters = [
                "rating_client": rating,
                "comment_client": comment
            ]
        }

        alamofireManager.request(EspidyRouter.postShipmentRateServiceId(id: idShipment, parameters: parameters))
            .validate()
            .responseJSON { response in
                
                if let headerFields = response.response?.allHeaderFields as? [String: String] {
                    
                    if headerFields["access-token"] != nil {
                        Global_UserSesion?.accessToken = headerFields["access-token"]
                        Global_UserSesion?.client = headerFields["client"]
                        Global_UserSesion?.uid = headerFields["uid"]
                    }
                    
                    switch response.result {
                    case .success:
                        completionHandler(nil)
                    case .failure(let error):
                        completionHandler(error)
                    }
                    
                }
        }
    }
    
    //postShipmentCancelId
    func shipmentCancelId(_ idShipment: String, completionHandler: @escaping (Error?) -> Void) {
        
        alamofireManager.request(EspidyRouter.postShipmentCancelId(id: idShipment))
            .validate()
            .responseJSON { response in
                
//                print("response.request \(response.request)")   // original URL request
//                print("response.response \(response.response)") // URL response
//                print("response.result \(response.result)")     // result of response serialization
                
                if let headerFields = response.response?.allHeaderFields as? [String: String] {
                    
                    if headerFields["access-token"] != nil {
                        Global_UserSesion?.accessToken = headerFields["access-token"]
                        Global_UserSesion?.client = headerFields["client"]
                        Global_UserSesion?.uid = headerFields["uid"]
                    }
                    
                    switch response.result {
                    case .success:
                        completionHandler(nil)
                    case .failure(let error):
                        completionHandler(error)
                    }
                    
                }
        }
    }
    
    //getShipmentsActive
    func shipmentsActive(_ completionHandler: @escaping (Result<[Shipment]>) -> Void) {
        
        alamofireManager.request(EspidyRouter.getShipmentsActive())
            .validate()
            .responseArray { (response: DataResponse<[Shipment]>) in
                
                if let headerFields = response.response?.allHeaderFields as? [String: String] {
                    if headerFields["access-token"] != nil {
                        Global_UserSesion?.accessToken = headerFields["access-token"]
                        Global_UserSesion?.client = headerFields["client"]
                        Global_UserSesion?.uid = headerFields["uid"]
                    }
                    
                    completionHandler(response.result)
                }
        }
        
    }
    
    func estimatedCost(km: String, time: String, method: Int, completionHandler: @escaping (Result<MapsDirections>?) -> Void) {
        let parameters: Parameters = [
            "km": km,
            "time": time,
            "user_id": Global_UserSesion?.id ?? 0,
            "shipping_method": method
        ]
        
        let headers = ["access-token": Global_UserSesion?.accessToken ?? "",
                       "uid": Global_UserSesion?.uid ?? "",
                       "client": Global_UserSesion?.client ?? ""]
        
        do {
            let url = try EspidyRouter.baseURLString.asURL().appendingPathComponent("cost")
            
            Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
                .responseObject { (response: DataResponse<MapsDirections>) in
                    completionHandler(response.result)
            }
        } catch {
            print("error while getting url")
            completionHandler(nil)
        }

    }
    
    // MARK: - Driver
    //postTrackingDriver
    func trackingDriver(_ idDriver: String, driverLocation: CLLocationCoordinate2D, completionHandler: @escaping (Error?) -> Void) {
        
        let latitudeDriverLocation = String(Double(driverLocation.latitude))
        let longitudeDriverLocation = String(Double(driverLocation.longitude))
        
        let parameters: Parameters = [
            "lat": latitudeDriverLocation,
            "lng": longitudeDriverLocation
        ]

        alamofireManager.request(EspidyRouter.postTrackingDriver(parameters: parameters))
            .validate()
            .responseJSON { response in
                
                /*
                print("response.request \(response.request!)")  // original URL request
                print("response.response \(response.response!)") // HTTP URL response
                print("response.data \(response.data!)")     // server data
                print("response.result \(response.result)")   // result of response serialization
                */
                
                if let headerFields = response.response?.allHeaderFields as? [String: String] {
                    
                    if headerFields["access-token"] != nil {
                        Global_UserSesion?.accessToken = headerFields["access-token"]
                        Global_UserSesion?.client = headerFields["client"]
                        Global_UserSesion?.uid = headerFields["uid"]
                    }
                    
                    switch response.result {
                    case .success:
                        completionHandler(nil)
                    case .failure(let error):
                        completionHandler(error)
                    }
                    
                }
        }
    }
    
    //getLocationDriver
    func locationDriver(_ idDriver: String, completionHandler: @escaping (Result<EspidyLocation>) -> Void) {
        
        alamofireManager.request(EspidyRouter.getLocationDriver(id: idDriver))
            .responseObject { (response: DataResponse<EspidyLocation>) in
                if let headerFields = response.response?.allHeaderFields as? [String: String] {
                    
                    if headerFields["access-token"] != nil {
                        Global_UserSesion?.accessToken = headerFields["access-token"]
                        Global_UserSesion?.client = headerFields["client"]
                        Global_UserSesion?.uid = headerFields["uid"]
                    }
                    
                    completionHandler(response.result)
                }
        }
    }
}
