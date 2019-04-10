//
//  InstanPayDeliveryPresenter.swift
//  ESPIDY
//
//  Created by MUJICAM on 10/23/18.
//  Copyright © 2018 Kretum. All rights reserved.
//

import Foundation

protocol InstanPayDeliveryProtocol: NSObjectProtocol{
    func createPayDelivery(shipment_id: String, amount: String)
    func aceptPayDelivery(shipment_id: String)
    func cancelPayDelivery(shipment_id: String)
    
    func responseConsult(status: Int, message: String)
    
}


class InstanPayDeliveryPresenter{
    private let service: InstanPayDeliveryServices
    weak private var view: InstanPayDeliveryProtocol?
    
    init(service: InstanPayDeliveryServices){
        self.service = service
    }
    
    func attachView(view: InstanPayDeliveryProtocol){
        self.view = view
    }
    
    func detachView(){
        view = nil
    }
    
    func create(shipment_id: String, amount: String){
        self.service.instant_purchases(shipment_id: shipment_id, amount: amount) { (status, message) in
            if let status = status, let message = message{
                self.view?.responseConsult(status: status, message: message)
            }else{
                print("--->  func create en class InstanPayDeliveryPresenter line 42")
                self.view?.responseConsult(status: 500, message: "error conection".localized)
            }
        }
    }
    
    func accept(shipment_id: String){
        
    }
    
    func cancel(shipment_id: String){
        self.service.cancelInstant_purchases(shipment_id: shipment_id) { (status, message) in
            if let status = status, let message = message{
                self.view?.responseConsult(status: status, message: message)
            }else{
                print("--->  func create en class InstanPayDeliveryPresenter line 42")
                self.view?.responseConsult(status: 500, message: "error conection".localized)
            }
        }
    }
    
}
