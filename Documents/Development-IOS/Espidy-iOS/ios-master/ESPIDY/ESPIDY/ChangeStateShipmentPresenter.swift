//
//  ChangeStateShipmentPresenter.swift
//  ESPIDY
//
//  Created by Mac Hostienda Movil on 10/22/18.
//  Copyright © 2018 Kretum. All rights reserved.
//

import Foundation

protocol ProtocolChangeStateShipment : NSObjectProtocol {
    
    func pauseShipment(id: String)
    func continueShipment(id: String)
    
    func answerQuery(answerQuery: String)
    
}

class ChangeStateShipmentPresenter{
    private let service : ChangeStateShipmentServices
    weak private var view : ProtocolChangeStateShipment?
    
    init(service: ChangeStateShipmentServices) {
        self.service = service
    }
    
    func attachView(view: ProtocolChangeStateShipment){
        self.view = view
    }
    
    func detachView(){
        view = nil
    }
    
    func pauseQuery(id: String){
        self.service.pauseShipment(shipment_id: id) { (result) in
            if let cad = result {
                self.view?.answerQuery(answerQuery: cad)
            }else{
                self.view?.answerQuery(answerQuery: "Algo Paso")
            }
            
        }
    }
    
    func continueQuery(id:  String){
        self.service.continueShipment(shipment_id: id) { (result) in
            if let cad = result {
                self.view?.answerQuery(answerQuery: cad)
            }else{
                self.view?.answerQuery(answerQuery: "Algo Paso")
            }
        }
    }
}
