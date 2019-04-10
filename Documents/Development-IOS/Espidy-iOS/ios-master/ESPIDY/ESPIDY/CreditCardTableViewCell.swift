//
//  CreditCardTableViewCell.swift
//  ESPIDY
//
//  Created by FreddyA on 9/13/16.
//  Copyright © 2016 Kretum. All rights reserved.
//

import UIKit
import Caishen

class CreditCardTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imageViewCreditCard: UIImageView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelNumber: UILabel!
    @IBOutlet weak var labelValidDate: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func loadData(_ creditCard: Credit_card) {
        if creditCard.payment_method_id == 1 {
            labelName.text = creditCard.fullname?.uppercased() ?? ""
            labelNumber.text = creditCard.card_number ?? "***********"
            labelValidDate.text = "**/2***"
            imageViewCreditCard.image = creditCard.imageCard
        } else {
            imageViewCreditCard.image = creditCard.imageCard
            labelName.text = creditCard.card_number
            labelNumber.text = ""
            labelValidDate.text = ""
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        labelName.text = nil
        labelNumber.text = nil
        labelValidDate.text = nil
        imageViewCreditCard.image = nil
    }
}
