//
//  SplashViewController.swift
//  ESPIDY
//
//  Created by FreddyA on 11/25/16.
//  Copyright © 2016 Kretum. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        EspidyApiManager.sharedInstance.shipmentsActive { (result) in
            print("result.error \(result.error) result.isFailure \(result.isFailure) result.isSuccess \(result.isSuccess)")
            
            if let shipmentsActive = result.value {
                if shipmentsActive.count > 0 {
                    let shipmentActive = shipmentsActive[0]
                    if let statusShipment = shipmentActive.status {
                        Global_UserSesion?.shipmentActive = shipmentActive
                        Global_UserSesion?.statusShipment = statusShipment
                        Global_UserSesion?.isShipmentActive = true
                    } else {
                        Global_UserSesion?.shipmentActive = nil
                        Global_UserSesion?.statusShipment = ""
                        Global_UserSesion?.isShipmentActive = false
                    }
                } else {
                    Global_UserSesion?.shipmentActive = nil
                    Global_UserSesion?.statusShipment = ""
                    Global_UserSesion?.isShipmentActive = false
                }
                
                if Global_UserSesion?.personable_id != "Driver" {
                    EspidyApiManager.sharedInstance.creditCards { (result) in
                        guard result.error == nil else {
                            // TODO: display error
                            print("AlertMessageError \(result.error)")
                            
                            let ad = UIApplication.shared.delegate as! AppDelegate
                            ad.launchStoryboard(Storyboard.Main, animated: false)
                            
                            return
                        }
                        
                        if let fetchedCreditCards = result.value {
                            Global_creditCards.append(contentsOf: fetchedCreditCards)
                            
                            let ad = UIApplication.shared.delegate as! AppDelegate
                            ad.launchStoryboard(Storyboard.Main, animated: false)
                        } else {
                            let ad = UIApplication.shared.delegate as! AppDelegate
                            ad.launchStoryboard(Storyboard.Main, animated: false)
                        }
                    }
                }else {
                    let ad = UIApplication.shared.delegate as! AppDelegate
                    ad.launchStoryboard(Storyboard.Main, animated: false)
                }
            } else {
                let ad = UIApplication.shared.delegate as! AppDelegate
                ad.launchStoryboard(Storyboard.Main, animated: false)
            }
        }
        
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
