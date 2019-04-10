//
//  ResponseJSONObjectSerializable.swift
//  ESPIDY
//
//  Created by FreddyA on 9/6/16.
//  Copyright © 2016 Kretum. All rights reserved.
//

import Foundation
import SwiftyJSON

public protocol ResponseJSONObjectSerializable {
    init?(json: SwiftyJSON.JSON)
}