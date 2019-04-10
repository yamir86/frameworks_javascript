//
//  LoginViewController.swift
//  ESPIDY
//
//  Created by FreddyA on 9/6/16.
//  Copyright © 2016 Kretum. All rights reserved.
//

import UIKit
import PKHUD
import SwiftCop
import Firebase
import FBSDKLoginKit
import FirebaseInstanceID

class LoginViewController: UIViewController {
    
    var dict: NSDictionary!
    
    let swiftCop = SwiftCop()
    
    @IBOutlet weak var textFieldEmail: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    @IBOutlet weak var viewFacebookLogin: DesignableUIView!
    @IBOutlet weak var buttonNeedAccount: UIButton!
    @IBOutlet weak var buttonLostPassword: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGestureViewFacebookLogin = UITapGestureRecognizer(target: self, action: #selector(handleLoginFacebook))
        viewFacebookLogin.addGestureRecognizer(tapGestureViewFacebookLogin)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let attributedForNeedAccount = NSAttributedString(string: "NEED AN ACCOUNT?".localized,
                                                          attributes: [
                                                            NSAttributedStringKey.font: UIFont(name: "Montserrat-Bold", size: 14)!,
                                                            NSAttributedStringKey.foregroundColor: UIColor(red: 56/255,
                                                                green: 57/255, blue: 56/255, alpha: 0.5),
                                                            NSAttributedStringKey.underlineStyle: 1
                                                          ])
        
        let attributedForLostPassword = NSAttributedString(string: "LOST YOUR PASSWORD?".localized,
                                                           attributes: [
                                                            NSAttributedStringKey.font: UIFont(name: "Montserrat-Regular", size: 12)!,
                                                            NSAttributedStringKey.foregroundColor: UIColor(red: 56/255,
                                                                green: 57/255, blue: 56/255, alpha: 0.5),
                                                            NSAttributedStringKey.underlineStyle: 1
                                                           ])
        
        buttonNeedAccount.setAttributedTitle(attributedForNeedAccount, for: UIControlState())
        buttonLostPassword.setAttributedTitle(attributedForLostPassword, for: UIControlState())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    @objc func handleLoginFacebook() {
        
        UIView.animate(withDuration: 0.2, delay: 0, options: .transitionCrossDissolve, animations: {
            
            self.viewFacebookLogin.alpha = 0.2
            
            }) { (_) in
                self.viewFacebookLogin.alpha = 1
                let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
                fbLoginManager.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
                    if error != nil {
                        print("fbLoginManager Process error")
                    } else if (result?.isCancelled)! {
                        print("fbLoginManager Process Cancel")
                    } else {
                        print("EXITOSO?")
                        let fbloginresult: FBSDKLoginManagerLoginResult = result!
                        if(fbloginresult.grantedPermissions.contains("email")) {
                            self.getFBUserData()
                            fbLoginManager.logOut()
                            
//                            let ad = UIApplication.sharedApplication().delegate as! AppDelegate
//                            ad.launchStoryboard(Storyboard.Main, animated: false)
                        }
                    }
                }
        }
        
    }
    
    // MARK: - Methods
    func getFBUserData(){
        if((FBSDKAccessToken.current()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    self.dict = result as! NSDictionary
                    
                    let id = self.dict.object(forKey: "id") as! String
                    let name = self.dict.object(forKey: "name") as! String
                    let image = ((self.dict.object(forKey: "picture") as AnyObject).object(forKey: "data") as AnyObject).object(forKey: "url") as! String
                    let email = self.dict.object(forKey: "email") as! String
                    
//                    Global_UserSesion = User(name: name, image: image, email: email)
                    
                    HUD.show(.rotatingImage(UIImage(named: "progressHUD")))
                    EspidyApiManager.sharedInstance.loginFacebook(email, password: id, name: name, phone: "") { result, headerFields in
                        guard result.error == nil else {
                            // TODO: display error
                            HUD.flash(.error, delay: 1.0) { _ in
//                                print("AlertMessageError \(result.error)")
                            }
                            return
                        }
                        if let signInUser = result.value {
                            if signInUser.errors == nil || signInUser.errors?.count == 0 {
                                Global_UserSesion = signInUser
                                Global_UserSesion?.accessToken = headerFields["access-token"]
                                Global_UserSesion?.client = headerFields["client"]
                                Global_UserSesion?.uid = headerFields["uid"]
//                                print("\(image)")
                                Global_UserSesion?.image = image
                                
                                //Subscribe
//                                print("Subscribe to FCM")
                                let ad = UIApplication.shared.delegate as! AppDelegate
                                ad.connectToFcm()
                                
                                EspidyApiManager.sharedInstance.shipmentsActive { (result) in
                                    guard result.error == nil else {
                                        if Global_UserSesion?.personable_id != "Driver" {
                                            EspidyApiManager.sharedInstance.creditCards { (result) in
                                                guard result.error == nil else {
                                                    // TODO: display error
                                                    return
                                                }
                                                if let fetchedCreditCards = result.value {
                                                    Global_creditCards.append(contentsOf: fetchedCreditCards)
                                                }
                                            }
                                        }
                                        
                                        HUD.flash(.success, delay: 2.0) { _ in
                                            let ad = UIApplication.shared.delegate as! AppDelegate
                                            ad.launchStoryboard(Storyboard.Main, animated: false)
                                        }
                                        return
                                    }
                                    if let shipmentsActive = result.value {
                                        if shipmentsActive.count > 0 {
                                            let shipmentActive = shipmentsActive[0]
                                            if let statusShipment = shipmentActive.status {
                                                Global_UserSesion?.shipmentActive = shipmentActive
                                                Global_UserSesion?.statusShipment = statusShipment
                                                Global_UserSesion?.isShipmentActive = true
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
                                                    return
                                                }
                                                if let fetchedCreditCards = result.value {
                                                    Global_creditCards.append(contentsOf: fetchedCreditCards)
                                                }
                                            }
                                        }
                                        
                                        HUD.flash(.success, delay: 2.0) { _ in
                                            let ad = UIApplication.shared.delegate as! AppDelegate
                                            ad.launchStoryboard(Storyboard.Main, animated: false)
                                        }
                                    }
                                }
                                
                                Settings.setUserAcount(Global_UserSesion!)
                            } else {
                                HUD.flash(.error, delay: 0.5) { _ in
                                    if let messageErrors = signInUser.errors {
                                        let alertController = UIAlertController(title: "Error", message: messageErrors[0], preferredStyle: .alert)
                                        
                                        let okAction = UIAlertAction(title: "OK", style: .default) { (result : UIAlertAction) -> Void in
//                                            print("errors \(signInUser.errors!)")
                                        }
                                        
                                        alertController.addAction(okAction)
                                        self.present(alertController, animated: true, completion: nil)
                                    }
                                }
                            }
                        }
                    }
                }
            })
        }
    }
    
    func signInUser(_ email: String, password: String) {
        HUD.show(.rotatingImage(UIImage(named: "progressHUD")))
        EspidyApiManager.sharedInstance.signIn(email, password: password) { result, headerFields in
            guard result.error == nil else {
                // TODO: display error
                HUD.flash(.error, delay: 1.0) { _ in
                    if let err = result.error {
                         print("AlertMessageError \(err)")
                    }
                   
                }
                return
            }
            if let signInUser = result.value {
                if signInUser.errors == nil || signInUser.errors?.count == 0 {
                    Global_UserSesion = signInUser
                    Global_UserSesion?.accessToken = headerFields["access-token"]
                    Global_UserSesion?.client = headerFields["client"]
                    Global_UserSesion?.uid = headerFields["uid"]
                    Global_UserSesion?.password = password
                    
                    if let accessToken = Global_UserSesion?.accessToken, let client = Global_UserSesion?.client, let uid = Global_UserSesion?.uid{
                        print("---> accessToken \(accessToken)")
                        print("---> client \(client)")
                        print("---> uid \(uid)")
                    }

                    
                    //Subscribe
//                    print("Subscribe to FCM")
                    let ad = UIApplication.shared.delegate as! AppDelegate
                    ad.connectToFcm()
                    
                    EspidyApiManager.sharedInstance.shipmentsActive { (result) in
                        guard result.error == nil else {
                            if Global_UserSesion?.personable_id != "Driver" {
                                EspidyApiManager.sharedInstance.creditCards { (result) in
                                    guard result.error == nil else {
                                        // TODO: display error
                                        return
                                    }
                                    if let fetchedCreditCards = result.value {
                                        Global_creditCards.append(contentsOf: fetchedCreditCards)
                                    }
                                }
                            }
                            
                            HUD.flash(.success, delay: 2.0) { _ in
                                let ad = UIApplication.shared.delegate as! AppDelegate
                                ad.launchStoryboard(Storyboard.Main, animated: false)
                            }
                            return
                        }
                        if let shipmentsActive = result.value {
                            if shipmentsActive.count > 0 {
                                let shipmentActive = shipmentsActive[0]
                                if let statusShipment = shipmentActive.status {
                                    Global_UserSesion?.shipmentActive = shipmentActive
                                    Global_UserSesion?.statusShipment = statusShipment
                                    Global_UserSesion?.isShipmentActive = true
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
                                        return
                                    }
                                    if let fetchedCreditCards = result.value {
                                        Global_creditCards.append(contentsOf: fetchedCreditCards)
                                    }
                                }
                            }
                            
                            HUD.flash(.success, delay: 2.0) { _ in
                                let ad = UIApplication.shared.delegate as! AppDelegate
                                ad.launchStoryboard(Storyboard.Main, animated: false)
                            }
                        }
                    }
                    
                    Settings.setUserAcount(Global_UserSesion!)
                } else {
                    HUD.flash(.error, delay: 0.5) { _ in
                        if let messageErrors = signInUser.errors {
                            let alertController = UIAlertController(title: "Error", message: messageErrors[0], preferredStyle: .alert)
                            
                            let okAction = UIAlertAction(title: "OK", style: .default) { (result : UIAlertAction) -> Void in
//                                print("errors \(signInUser.errors!)")
                            }
                            
                            alertController.addAction(okAction)
                            self.present(alertController, animated: true, completion: nil)
                        }
                    }
                }
            }
        }
    }
    
    func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
    
    @IBAction func handleLogin(_ sender: AnyObject) {
        //no es recomendable usar el ! ya se q esta obligando a q te de un valor y si este valor es nil la app  explotara! ACOMODAR AQUI
        signInUser(textFieldEmail.text!, password: textFieldPassword.text!)
    }
    
    @IBAction func buttonLostPassword(_ sender: UIButton) {
        let alertController = UIAlertController(title: "REMEMBER YOUR PASSWORD".localized, message: "We can help you reset your password and security information, please enter your email".localized, preferredStyle: .alert)
        
        let actionCancel = UIAlertAction(title: "CANCEL".localized, style: .cancel) { (action:UIAlertAction) in
            //This is called when the user presses the cancel button.
        }
        
        let actionOk = UIAlertAction(title: "OK", style: .default) { (action:UIAlertAction) in
            //This is called when the user presses the login button.
            let textEmail = alertController.textFields![0] as UITextField
            
            EspidyApiManager.sharedInstance.rememberPassword(textEmail.text!, completionHandler: { (error) in
                if error == nil {
                    let alertController = UIAlertController(title: "REMEMBER YOUR PASSWORD".localized, message: "We will send you an email for the instructions that you must follow to recover your password.".localized, preferredStyle: .alert)
                    
                    let okAction = UIAlertAction(title: "OK", style: .default) { (result : UIAlertAction) -> Void in
                        
                    }
                    
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                } else {
//                    print("Error!!!")
                }
            })
            
//            print("The user entered: \(textEmail.text!)")
        }
        
        alertController.addTextField { (textField) -> Void in
            //Configure the attributes of the first text box.
            textField.placeholder = "Email"
            
//            self.swiftCop.addSuspect(Suspect(view: textField,
//                                             sentence: "Invalid email".localized,
//                                             trial: Trial.Email))
        }
        
        //Add the buttons
        alertController.addAction(actionCancel)
        alertController.addAction(actionOk)
        
        //Present the alert controller
        self.present(alertController, animated: true, completion:nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
