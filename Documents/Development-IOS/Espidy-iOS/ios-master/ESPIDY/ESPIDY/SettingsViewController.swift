//
//  SettingsViewController.swift
//  ESPIDY
//
//  Created by FreddyA on 9/5/16.
//  Copyright © 2016 Kretum. All rights reserved.
//

import UIKit
import PKHUD
import SwiftCop
import Kingfisher
import Firebase
import FirebaseInstanceID
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


class SettingsViewController: UIViewController, AlertSetYourselfAwayDelegate {
    
    var titleNavigationBar: String?
    
    let swiftCop = SwiftCop()
    
    var isChangedImage = false

    @IBOutlet weak var imageViewProfile: CustomImageView!
    @IBOutlet weak var textFieldName: UITextField!
    @IBOutlet weak var textFieldEmail: UITextField!
    @IBOutlet weak var textFieldPassword: UITextField!
    @IBOutlet weak var textFieldTelephone: UITextField!
    @IBOutlet weak var labelErrorValidationName: UILabel!
    @IBOutlet weak var labelErrorValidationEmail: UILabel!
    @IBOutlet weak var labelErrorValidationPassword: UILabel!
    @IBOutlet weak var labelErrorValidationPhone: UILabel!
    @IBOutlet weak var constraintHeightViewInvisible: NSLayoutConstraint!
    @IBOutlet weak var viewInvisible: UIView!
    @IBOutlet weak var switchInvisible: UISwitch!
    @IBOutlet weak var labelSwitchInvisible: UILabel!
    @IBOutlet weak var buttonSignOut: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let titleNavigationBar = titleNavigationBar {
            let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 44))
            titleLabel.text = titleNavigationBar
            titleLabel.textColor = UIColor.white
            titleLabel.font = UIFont(name: "Montserrat-Regular", size: 15)
            titleLabel.textAlignment = .center
            navigationItem.titleView = titleLabel
        }
        
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let attributedForSignOut = NSAttributedString(string: "SIGN OUT".localized,
                                                          attributes: [
                                                            NSAttributedStringKey.font: UIFont(name: "Montserrat-Bold", size: 14)!,
                                                            NSAttributedStringKey.foregroundColor: UIColor(red: 56/255,
                                                                green: 57/255, blue: 56/255, alpha: 0.5),
                                                            NSAttributedStringKey.underlineStyle: 1
            ])
        
        buttonSignOut.setAttributedTitle(attributedForSignOut, for: UIControlState())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Methods
    func setupView() {
        
        let tapGestureImageViewProfile = UITapGestureRecognizer(target: self, action: #selector(pickPhoto))
        imageViewProfile.addGestureRecognizer(tapGestureImageViewProfile)
        
        if Global_UserSesion != nil {
            textFieldEmail.text = Global_UserSesion?.email
            textFieldPassword.text = ""
            textFieldTelephone.text = Global_UserSesion?.phone
            textFieldName.text = Global_UserSesion?.name
            
            if let profileImageUrl = Global_UserSesion?.image {
                
                if Global_UserSesion?.avatar_file_size > 0 {
                    showPhotoProfile((UIImage(named: "avatar-men-settings")), profileImageUrl: profileImageUrl)
                } else {
                    showPhotoProfile((UIImage(named: "avatar-men-settings")), profileImageUrl: nil)
                }
                
            } else {
                showPhotoProfile((UIImage(named: "avatar-men-settings")), profileImageUrl: nil)
            }
            
            if Global_UserSesion?.personable_id == "Driver" {
                viewInvisible.isHidden = false
                constraintHeightViewInvisible.constant = 31
                switchInvisible.isOn = Global_UserSesion!.isInvisible
                labelSwitchInvisible.text = switchInvisible.isOn ? "SET YOURSELF AWAY".localized : "SET ME VISIBLE".localized
            } else {
                viewInvisible.isHidden = true
                constraintHeightViewInvisible.constant = 0
                switchInvisible.isOn = Global_UserSesion!.isInvisible
            }
        }
        
        swiftCop.addSuspect(Suspect(view: textFieldName,
            sentence: "The name is required".localized,
            trial: Trial.length(.minimum, 1)))
        
        swiftCop.addSuspect(Suspect(view: textFieldEmail,
            sentence: "Invalid email".localized,
            trial: Trial.email))
        
        swiftCop.addSuspect(Suspect(view: textFieldTelephone,
            sentence: "The phone is required".localized,
            trial: Trial.length(.minimum, 1)))
        
        labelErrorValidationName.text = ""
        labelErrorValidationEmail.text = ""
        labelErrorValidationPassword.text = ""
        labelErrorValidationPhone.text = ""
    }
    
    func showPhotoProfile(_ image: UIImage?, profileImageUrl: String?) {
        if profileImageUrl != nil {
            imageViewProfile.kf.indicatorType = .activity
            imageViewProfile.kf.setImage(with: URL(string: profileImageUrl!)!,
                                         placeholder: image,
                                         options: nil,
                                         progressBlock: nil,
                                         completionHandler: nil)
        } else {
            imageViewProfile.image = image
        }
        imageViewProfile.layer.cornerRadius = 50
        imageViewProfile.layer.masksToBounds = true
        imageViewProfile.contentMode = .scaleAspectFill
    }
    
    func validateFields() -> Bool {
        var validate = true
        
        if swiftCop.anyGuilty() {
            let suspects = swiftCop.allGuilties()
            for suspect in suspects {
                let textField = suspect.view
                switch textField {
                case textFieldName:
                    labelErrorValidationName.text = suspect.verdict()
                case textFieldEmail:
                    labelErrorValidationEmail.text = suspect.verdict()
                case textFieldPassword:
                    labelErrorValidationPassword.text = suspect.verdict()
                case textFieldTelephone:
                    labelErrorValidationPhone.text = suspect.verdict()
                default:
                    break
                }
            }
            validate = false
        }
        
        return validate
    }
    
    func updateUserProfile() {
        if validateFields() {
            HUD.show(.rotatingImage(UIImage(named: "progressHUD")))
            EspidyApiManager.sharedInstance.updateUserWithImage(textFieldName.text!,
                                                                 email: textFieldEmail.text!,
                                                                 phone: textFieldTelephone.text!,
                                                                 password: textFieldPassword.text!,
                                                                 image: imageViewProfile.image!,
                                                                 isChangedImage: isChangedImage,
                                                                 completionHandler: { result in
                guard result.error == nil else {
                    // TODO: display error
                    HUD.flash(.error, delay: 1.0) { _ in
//                        print("AlertMessageError \(result.error)")
                    }
                    return
                }
                if let userUpdated = result.value {
                    Global_UserSesion?.name = userUpdated.name
                    Global_UserSesion?.email = userUpdated.email
                    Global_UserSesion?.phone = userUpdated.phone
//                    Global_UserSesion?.password = userUpdated.password
                    Global_UserSesion?.image = userUpdated.image
                    Global_UserSesion?.avatar_file_size = userUpdated.avatar_file_size
                    if Global_UserSesion?.isInvisible != self.switchInvisible.isOn {
                        Global_UserSesion?.isInvisible = self.switchInvisible.isOn
                        if Global_UserSesion!.isInvisible {
                            //Subscribe
//                            print("Subscribe to FCM")
                            let ad = UIApplication.shared.delegate as! AppDelegate
                            ad.connectToFcm()
                        } else {
                            //Unsubscribe
//                            print("Unsubscribe to FCM")
                            EspidyApiManager.sharedInstance.updateUserTokenFCM("", completionHandler: { (result) in
                                guard result.error == nil else {
                                    // TODO: display error
                                    print("Error in Update tokenFCM \(result.error)")
                                    return
                                }
                                
                                if let userTokenFCM = result.value {
                                    if userTokenFCM.errors == nil || userTokenFCM.errors?.count == 0 {
                                        let instanceId = FIRInstanceID.instanceID()
                                        instanceId.delete(handler: { (error) in
                                            if error != nil {
                                                print("Error FIRInstanceID.deleteIDWithHandler \(error)")
                                            } else {
                                                Global_UserSesion?.token_fcm = ""
                                            }
                                        })
                                    }
                                }
                            })
                        }
                    }
                    HUD.flash(.success, delay: 2.0) { _ in
                        Settings.removeUserAcount()
                        Settings.setUserAcount(Global_UserSesion!)
                    }
                }
            })
        }
    }
    
    func SignOutUser() {
        HUD.show(.rotatingImage(UIImage(named: "progressHUD")))
        //Unsubscribe
        
        EspidyApiManager.sharedInstance.signOut({ (error) in
            Settings.removeUserAcount()
            Global_UserSesion = nil
            Global_creditCards = []
            // Add payment method cash.
            Global_creditCards.append(Credit_card(payment_method_id: 2, imageCard: UIImage(named: "ic-cash-green")!, cardNumber: "CASH"))
                
            let instanceId = FIRInstanceID.instanceID()
            instanceId.delete(handler: { (error) in })
                
            HUD.flash(.success, delay: 1.0) { _ in
                let ad = UIApplication.shared.delegate as! AppDelegate
                ad.launchStoryboard(Storyboard.FlowLoginRegister, animated: true)
            }
        })
    }
    
    // MARK: - Actions
    @IBAction func handleSaveData(_ sender: UIButton) {
        updateUserProfile()
    }
    
    @IBAction func ButtonSignOut(_ sender: AnyObject) {
        SignOutUser()
    }
    
    // MARK: - Alert SetYourselfAway
    lazy var alertSetYourselfAway: AlertSetYourselfAway = {
        let alert = AlertSetYourselfAway()
        alert.delegate = self
        return alert
    }()
    
    func acceptedChange() {
        switchInvisible.isOn = true
        labelSwitchInvisible.text = "SET YOURSELF AWAY".localized
    }
    
    @IBAction func switchInvisible(_ sender: UISwitch) {
//        labelSwitchInvisible.text = sender.on ? "SET YOURSELF AWAY".localized : "SET ME VISIBLE".localized
        if sender.isOn {
            labelSwitchInvisible.text = "SET YOURSELF AWAY".localized
        } else {
            labelSwitchInvisible.text = "SET ME VISIBLE".localized
            alertSetYourselfAway.showView()
        }
    }
    
    @IBAction func validateName(_ sender: UITextField) {
//        labelErrorValidationName.text = swiftCop.isGuilty(sender)?.verdict()
    }
    
    @IBAction func validateEmail(_ sender: UITextField) {
//        labelErrorValidationEmail.text = swiftCop.isGuilty(sender)?.verdict()
    }
    
    @IBAction func validatePassword(_ sender: UITextField) {
//        labelErrorValidationPassword.text = swiftCop.isGuilty(sender)?.verdict()
    }
    
    @IBAction func validatePhone(_ sender: UITextField) {
//        labelErrorValidationPhone.text = swiftCop.isGuilty(sender)?.verdict()
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

extension SettingsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @objc func pickPhoto() {
        // TODO: delete "true ||" only for test alertview.
        if true || UIImagePickerController.isSourceTypeAvailable(.camera) {
            showPhotoMenu()
        } else {
            choosePhotoFromLibrary()
        }
    }
    
    func showPhotoMenu() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "CANCEL".localized.capitalized, style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let takePhotoAction = UIAlertAction(title: "Take Photo".localized, style: .default, handler: { _ in self.takePhotoWithCamera() })
        alertController.addAction(takePhotoAction)
        
        let chooseFromLibraryAction = UIAlertAction(title: "Choose From Library".localized, style: .default, handler: { _ in self.choosePhotoFromLibrary() })
        alertController.addAction(chooseFromLibraryAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func takePhotoWithCamera() {
        let imagePicker = EspidyImagePickerViewController()
        imagePicker.sourceType = .camera
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.view.tintColor = view.tintColor
        present(imagePicker, animated: true, completion: nil)
    }
    
    func choosePhotoFromLibrary() {
        let imagePicker = EspidyImagePickerViewController()
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.view.tintColor = view.tintColor
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerEditedImage] as? UIImage
        
        if let image = image {
            showPhotoProfile(image, profileImageUrl: nil)
            isChangedImage = true
        } else {
            isChangedImage = false
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

extension SettingsViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        switch textField {
        case textFieldName:
            labelErrorValidationName.text = ""
        case textFieldEmail:
            labelErrorValidationEmail.text = ""
        case textFieldPassword:
            labelErrorValidationPassword.text = ""
        case textFieldTelephone:
            labelErrorValidationPhone.text = ""
        default:
            break
        }
        return true
    }
}














