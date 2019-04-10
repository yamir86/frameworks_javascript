//
//  RegisterCardViewController.swift
//  ESPIDY
//
//  Created by FreddyA on 9/7/16.
//  Copyright © 2016 Kretum. All rights reserved.
//

import UIKit
import PKHUD
import Caishen

protocol RegisterCardViewControllerDelegate: class {
    func successRegister()
}

class RegisterCardViewController: UIViewController, NumberInputTextFieldDelegate, CardInfoTextFieldDelegate, CardIOPaymentViewControllerDelegate, ValidDatePickerViewDelegate, UITextFieldDelegate {

    weak var delegate: RegisterCardViewControllerDelegate?
    
    lazy var validDatePickerView: ValidDatePickerView = {
        let validDate = ValidDatePickerView()
        validDate.delegate = self
        return validDate
    }()
    
    var month: Int?
    var year: Int?
    var titleButton: String?
    var info0: String?
    var info1: String?
    var titleNavigationBar: String?
    
    var card: Card? {
        let number = textFieldCardNumber.cardNumber
        let cvc = CVC(rawValue: textFieldCVCNumber.text ?? "")
        var monthString = ""
        var yearString = ""
        
        if let month = month {
            monthString = String(format: "%02d", month)
        }
        
        if let year = year {
            yearString = String(format: "%d", year)
        }
        
        let expiry = Expiry(month: monthString ?? "", year: yearString ?? "") ?? Expiry.invalid
        
        let cardType = textFieldCardNumber.cardTypeRegister.cardType(for: textFieldCardNumber.cardNumber)

        if cardType.validate(cvc: cvc).union(cardType.validate(expiry: expiry)).union(cardType.validate(number: number)) == .Valid {
            return Card(number: number, cvc: cvc, expiry: expiry)
        } else {
            return nil
        }
    }
    
    @IBOutlet weak var textFieldName: UITextField!
    @IBOutlet weak var textFieldCardNumber: NumberInputTextField!
    @IBOutlet weak var textFieldCVCNumber: CVCInputTextField!
    @IBOutlet weak var labelInfo0: UILabel!
    @IBOutlet weak var labelInfo1: UILabel!
    @IBOutlet weak var buttonValidDate: DesignableUIButton!
    @IBOutlet weak var buttonActionViewController: UIButton!
    @IBOutlet weak var buttonSkip: UIButton!
    @IBOutlet weak var constraintHeightLabelInfo0: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textFieldCardNumber.numberInputTextFieldDelegate = self
        textFieldCVCNumber.cardInfoTextFieldDelegate = self
        
        labelInfo0.text = info0
        labelInfo1.text = info1
        buttonActionViewController.setTitle(titleButton, for: UIControlState())
        
        if info0 == "" {
            labelInfo0.isHidden = true
            buttonSkip.isHidden = true
            constraintHeightLabelInfo0.constant = 0
        } else {
            labelInfo0.isHidden = false
            buttonSkip.isHidden = false
            constraintHeightLabelInfo0.constant = 44
        }
        
        if let titleNavigationBar = titleNavigationBar {
            let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 44))
            titleLabel.text = titleNavigationBar
            titleLabel.textColor = UIColor.white
            titleLabel.font = UIFont(name: "Montserrat-Regular", size: 15)
            titleLabel.textAlignment = .center
            navigationItem.titleView = titleLabel
        }
        
        CardIOUtilities.preload()
        handleUpdateValidDate((Calendar(identifier: Calendar.Identifier.gregorian) as NSCalendar).component(.month, from: Date()),
                              year: (Calendar(identifier: Calendar.Identifier.gregorian) as NSCalendar).component(.year, from: Date()),
                              changeTitleColor: false)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let attributedForbuttonSkip = NSAttributedString(string: "SKIP THIS STEP".localized,
                                                           attributes: [
                                                            NSAttributedStringKey.font: UIFont(name: "Montserrat-Regular", size: 12)!,
                                                            NSAttributedStringKey.foregroundColor: UIColor(red: 56/255,
                                                                green: 57/255, blue: 56/255, alpha: 0.5),
                                                            NSAttributedStringKey.underlineStyle: 1
            ])
        
        buttonSkip.setAttributedTitle(attributedForbuttonSkip, for: UIControlState())
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    @IBAction func handleValidDate(_ sender: DesignableUIButton) {
        if let month = month {
            validDatePickerView.month = month
        }
        
        if let year = year {
            validDatePickerView.year = year
        }
        view.endEditing(true)
        validDatePickerView.showPickerView()
    }
    
    @IBAction func handleCaptureCard(_ sender: UIButton) {
        let cardIOVC = CardIOPaymentViewController(paymentDelegate: self)
        cardIOVC?.navigationBarStyleForCardIO = .black
        cardIOVC?.navigationBarTintColor = UIColor.ESPIDYColorRedL()
        cardIOVC?.modalPresentationStyle = .fullScreen
        present(cardIOVC!, animated: true, completion: nil)
    }
    
    @IBAction func handleRegisterCreditCard(_ sender: UIButton) {
        if textFieldName.text!.isEmpty {
            // TODO: //campo requerido
//            print("Name requerid info")
        } else if card == nil {
            // TODO: //verifique los datos de la tarjeta de credito
//            print("Credit Card Not Valid")
        } else {
            registerCreditCard(textFieldName.text!,
                               card_number: String(describing: card!.bankCardNumber),
                               cvc_number: card!.cardVerificationCode.rawValue,
                               card_expiration_month: String(format: "%02d", card!.expiryDate.month),
                               card_expiration_year: String(card!.expiryDate.year))
        }
    }
    
    // MARK: - Methods
    func userDidCancel(_ paymentViewController: CardIOPaymentViewController!) {
        paymentViewController?.dismiss(animated: true, completion: nil)
    }
    
    func userDidProvide(_ cardInfo: CardIOCreditCardInfo!, in paymentViewController: CardIOPaymentViewController!) {
        if let info = cardInfo {
//            let str = NSString(format: "Received card info.\n Number: %@\n expiry: %02lu/%lu\n cvv: %@.", info.redactedCardNumber, info.expiryMonth, info.expiryYear, info.cvv)
            textFieldName.text = info.cardholderName
            textFieldCardNumber.text = info.cardNumber
            textFieldCVCNumber.text = info.cvv
            handleUpdateValidDate(Int(info.expiryMonth), year: Int(info.expiryYear), changeTitleColor: true)
        }
        paymentViewController?.dismiss(animated: true, completion: nil)
    }
    
    func handleUpdateValidDate(_ month: Int, year: Int, changeTitleColor: Bool) {
        self.month = month
        self.year = year
        
        let validDate = String(format: "%02d/%d", month, year)
        
        buttonValidDate.setTitle(validDate, for: UIControlState())
        if changeTitleColor {
            buttonValidDate.setTitleColor(UIColor.black, for: UIControlState())
        }
        
    }
    
    func registerCreditCard(_ fullname: String,
                            card_number: String,
                            cvc_number: String,
                            card_expiration_month: String,
                            card_expiration_year: String) {
        
        HUD.show(.rotatingImage(UIImage(named: "progressHUD")))
        EspidyApiManager.sharedInstance.registerCreditCard(fullname,
                                                               card_number: card_number,
                                                               cvc_number: cvc_number,
                                                               card_expiration_month: card_expiration_month,
                                                               card_expiration_year: card_expiration_year) { result in
            guard result.error == nil else {
                // TODO: display error
                HUD.flash(.error, delay: 1.0) { _ in
//                    print("AlertMessageError \(result.error)")
                }
                return
            }
            if let newCreditCard = result.value {
                if newCreditCard.status == nil {
                    HUD.flash(.success, delay: 1.0) { _ in
                        Global_creditCards = [Credit_card]()
                        Global_creditCards.append(Credit_card(payment_method_id: 2,
                                                              imageCard: UIImage(named: "ic-cash-green")!,
                                                              cardNumber: "CASH"))
                        
                        Global_creditCards.append(newCreditCard)
                        
                        if self.delegate != nil {
                            self.delegate?.successRegister()
                        } else {
                            self.performSegue(withIdentifier: "SegueMain", sender: nil)
                        }
                    }
                } else {
                    HUD.flash(.error, delay: 1.0) { _ in
//                        print("full message error \(newCreditCard.status!)")
                    }
                }
            }
        }
    }
    
    func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
    
    // MARK: - TextFieldDelegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        let newLength = text.characters.count + string.characters.count - range.length
         if textField == textFieldCardNumber {
            return newLength <= 16
        } else if textField == textFieldCVCNumber {
            return newLength <= 4
        } else {
            return newLength <= 25
        }
    }
    
    // MARK: - NumberInputTextFieldDelegate
    func numberInputTextFieldDidComplete(_ numberInputTextField: NumberInputTextField) {
        textFieldCVCNumber.cardType = numberInputTextField.cardTypeRegister.cardType(for: numberInputTextField.cardNumber)
//        print("Card number: \(numberInputTextField.cardNumber)")
//        print(card)
//        monthInputTextField.becomeFirstResponder()
    }
    
    func numberInputTextFieldDidChangeText(_ numberInputTextField: NumberInputTextField) {
        
    }
    
    // MARK: - CardInfoTextFieldDelegate
    func textField(_ textField: UITextField, didEnterValidInfo: String) {
//        switch textField {
//        case is CVCInputTextField:
//            print("CVC: \(didEnterValidInfo)")
//        default:
//            break
//        }
//        print(card)
    }
    
    func textField(_ textField: UITextField, didEnterPartiallyValidInfo: String) {
        // The user entered information that is not valid but might become valid on further input.
        // Example: Entering "1" for the CVC is partially valid, while entering "a" is not.
    }
    
    func textField(_ textField: UITextField, didEnterOverflowInfo overFlowDigits: String) {
        // This function is used in a CardTextField to carry digits to the next text field.
        // Example: A user entered "02/20" as expiry and now tries to append "5" to the month.
        //          On a card text field, the year will be replaced with "5" - the overflow digit.
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
