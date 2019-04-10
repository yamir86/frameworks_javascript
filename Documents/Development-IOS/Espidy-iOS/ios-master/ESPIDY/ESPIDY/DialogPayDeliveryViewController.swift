//
//  DialogPayDeliveryViewController.swift
//  ESPIDY
//
//  Created by Mac Hostienda Movil on 11/9/18.
//  Copyright © 2018 Kretum. All rights reserved.
//

import UIKit
import PKHUD

class DialogPayDeliveryViewController: UIViewController {

    @IBOutlet weak var lblText: UILabel!
    @IBOutlet weak var lblAmountText: UILabel!
    @IBOutlet weak var btnAccepted: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    
    //var shipment: Shipment?
    var shipment_id : String?
    // presenter
    
    fileprivate let presenter = InstanPayDeliveryPresenter(service: InstanPayDeliveryServices())
    var amount : String?
    var instant_purchase_id: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.attachView(view: self)
        
        self.setupView()
        // Do any additional setup after loading the view.
    }
    
    func setupView(){
        print("cargar de la consulta...")
        self.lblText.text = "ATTENTION!".localized
        if let amount = self.amount {
            self.lblAmountText.text = "\(amount) DOP"
        }
        self.btnCancel.setTitle("CANCEL".localized, for: .normal)
        self.btnAccepted.setTitle("ACCEPT!".localized, for: .normal)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func actionCancel(_ sender: UIButton) {
        HUD.show(.rotatingImage(UIImage(named: "progressHUD")))
        if let shipment_id = self.instant_purchase_id{
            self.cancelPayDelivery(shipment_id: shipment_id)
        }
    }
    
    @IBAction func actionAccept(_ sender: UIButton) {
        HUD.show(.rotatingImage(UIImage(named: "progressHUD")))
        if let shipment_id = self.instant_purchase_id{
            self.aceptPayDelivery(shipment_id: shipment_id)
        }
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

extension DialogPayDeliveryViewController: InstanPayDeliveryProtocol{
    
    func createPayDelivery(shipment_id: String, amount: String) {
        //void for client
    }
    
    func aceptPayDelivery(shipment_id: String) {
        self.presenter.accept(shipment_id: shipment_id)
    }
    
    func cancelPayDelivery(shipment_id: String) {
        self.presenter.cancel(shipment_id: shipment_id)
    }
    
    func responseConsult(status: Int, message: String) {
        print("status ---> \(status)")
        if status == 200{
            HUD.flash(.success, delay: 1.0) { _ in
                self.dismiss(animated: true, completion: nil)
            }
           
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

