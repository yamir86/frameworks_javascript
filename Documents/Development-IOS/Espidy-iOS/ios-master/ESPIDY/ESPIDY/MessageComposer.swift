//
//  MessageComposer.swift
//  ESPIDY
//
//  Created by FreddyA on 11/28/16.
//  Copyright © 2016 Kretum. All rights reserved.
//

import Foundation
import MessageUI

class MessageComposer: NSObject, MFMessageComposeViewControllerDelegate {
    
    // A wrapper function to indicate whether or not a text message can be sent from the user's
    func canSendText() -> Bool {
        return MFMessageComposeViewController.canSendText()
    }
    
    // Configures and returns a MFMessageComposeViewController instance
    func configuredMessageComposeViewController(_ textMessageRecipients:[String] ,textBody body:String) -> MFMessageComposeViewController {

        let messageComposeVC = MFMessageComposeViewController()
        messageComposeVC.messageComposeDelegate = self //  Make sure to set this property to self, so that the controller can be dismissed!
        messageComposeVC.recipients = textMessageRecipients
        messageComposeVC.body = body
        return messageComposeVC
    }
    
    // MFMessageComposeViewControllerDelegate callback - dismisses the view controller when the user is finished with it
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
    
}
