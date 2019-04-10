//
//  PlacesCell.swift
//  ESPIDY
//
//  Created by FreddyA on 9/26/16.
//  Copyright © 2016 Kretum. All rights reserved.
//

import UIKit

class PlacesCell: BaseCell {
    
    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.4, delay: 0.1, options: .curveEaseOut, animations: {
                self.labelPlace.textColor = self.isHighlighted ? UIColor.ESPIDYColorLight() : UIColor.ESPIDYColorDark()
            }) { (true) in
//            delegate?.didTapCell(labelPlace.text)
            }
        }
    }
    
    var place: GMSAutocompletePrediction? {
        didSet {
            let regularFont = UIFont(name: "Montserrat-Regular", size: 12)
            let boldFont = UIFont(name: "Montserrat-Bold", size: 12)
            
            let bolded = place!.attributedFullText.mutableCopy() as! NSMutableAttributedString
            bolded.enumerateAttribute(NSAttributedStringKey(rawValue: kGMSAutocompleteMatchAttribute),
                                      in: NSMakeRange(0, bolded.length),
                                      options: .longestEffectiveRangeNotRequired) { (value, range: NSRange, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
                let font = (value == nil) ? regularFont : boldFont
                bolded.addAttribute(NSAttributedStringKey.font, value: font!, range: range)
            }
            
            labelPlace.attributedText = bolded
        }
    }
    
    let labelPlace: UILabel = {
        let label = UILabel()
        label.text = "Prueba de algun lugar".uppercased()
        label.font = UIFont(name: "Montserrat-Regular", size: 12)
        label.textColor = UIColor.ESPIDYColorDark()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let imageViewIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "pin-pickup")
        imageView.tintColor = UIColor.ESPIDYColorBorderView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let viewSeparator: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.ESPIDYColorBorderView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override func setupViews() {
        super.setupViews()
        
        addSubview(imageViewIcon)
        addSubview(labelPlace)
        addSubview(viewSeparator)
        
        imageViewIcon.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        imageViewIcon.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        imageViewIcon.widthAnchor.constraint(equalToConstant: 20).isActive = true
        imageViewIcon.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        labelPlace.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        labelPlace.leftAnchor.constraint(equalTo: imageViewIcon.rightAnchor, constant: 8).isActive = true
        labelPlace.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8).isActive = true
        
        viewSeparator.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        viewSeparator.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 36).isActive = true
        viewSeparator.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        viewSeparator.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        
        
    }
}

