//
//  Settings.swift
//  ESPIDY
//
//  Created by FreddyA on 8/26/16.
//  Copyright © 2016 Kretum. All rights reserved.
//

import Foundation

let onboardingKey = "onboardingShown"
let userSesionKey = "UserSesion"

class Settings {
    
    class func groupDefaults() -> UserDefaults {
        return UserDefaults(suiteName: "espidy")!
    }
    
    //onBoarding
    class func registerDefaults() {
        let defaults = groupDefaults()
        defaults.register(defaults: [onboardingKey: false])
        //only test onBoarding
//        defaults.setBool(false, forKey: onboardingKey)
    }
    
    //User
    class func setUserAcount(_ user: User) {
        let defaults = groupDefaults()
        let userArray = [user]
        let userData = NSKeyedArchiver.archivedData(withRootObject: userArray)
        defaults.set(userData, forKey: userSesionKey)
    }
    
    class func getUserAcount() -> User? {
        let defaults = groupDefaults()
        let userData = defaults.object(forKey: userSesionKey) as? Data
        
        if let userData = userData {
            let userArray = NSKeyedUnarchiver.unarchiveObject(with: userData) as? [User]
            
            if let userArray = userArray {
                return userArray[0]
            }
        }
        return nil
    }
    
    class func removeUserAcount() {
        let defaults = groupDefaults()
        defaults.removeObject(forKey: userSesionKey)
    }
}
