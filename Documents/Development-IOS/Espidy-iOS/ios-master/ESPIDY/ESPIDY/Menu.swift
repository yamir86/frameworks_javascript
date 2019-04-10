//
//  Menu.swift
//  ESPIDY
//
//  Created by FreddyA on 9/5/16.
//  Copyright © 2016 Kretum. All rights reserved.
//

import Foundation

enum MenuName: String {
    case Cancel
    case Payments
    case History
    case Help
    case Settings
    case RedeemCode
    static let allValues = [Cancel, Payments, History, Help, Settings, RedeemCode]
    
    var name: String {
        switch self {
        case .Cancel:
            return "cancel"
        case .Payments:
            return "PAYMENTS".localized
        case .History:
            return "HISTORY".localized
        case .Help:
            return "HELP".localized
        case .Settings:
            return "SETTINGS".localized
        case .RedeemCode:
            return "RedeemCode".localized
        }
    }
    
}

class Menu: NSObject {
    let name: MenuName
    let imageName: String
    
    init(name: MenuName, imageName: String) {
        self.name = name
        self.imageName = imageName
    }
}
