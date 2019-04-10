//
//  ReadCodePresenter.swift
//  ESPIDY
//
//  Created by Mac Hostienda Movil on 10/3/18.
//  Copyright © 2018 Kretum. All rights reserved.
//

import Foundation

protocol ProtocolRead: NSObjectProtocol {
    
    func consultacode(client_id: Int, code: String)
    func respuestacode(respuesta: Bool, respuestacode: String)
    
}

class ReaderPresenter{
    
    private let readService : CodeService
    weak private var readView : ProtocolRead?
    
    init(readService : CodeService){
        self.readService = readService
    }
    
    func attachView(view: ProtocolRead){
        readView = view
    }
    
    func detachView() {
        readView = nil
    }
    
    //
    func ConsultaCode(client_id: Int, code : String){
        self.readService.asingCode(client_id: client_id, identifier: code, completionHandler: {
            (status, message) in
            self.readView?.respuestacode(respuesta: status ?? false, respuestacode: message ?? "")
        })
    }
    
}
