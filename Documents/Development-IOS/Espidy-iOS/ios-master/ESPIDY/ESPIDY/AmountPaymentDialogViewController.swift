//
//  AmountPaymentDialogViewController.swift
//  ESPIDY
//
//  Created by Mac Hostienda Movil on 14/9/18.
//  Copyright © 2018 Kretum. All rights reserved.
//

import UIKit
import PKHUD

class AmountPaymentDialogViewController: UIViewController {

    @IBOutlet weak var labelTextTitle: UILabel!
    @IBOutlet weak var textFieldCost: UITextField!
    @IBOutlet weak var buttonAccept: UIButton!
    @IBOutlet weak var buttonCancel: UIButton!
    
    
    var shipment: Shipment?
    // presenter
    fileprivate let presenter = InstanPayDeliveryPresenter(service: InstanPayDeliveryServices())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        presenter.attachView(view: self)
        
        // Do any additional setup after loading the view.
    }
    
    func setupView(){
        self.labelTextTitle.text = "ENTER THE AMOUNT".localized
        self.buttonAccept.setTitle("CANCEL".localized, for: .normal)
        self.buttonAccept.setTitle("ACCEPT!".localized, for: .normal)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //hide the keyboard by pressing outside the dialog
        self.view.endEditing(true)
    }
    
    @IBAction func acceptAction(_ sender: UIButton) {
        self.view.endEditing(true)
        print("Acepto!")
        
        if let text = textFieldCost.text, text.count > 0{
            HUD.show(.rotatingImage(UIImage(named: "progressHUD")))
            guard let shipmentID = shipment?.id, let amount = textFieldCost.text else {
                return
            }
            self.createPayDelivery(shipment_id: String(shipmentID), amount: amount)
            
        }else{
            let alert = UIAlertController(title: "¡ATENTION!".localized, message: "Ingrese un monto", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }

    }
    
    @IBAction func cancelAction(_ sender: UIButton) {
        self.view.endEditing(true)
        print("Cancelo!")
        self.dismiss(animated: true, completion: nil)
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


extension AmountPaymentDialogViewController: InstanPayDeliveryProtocol{
    
    func createPayDelivery(shipment_id: String, amount: String) {
        self.presenter.create(shipment_id: shipment_id, amount: amount)
    }
    
    func aceptPayDelivery(shipment_id: String) {
        //void here class
    }
    
    func cancelPayDelivery(shipment_id: String) {
        //void here class
    }
    
    func responseConsult(status: Int, message: String) {
        print("status ---> \(status)")
        if status == 200{
            HUD.flash(.success, delay: 1.0) { _ in  }
            self.dismiss(animated: true, completion: nil)
        }else{
            HUD.flash(.error, delay: 1.0) { _ in
                let alert = UIAlertController(title: "¡ATENTION!".localized, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                //self.dismiss(animated: true, completion: nil)
            }
            
        }
    }
    
    
}
