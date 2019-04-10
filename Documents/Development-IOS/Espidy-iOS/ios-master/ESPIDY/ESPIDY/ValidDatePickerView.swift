//
//  ValidDatePickerView.swift
//  ESPIDY
//
//  Created by FreddyA on 9/11/16.
//  Copyright © 2016 Kretum. All rights reserved.
//

import UIKit

protocol ValidDatePickerViewDelegate: class {
    func handleUpdateValidDate(_ month: Int, year: Int, changeTitleColor: Bool)
}

class ValidDatePickerView: NSObject {
    
    var delegate: ValidDatePickerViewDelegate?
    var month: Int?
    var year: Int?
    
    lazy var blackView: UIView = {
        var view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleDismiss)))
        return view
    }()
    
    let contentView: UIView = {
        var view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }()
    
    let toolBarPickerView: UIToolbar = {
        var toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.black
        toolBar.translatesAutoresizingMaskIntoConstraints = false
        
        return toolBar
    }()
    
    lazy var pickerViewMonthYear: MonthYearPickerView = {
        var pickerView = MonthYearPickerView()
        pickerView.backgroundColor = UIColor.white
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        return pickerView
    }()
    
    func setupViews() {
        
        contentView.addSubview(toolBarPickerView)
        contentView.addSubview(pickerViewMonthYear)
        
        toolBarPickerView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        toolBarPickerView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        toolBarPickerView.widthAnchor.constraint(equalTo: contentView.widthAnchor).isActive = true
        
        let doneButton = UIBarButtonItem(title: "DONE".localized, style: .plain, target: self, action: #selector(handleDoneTab))
        doneButton.setTitleTextAttributes([
            NSAttributedStringKey.font: UIFont(name: "Montserrat-Regular", size: 17)!,
            NSAttributedStringKey.foregroundColor: UIColor.ESPIDYColorDark()], for: UIControlState())
        let spaceButton0 = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        spaceButton0.width = 16
        let spaceButton1 = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let spaceButton2 = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        spaceButton2.width = 16
        
        let cancelButton = UIBarButtonItem(title: "CANCEL".localized, style: .plain, target: self, action: #selector(handleDismiss))
        cancelButton.setTitleTextAttributes([
            NSAttributedStringKey.font: UIFont(name: "Montserrat-Regular", size: 17)!,
            NSAttributedStringKey.foregroundColor: UIColor.ESPIDYColorDark()], for: UIControlState())
        
        toolBarPickerView.setItems([spaceButton0, cancelButton, spaceButton1, doneButton, spaceButton2], animated: false)
        toolBarPickerView.isUserInteractionEnabled = true
        
        pickerViewMonthYear.topAnchor.constraint(equalTo: toolBarPickerView.bottomAnchor).isActive = true
        pickerViewMonthYear.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        pickerViewMonthYear.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        pickerViewMonthYear.widthAnchor.constraint(equalTo: contentView.widthAnchor).isActive = true

    }
    
    func showPickerView() {
        //showPickerView 
        if let window = UIApplication.shared.keyWindow {
            
            if let month = month {
                pickerViewMonthYear.month = month
            }
            
            if let year = year {
                pickerViewMonthYear.year = year
            }
            
            window.addSubview(blackView)
            window.addSubview(contentView)
            
            let height: CGFloat = CGFloat(256)
            let y = window.frame.height - height
            contentView.frame = CGRect(x: 0, y: window.frame.height, width: window.frame.width, height: height)
            
            blackView.frame = window.frame
            blackView.alpha = 0
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                self.blackView.alpha = 1
                
                self.contentView.frame = CGRect(x: 0, y: y, width: self.contentView.frame.width, height: self.contentView.frame.height)
                
                }, completion: nil)
        }
    }
    
    @objc func handleDismiss() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            
            self.blackView.alpha = 0
            
            if let window = UIApplication.shared.keyWindow {
                self.contentView.frame = CGRect(x: 0, y: window.frame.height, width: self.contentView.frame.width, height: self.contentView.frame.height)
            }
            
        }) { (completed: Bool) in
            
        }
    }
    @objc
    func handleDoneTab() {
        self.delegate?.handleUpdateValidDate(pickerViewMonthYear.month, year: pickerViewMonthYear.year, changeTitleColor: true)
        handleDismiss()
    }
    
    override init() {
        super.init()
        
        setupViews()
        
    }
    
}
