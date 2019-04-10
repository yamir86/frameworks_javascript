//
//  PaymentPickerView.swift
//  ESPIDY
//
//  Created by FreddyA on 3/18/17.
//  Copyright © 2017 Kretum. All rights reserved.
//
import UIKit

class PaymentPickerView: UIPickerView, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var payment: Int = 0 {
        didSet {
            selectRow(payment, inComponent: 0, animated: false)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonSetup()
    }
    
    func commonSetup() {
        self.delegate = self
        self.dataSource = self
        selectRow(payment, inComponent: 0, animated: false)
    }
    
    // MARK: - UIPicker Delegate / Data Source
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
//        let paymentView = PaymentView(frame: CGRectMake(0, 0, 320, 44))
//        paymentView.labelPaymentSub.text = String(format: "%02d/%d",
//                                                  Global_creditCards[row].card_expiration_month!,
//                                                  Global_creditCards[row].card_expiration_year!)
//        return paymentView
        
        let paymentView = UIView()
        let stackPaymentH = UIStackView()
        let imagePayment = UIImageView()
        let labelPaymentTitle = UILabel()
        
        labelPaymentTitle.font = UIFont(name: "Montserrat-Regular", size: 16)
        labelPaymentTitle.textAlignment = .right
        
        stackPaymentH.translatesAutoresizingMaskIntoConstraints = false
        imagePayment.translatesAutoresizingMaskIntoConstraints = false
        labelPaymentTitle.translatesAutoresizingMaskIntoConstraints = false
        
        stackPaymentH.axis = .horizontal
        stackPaymentH.alignment = .fill
        stackPaymentH.distribution = .fill
        
        paymentView.addSubview(stackPaymentH)
        stackPaymentH.addArrangedSubview(imagePayment)
        stackPaymentH.addArrangedSubview(labelPaymentTitle)
        
        stackPaymentH.rightAnchor.constraint(equalTo: paymentView.rightAnchor, constant: 38)
        stackPaymentH.leftAnchor.constraint(equalTo: paymentView.leftAnchor, constant: 38).isActive = true
        
        stackPaymentH.centerYAnchor.constraint(equalTo: paymentView.centerYAnchor).isActive = true
        
        imagePayment.heightAnchor.constraint(equalToConstant: 36.0).isActive = true
        imagePayment.widthAnchor.constraint(equalToConstant: 54.0).isActive = true
        
        stackPaymentH.spacing = 30
        
        imagePayment.image = Global_creditCards[row].imageCard
        labelPaymentTitle.text = Global_creditCards[row].card_number
        
        return paymentView
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 60
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Global_creditCards.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        payment = row
    }
}
