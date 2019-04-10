//
//  credit_cards.swift
//  ESPIDY
//
//  Created by FreddyA on 10/2/16.
//  Copyright © 2016 Kretum. All rights reserved.
//

import Foundation
import SwiftyJSON
import Caishen

class Credit_card: ResponseJSONObjectSerializable {
    var id: Int?
    var client_id: Int?
    var imageCard: UIImage?
    var fullname: String?
    var card_number: String?
    var cvc_number: Int?
    var card_expiration_month: Int?
    var card_expiration_year: Int?
    var payment_method_id: Int?
    var status: String?
    var full_messages: [String]?
    var errors: [String]?
    
    let cardTypeRegister: CardTypeRegister = CardTypeRegister.sharedCardTypeRegister
    let cardNumberSeparator: String = " "
    var cardNumberFormatter: CardNumberFormatter {
        return CardNumberFormatter(cardTypeRegister: cardTypeRegister, separator: cardNumberSeparator)
    }
    
    var card: Card? {
        let fieldCardNumber = NumberInputTextField()
        fieldCardNumber.text = card_number
        let number = fieldCardNumber.cardNumber
        let cvc = CVC(rawValue: String(describing: cvc_number) ?? "")
        var monthString = ""
        var yearString = ""
        
        if let month = card_expiration_month {
            monthString = String(format: "%02d", month)
        }
        
        if let year = card_expiration_year {
            yearString = String(format: "%d", year)
        }
        
        let expiry = Expiry(month: monthString ?? "", year: yearString ?? "") ?? Expiry.invalid
        let cardType = fieldCardNumber.cardTypeRegister.cardType(for: fieldCardNumber.cardNumber)
        
        if cardType.validate(cvc: cvc).union(cardType.validate(expiry: expiry)).union(cardType.validate(number: number)) == .Valid {
            return Card(number: number, cvc: cvc, expiry: expiry)
        } else {
            return nil
        }
    }
    
    var cardType: CardType? {
        let fieldCardNumber = NumberInputTextField()
        fieldCardNumber.text = card_number
        return fieldCardNumber.cardTypeRegister.cardType(for: fieldCardNumber.cardNumber)
    }
    
    required init?(json: JSON) {
        self.status = json["status"].string
        self.errors = json["errors"].arrayValue.map {$0.string!}
        
        self.id = json["id"].int
        self.client_id = json["client_id"].int
        self.fullname = json["fullname"].string
        self.card_number = json["card_number"].string
        self.cvc_number = json["cvc_number"].int
        self.card_expiration_month = json["card_expiration_month"].int
        self.card_expiration_year = json["card_expiration_year"].int
        self.payment_method_id = 1
        self.imageCreditCard()
        self.maskNumber()
    }
    
    required init() {
    }
    
    init(fullname: String,
         card_number: String,
         cvc_number: Int,
         card_expiration_month: Int,
         card_expiration_year: Int) {
        
        self.fullname = fullname
        self.card_number = card_number
        self.cvc_number = cvc_number
        self.card_expiration_month = card_expiration_month
        self.card_expiration_year = card_expiration_year
    }
    
    init(payment_method_id: Int, imageCard: UIImage, cardNumber: String) {
        self.payment_method_id = payment_method_id
        self.imageCard = imageCard
        self.card_number = cardNumber
    }
    
    func imageCreditCard() {
        switch self.cardType!.name {
        case "MasterCard":
            self.imageCard = UIImage(named: "tdc-mc-payments")
        case "Visa":
            self.imageCard = UIImage(named: "tdc-visa-payments")
        case "Amex":
            self.imageCard = UIImage(named: "tdc-american-payments")
        case "Discover":
            self.imageCard = UIImage(named: "tdc-discover-payments")
        default:
            self.imageCard = UIImage(named: "tdc-default-payments")
        }
    }
    
    func maskNumber() {
        if let card_number = self.card_number {
            let cardNumber = cardNumberFormatter.format(cardNumber: card_number)
            let lastCardNumber = cardNumber.substring(from: cardNumber.index(cardNumber.endIndex, offsetBy: (-4)))
            let firstCardNumber = cardNumber.substring(to: cardNumber.index(cardNumber.startIndex, offsetBy: (cardNumber.characters.count - 4)))
            var maskCardNumber = firstCardNumber.replacingOccurrences(of: "0", with: "•")
            
            for i in 1...9 {
                maskCardNumber = maskCardNumber.replacingOccurrences(of: String(i), with: "•")
            }
            self.card_number = "\(maskCardNumber)\(lastCardNumber)"
        }
    }
}
