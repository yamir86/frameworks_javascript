//
//  Driver.swift
//  ESPIDY
//
//  Created by FreddyA on 9/21/16.
//  Copyright © 2016 Kretum. All rights reserved.
//

import Foundation

class Person {
    var name: String?
    var image: String?
    var feedbackStars: Int?
    var espidyLocation: EspidyLocation?
    
    init(name: String, image: String, feedbackStars: Int) {
        self.name = name
        self.image = image
        self.feedbackStars = feedbackStars
    }
   
}
