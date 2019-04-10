//
//  CollectionViewCellVehicle.swift
//  ESPIDY
//
//  Created by FreddyA on 9/3/16.
//  Copyright © 2016 Kretum. All rights reserved.
//

import UIKit

class CollectionViewCellVehicle: UICollectionViewCell {
    
    var activeService: Bool? {
        didSet {
            self.isUserInteractionEnabled = activeService!
        }
    }
    
    @IBOutlet weak var imageVehicle: UIImageView!
    @IBOutlet weak var labelVehicle: UILabel!

    override var isHighlighted: Bool {
        didSet {
            if isSelected {
                imageVehicle.isHighlighted = isSelected
                labelVehicle.textColor = UIColor.white
            } else {
                imageVehicle.isHighlighted = isSelected
                labelVehicle.textColor = UIColor.ESPIDYColorUnSelected()
            }
        }
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                imageVehicle.isHighlighted = isSelected
                labelVehicle.textColor = UIColor.white
            } else {
                imageVehicle.isHighlighted = isSelected
                labelVehicle.textColor = UIColor.ESPIDYColorUnSelected()
            }
            
//            imageVehicle.highlighted = selected ? true : false
//            labelVehicle.textColor = selected ? UIColor.whiteColor() : UIColor.ESPIDYColorUnSelected()

        }
    }

}
