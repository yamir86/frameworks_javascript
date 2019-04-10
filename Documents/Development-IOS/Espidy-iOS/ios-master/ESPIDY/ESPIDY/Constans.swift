//
//  Constans.swift
//  ESPIDY
//
//  Created by MUJICAM on 8/30/18.
//  Copyright © 2018 Kretum. All rights reserved.
//

import Foundation
import UIKit



var existPayMethod = false
var isNewMessage = false

func isExistsCreditCard(){
    //var creditCards = [Credit_card]()
    
    EspidyApiManager.sharedInstance.creditCards { (result) in
        
        guard result.error == nil else {
            
            return
        }
        if let fetchedCreditCards = result.value {
            //creditCards.append(contentsOf: fetchedCreditCards)
            if fetchedCreditCards.count > 0{
                print("---> HAY TDC: \(fetchedCreditCards)\n")
                existPayMethod = true
            }else{
                existPayMethod = false
                print("---> NO HAY TDC\n")
            }
        }
    }
}


//Mastercard    5100 0000 0000 0016    12/2021 or 06/2021    123    CHE    Without limit    Yes
