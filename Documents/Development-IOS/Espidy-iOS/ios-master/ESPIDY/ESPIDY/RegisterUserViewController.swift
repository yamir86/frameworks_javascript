//
//  RegisterUserViewController.swift
//  ESPIDY
//
//  Created by FreddyA on 9/7/16.
//  Copyright © 2016 Kretum. All rights reserved.
//

import UIKit
import PKHUD
import Firebase
import FirebaseInstanceID

class RegisterUserViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var textFieldName: UITextField!
    @IBOutlet weak var textFieldEmail: UITextField!
    @IBOutlet weak var textFieldPhone: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    @IBOutlet weak var imageViewEyeIcon: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let tapGestureEyeIcon = UITapGestureRecognizer(target: self, action: #selector(handleTapEyeIcon))
        imageViewEyeIcon.addGestureRecognizer(tapGestureEyeIcon)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // MARK: - Methods
    func registerUser(_ email: String, password: String, name: String, phone: String) {
        HUD.show(.rotatingImage(UIImage(named: "progressHUD")))
        
        guard isValidForm() else {
            HUD.flash(.error, delay: 1.0) { _ in
            }
            return
        }
        
        EspidyApiManager.sharedInstance.registerUser(email, password: password, name: name, phone: phone) { result, headerFields in
            guard result.error == nil else {
                // TODO: display error
                HUD.flash(.error, delay: 1.0) { _ in
//                    print("AlertMessageError \(result.error)")
                }
                return
            }
            if let newUser = result.value {
                if newUser.status == "success" {
                    Global_UserSesion = newUser
                    Global_UserSesion?.accessToken = headerFields["access-token"]
                    Global_UserSesion?.client = headerFields["client"]
                    Global_UserSesion?.uid = headerFields["uid"]
                    Global_UserSesion?.password = password
                    
                    //Subscribe
//                    print("Subscribe to FCM")
                    let ad = UIApplication.shared.delegate as! AppDelegate
                    ad.connectToFcm()
                    
                    HUD.flash(.success, delay: 2.0) { _ in
                        Settings.setUserAcount(Global_UserSesion!)
                        
                        let registerCardViewController = self.storyboard!.instantiateViewController(withIdentifier: "RegisterCardViewController") as! RegisterCardViewController
                        registerCardViewController.info0 = "WE CHARGE ONLY BY CREDIT CARD AFTER YOUR SHIPMENT HAS ARRIVED QUIET YOUR DATA IS SAFE!".localized
                        registerCardViewController.info1 = "OR COMPLETE THE FIELDS PRESENTED BELOW".localized
                        registerCardViewController.titleButton = "CREATE ACCOUNT!".localized
                        self.present(registerCardViewController, animated: true, completion: nil)
                    }
                    
                } else {
                    HUD.flash(.error, delay: 1.0) { _ in
                    }
                }
            }
        }
    }
    
    func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
    
    @objc func handleTapEyeIcon() {
        imageViewEyeIcon.isHighlighted = !imageViewEyeIcon.isHighlighted
        textFieldPassword.isSecureTextEntry = !textFieldPassword.isSecureTextEntry
    }
    
    func isValidForm() -> Bool {
        return !(textFieldEmail.text ?? "").isEmpty &&
            !(textFieldPassword.text ?? "").isEmpty &&
            !(textFieldName.text ?? "").isEmpty &&
            !(textFieldPhone.text ?? "").isEmpty
    }
    
    // MARK: - Actions
    @IBAction func handleRegister(_ sender: UIButton) {
        registerUser(textFieldEmail.text!, password: textFieldPassword.text!, name: textFieldName.text!, phone: textFieldPhone.text!)
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    }
}
