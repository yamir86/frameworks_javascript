//
//  IncomingMessagesCell.swift
//  ESPIDY
//
//  Created by Mac Hostienda Movil on 16/9/18.
//  Copyright © 2018 Kretum. All rights reserved.
//

import UIKit

class IncomingMessagesCell: UITableViewCell {
    
    //@IBOutlet weak var viewComment: UIView!
    //@IBOutlet weak var imageProfile: UIImageView!
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var heightPhoto: NSLayoutConstraint!
   // @IBOutlet weak var lblUserName: UILabel!
    
    static let nib = UINib(nibName: "IncomingMessagesCell", bundle: nil)
    

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setudUI()
        // Initialization code
    }
    
    func setudUI(){
        //viewComment.layer.cornerRadius = 10
        //viewComment.layer.masksToBounds = true
        //textView.text = ""
        //imageProfile.layer.cornerRadius = 20
        //imageProfile.layer.masksToBounds = true
        textView.isScrollEnabled = false
        
    }
    
    
    func updateCommentCell(userName:String, sms : String, img : UIImage, sendImage : Bool){
        
        //lblUserName.text = userName
        textView.text = sms
        textViewDidChange(textView)
        if sendImage {
            self.heightPhoto.constant = 256
            self.photo.image = img
            //photo.sd_setImage(with:urlPhoto, completed: nil)
        }else{
            self.photo.image = nil
            self.heightPhoto.constant = 0
        }
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}

extension IncomingMessagesCell: UITextViewDelegate{
    func textViewDidChange(_ textView: UITextView) {
        print(textView.text)
        print("width ---> \(textView.frame.size.width)")
        print("height ---> \(textView.frame.size.height)")
        let size = CGSize(width: textView.frame.size.width, height: .infinity)
        let stimatedSize = textView.sizeThatFits(size)
        
        textView.constraints.forEach{
            (constraint) in
            
            if constraint.firstAttribute  == .height {
                constraint.constant = stimatedSize.height
            }else{
                return
            }
        }
    }
}
