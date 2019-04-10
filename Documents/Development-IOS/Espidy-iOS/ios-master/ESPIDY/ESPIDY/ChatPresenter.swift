//
//  ChatPresenter.swift
//  ESPIDY
//
//  Created by Mac Hostienda Movil on 10/19/18.
//  Copyright © 2018 Kretum. All rights reserved.
//

import Foundation


protocol ChatProtocol: NSObjectProtocol {
    
    func existChat(shipment_id: String)//checkar si existe el chat
    func respuestaExistChat(respuesta: Bool, idChat: Int, arrayMessages: [MessageModel]?) //respuesta si existe el chat o no
    
    func createChatRoom(shipment_id: String, message: String) //creamos el chat enviando un mensaje
    
    func sendMessage(conversation_id: Int, message: String) //enviamos mensaje directamente
    func respuestaSendMessage(status: Bool) //respues de enviar mensaje directamente
    
    func getMessages(arrayMessages: [MessageModel]) //Regresa el arreglo de los mensajes sirve para varias funciones de este protocolo
    func didError(message : String) //respusta para todos los errores en string
    
    func showConvertation(conversationsID: String) //
    
    
}

class ChatPresenter{
    private let chatService : ChatServices
    weak private var chatView : ChatProtocol?
    
    init(chatService: ChatServices) {
        self.chatService = chatService
    }
    
    func attachView(view: ChatProtocol){
        chatView = view
    }
    
    func detachView(){
        chatView = nil
    }
    
    
    func consultExistChat(shipment_id: String){
        self.chatService.checkExistConver(shipment_id: shipment_id, completionHandler: {
            (status,idChat, messages) in
            
            if let status = status{
                if let idChat = idChat ,let messages = messages{
                    self.chatView?.respuestaExistChat(respuesta: status,idChat:idChat,  arrayMessages: messages)
                }else{
                    print("---> Hay valores Falsos")
                    self.chatView?.respuestaExistChat(respuesta: status,idChat: 0,  arrayMessages: nil)
                }
            }
        })
    }
    
    func createChat(shipment_id: String, message: String){
        self.chatService.createChat(shipment_id: shipment_id, message: message, completionHandler: {
            (result, error) in
            
            if let resultado = result {
                self.chatView?.getMessages(arrayMessages: resultado)
            }else{
                if let error = error{
                    self.chatView?.didError(message: error)
                }
            }
        })
    }
    
    func send(conversation_id: Int, message: String){
        self.chatService.sendMessage(conversation_id: conversation_id, message: message) { (result) in
            if let resultado = result{
                switch resultado {
                case 200:
//                    self.chatService.showConversation(conversation_id: conversation_id, completionHandler: { (conversation_id, messages) in
//                        if let idChat = conversation_id ,let messages = messages{
//                            self.chatView?.respuestaExistChat(respuesta: true, idChat: idChat,  arrayMessages: messages)
//                        }
//                    })
                    self.chatView?.respuestaSendMessage(status: true)
                    
                    break
                default:
                    self.chatView?.respuestaSendMessage(status: true)
                    self.chatView?.didError(message: "La conversacion no existe o tiene problemas de conexión")
                }
            }
        }
    }
    
    func getConversation(conversationsID: String) {
        self.chatService.showConversation(conversation_id: conversationsID) { (status, arrayMessage) in
            if let status = status{
                switch status {
                case 200:
                    if let arrayMessage = arrayMessage{
                        self.chatView?.getMessages(arrayMessages: arrayMessage)
                    }
                    break
                    
                case 404:
                    self.chatView?.didError(message: "ERROR 404")
                    break
                default:
                    self.chatView?.didError(message: "ERROR 500")
                    break
                }
            }
        }
    }
    
    
}
