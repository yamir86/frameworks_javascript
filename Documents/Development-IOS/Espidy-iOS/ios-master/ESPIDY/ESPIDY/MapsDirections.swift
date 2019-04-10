//
//  MapsDirections.swift
//  ESPIDY
//
//  Created by FreddyA on 12/9/16.
//  Copyright © 2016 Kretum. All rights reserved.
//

import Foundation
import SwiftyJSON

class MapsDirections: ResponseJSONObjectSerializable {
    var durationText: String?
    var durationSeconds: Int?
    var distanceMeters: Float?
    var estimatedCost: Float?
    
    required init?(json: JSON) {
        
        var routes = [JSON]()
        if let resultadoJSON = json["routes"].array {
            for (_, routesJSON) in resultadoJSON.enumerated() {
                routes.append(routesJSON)
            }
            
            if routes.count > 0 {
                if let routeJSON = routes[0].dictionary {
                    var legs = [JSON]()
                    if let resultJSON = routeJSON["legs"]?.array {
                        for (_, legsJSON) in resultJSON.enumerated() {
                            legs.append(legsJSON)
                        }
                        
                        if let legJSON = legs[0].dictionary {
                            self.durationText = legJSON["duration"]?["text"].string
                            self.durationSeconds = legJSON["duration"]?["value"].int
                            self.distanceMeters = legJSON["distance"]?["value"].float
                        }
                        
                    }
                }
            }
        } else if let estimatedCost = json["value"].float {
            self.estimatedCost = estimatedCost
        }
    }
}
