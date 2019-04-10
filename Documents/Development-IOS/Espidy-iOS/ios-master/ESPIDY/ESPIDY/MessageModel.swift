//
//  MessageModel.swift
//  ESPIDY
//
//  Created by Mac Hostienda Movil on 10/19/18.
//  Copyright © 2018 Kretum. All rights reserved.
//

import Foundation
import SwiftyJSON

class MessageModel{
    private var _id: Int?
    private var _body: String?
    private var _conversation_id: Int?
    private var _user_id: Int?
    private var _created_at: String?
    private var _updated_at: String?
    
    var id: Int?{
        return _id
    }
    
    var body: String?{
        return _body
    }
    
    var conversation_id: Int?{
        return _conversation_id
    }
    
    var user_id: Int?{
        return _user_id
    }
    
    var created_at: String?{
        return _created_at
    }
    
    var updated_at: String?{
        return _updated_at
    }
    
    init(messageDict: Dictionary<String, Any>) {
        if let id = messageDict["id"] as? Int{
            self._id = id
        }
        
        if let body = messageDict["body"] as? String{
            self._body = body
        }
        
        if let conversation_id = messageDict["conversation_id"] as? Int{
            self._conversation_id = conversation_id
        }
        
        if let user_id = messageDict["user_id"] as? Int{
            self._user_id = user_id
        }
        
        if let created_at = messageDict["created_at"] as? String{
            self._created_at = created_at
        }
        
        if let updated_at = messageDict["updated_at"] as? String{
            self._updated_at = updated_at
        }
    }
    
}
