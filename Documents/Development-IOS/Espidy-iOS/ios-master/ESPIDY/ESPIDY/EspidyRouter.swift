//
//  EspidyRouter.swift
//  ESPIDY
//
//  Created by FreddyA on 9/24/16.
//  Copyright © 2016 Kretum. All rights reserved.
//

import Foundation
import Alamofire

enum EspidyRouter: URLRequestConvertible {
    case postRegister(parameters: Parameters)
    case postSignIn(parameters: Parameters)
    case postRegisterCreditCard(parameters: Parameters)
    case getCreditCards()
    case postRequestShipments(parameters: Parameters)
    case getShipments()
    case patchUpdateUser(id: String, parameters: Parameters)
    case patchUpdateUserTokenFCM(id: String, parameters: Parameters)
    case deleteCreditCard(id: String)
    case getShipmentId(id: String)
    case deleteSignOut()
    case postShipmentAcceptId(id: String)
    case postShipmentStartId(id: String)
    case postShipmentFinishId(id: String, parameters: Parameters)
    case postShipmentRateServiceId(id: String, parameters: Parameters)
    case postShipmentCancelId(id: String)
    case postTrackingDriver(parameters: Parameters)
    case getLocationDriver(id: String)
    case getShipmentsActive()
    case postRememberPassword(parameters: Parameters)
    case postLoginFacebook(parameters: Parameters)
    case postEstimatedCost(parameters: Parameters)
    case assign_Code(parameters: Parameters)
    
    static let baseURLString = "https://api.espidy.com"
    
    var method: HTTPMethod {
        switch self {
        case .postRegister, .postSignIn, .postRegisterCreditCard, .postRequestShipments,
             .postShipmentAcceptId, .postShipmentStartId, .postShipmentFinishId, .postShipmentRateServiceId,
             .postShipmentCancelId, .postTrackingDriver, .postRememberPassword, .postLoginFacebook,
             .postEstimatedCost,.assign_Code:
            return .post
        case .getCreditCards, .getShipments, .getShipmentId, .getLocationDriver, .getShipmentsActive:
            return .get
        case .patchUpdateUser, .patchUpdateUserTokenFCM:
            return .patch
        case .deleteCreditCard, .deleteSignOut:
            return .delete
        }
    }
    
    var path: String {
        switch self {
        case .postRegister:
            return "/v1/"
        case .postSignIn:
            return "/v1/sign_in"
        case .postRegisterCreditCard, .getCreditCards:
            return "/v1/credit_cards"
        case .postRequestShipments, .getShipments:
            return "/v1/shipments"
        case .patchUpdateUser(let id, _):
            if Global_UserSesion?.personable_id == "Driver" {
                return "/v1/drivers/\(id)"
            } else {
                return "/v1/clients/\(id)"
            }
        case .patchUpdateUserTokenFCM(let id, _):
            if Global_UserSesion?.personable_id == "Driver" {
                return "/v1/drivers/\(id)/token_fcm"
            } else {
                return "/v1/clients/\(id)/token_fcm"
            }
        case .deleteCreditCard(let id):
            return "/v1/credit_cards/\(id)"
        case .getShipmentId(let id):
            return "/v1/shipments/\(id)"
        case .deleteSignOut:
            return "/v1/sign_out"
        case .postShipmentAcceptId(let id):
            return "/v1/shipments/\(id)/accept"
        case .postShipmentStartId(let id):
            return "/v1/shipments/\(id)/start"
        case .postShipmentFinishId(let id, _):
            return "/v1/shipments/\(id)/finish"
        case .postShipmentRateServiceId(let id, _):
            return "/v1/shipments/\(id)/rate_service"
        case .postShipmentCancelId(let id):
            return "/v1/shipments/\(id)/cancel"
        case .postTrackingDriver:
            return "/v1/trackings"
        case .getLocationDriver(let id):
            return "/v1/drivers/\(id)/last_tracking"
        case .getShipmentsActive:
            return "/v1/shipments/active"
        case .postRememberPassword:
            return "/v1/password"
        case .postLoginFacebook:
            return "/v1/loginfacebook"
        case .postEstimatedCost:
            return "/cost"
        case .assign_Code:
            return "/v1/codes/assign"
        }
    }
    
    // MARK: URLRequestConvertible
    
    func asURLRequest() throws -> URLRequest {
        let url = try EspidyRouter.baseURLString.asURL()
        
        var urlRequest = URLRequest(url: url.appendingPathComponent(path))
        
        // Set headers...
        if let accessToken = Global_UserSesion?.accessToken,
            let uid = Global_UserSesion?.uid,
            let client = Global_UserSesion?.client {
            
            urlRequest.setValue("\(accessToken)", forHTTPHeaderField: "access-token")
            urlRequest.setValue("\(uid)", forHTTPHeaderField: "uid")
            urlRequest.setValue("\(client)", forHTTPHeaderField: "client")
        }
        
        urlRequest.httpMethod = method.rawValue
        
        switch self {
        case .postRegister(let parameters), .postSignIn(let parameters), .postRegisterCreditCard(let parameters),
             .postRequestShipments(let parameters), .patchUpdateUser(_, let parameters), .patchUpdateUserTokenFCM(_, let parameters),
             .postShipmentFinishId(_, let parameters), .postShipmentRateServiceId(_, let parameters),
             .postTrackingDriver(let parameters), .postRememberPassword(let parameters), .postLoginFacebook(let parameters), .assign_Code(let parameters):
            
            urlRequest = try URLEncoding.default.encode(urlRequest, with: parameters)
            
        case .postEstimatedCost(let parameters):
        
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest = try URLEncoding.default.encode(urlRequest, with: parameters)
            
        case .getCreditCards, .getShipments, .deleteCreditCard, .getShipmentId, .deleteSignOut, .postShipmentAcceptId,
             .postShipmentStartId, .postShipmentCancelId, .getLocationDriver, .getShipmentsActive:
            
            urlRequest = try URLEncoding.default.encode(urlRequest, with: nil)
        }
        
        return urlRequest
    }
}
