//
//  HistoryTableViewCell.swift
//  ESPIDY
//
//  Created by FreddyA on 9/13/16.
//  Copyright © 2016 Kretum. All rights reserved.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {
    
    //Idicator Outelts
    @IBOutlet weak var lblNameDriver: UILabel!
    @IBOutlet weak var lblNameTime: UILabel!
    @IBOutlet weak var lblNameDistance: UILabel!
    @IBOutlet weak var lblNameCost: UILabel!
    @IBOutlet weak var lblNamePayment: UILabel!
    //EditOutlets
    @IBOutlet weak var lblShowDateAndTime: UILabel!
    @IBOutlet weak var imageViewHistory: UIImageView!
    @IBOutlet weak var imagePaymentType: UIImageView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelTime: UILabel!
    @IBOutlet weak var labelDistance: UILabel!
    @IBOutlet weak var labelCost: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //statics
        lblNameDriver.text = "Driver:".localized
        lblNameTime.text = "Time:".localized
        lblNameDistance.text = "Distance:".localized
        lblNameCost.text = "Price:".localized
        lblNamePayment.text = "payment:".localized
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func loadData(_ shipment: Shipment) {
        
        if shipment.status == "PENDING" {
            labelName.text = shipment.status?.uppercased()
            labelTime.text = "-"
            labelCost.text = "-"
            
            if let shippingMethod = shipment.shippingMethod {
                switch shippingMethod {
                case .Food:
                    imageViewHistory.image = UIImage(named: "food-unselect-mainview") //Cambiar
                case .Motorcycle:
                    imageViewHistory.image = UIImage(named: "icon-moto2-history")
                case .Car:
                    imageViewHistory.image = UIImage(named: "icon-car2-history")
                }
            }
        } else {
            let nf = NumberFormatter()
            nf.numberStyle = NumberFormatter.Style.decimal
            nf.maximumFractionDigits = 2
            
            labelName.text = shipment.driver?.name?.uppercased()
            
            if let deliveryTime = shipment.delivery_time {
                labelTime.text = "\(deliveryTime) Min."
            } else {
                labelTime.text = "-"
            }
            
            if let costService = shipment.cost {
                if let costS = nf.string(from: NSNumber(value: costService)) {
                    labelCost.text = "\(costS) DOP"
                } else {
                    labelCost.text = "_"
                }
            } else {
                labelCost.text = "-"
            }
            
            if let shippingMethod = shipment.shippingMethod {
                switch shippingMethod {
                case .Food:
                    imageViewHistory.image = UIImage(named: "food-unselect-mainview") //Cambiar
                case .Motorcycle:
                    imageViewHistory.image = UIImage(named: "icon-moto2-history")
                case .Car:
                    imageViewHistory.image = UIImage(named: "icon-car2-history")
                }
            }
            
            if shipment.payment_method_id == 2 {
                self.imagePaymentType.image = UIImage(named: "ic-cash-green")
            }else{
                self.imagePaymentType.image = UIImage(named: "ic-tdc")
            }
           
            if let distance = shipment.distance {
                let textData = Double(distance)
                let text = String(format: "%.2f", arguments: [textData])
                self.labelDistance.text = text + " KM"
            }else{
                self.labelDistance.text = "-"
            }
        }
        
        if let dateString = shipment.dateString {
            self.lblShowDateAndTime.text = dateString
        }else{
            self.lblShowDateAndTime.text = " - "
        }
        
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        setupInit()

    }

    func setupInit(){
        //statics
        lblNameDriver.text = "Driver:".localized
        lblNameTime.text = "Time:".localized
        lblNameDistance.text = "Distance:".localized
        lblNameCost.text = "Price:".localized
        lblNamePayment.text = "payment:".localized
        
        //editable
        labelName.text = nil
        labelTime.text = nil
        labelDistance.text = nil
        labelCost.text = nil
        imageViewHistory.image = nil
        imagePaymentType.image = nil
    }
}
