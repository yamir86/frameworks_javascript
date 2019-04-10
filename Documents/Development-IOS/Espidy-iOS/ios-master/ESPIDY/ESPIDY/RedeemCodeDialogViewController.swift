//
//  RedeemCodeDialogViewController.swift
//  ESPIDY
//
//  Created by Mac Hostienda Movil on 8/9/18.
//  Copyright © 2018 Kretum. All rights reserved.
//

import UIKit
import PKHUD

class RedeemCodeDialogViewController: UIViewController {

    @IBOutlet weak var lblText: UILabel!
    @IBOutlet weak var tfRedeemCode: UITextField!
    @IBOutlet weak var btnAccepted: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    
    // Presenter
    fileprivate let presenter = ReaderPresenter(readService: CodeService())
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        presenter.attachView(view: self)
        // Do any additional setup after loading the view.
    }

    func setupView(){
        self.tfRedeemCode.delegate = self
        self.tfRedeemCode.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        self.lblText.text = "ENTER THE GIFT CODE".localized
        self.btnCancel.setTitle("CANCEL".localized, for: .normal)
        self.btnAccepted.setTitle("ACCEPT!".localized, for: .normal)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @IBAction func actionCancel(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func actionAccept(_ sender: UIButton) {
        extradDataForRequest()
        print("Realziar Consulta Aqui")
    }
    
    func extradDataForRequest(){
        if let code = tfRedeemCode.text,code.count > 0,  let id = Global_UserSesion?.id{
            HUD.show(.rotatingImage(UIImage(named: "progressHUD")))
            consultacode(client_id: id, code: code)
        }else{
            let alert = UIAlertController(title: "¡ATENTION!".localized, message: "Ingrese un codigo", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }

}

extension RedeemCodeDialogViewController: ProtocolRead{
    func consultacode(client_id: Int, code: String) {
        
       presenter.ConsultaCode(client_id: client_id, code: code)
    }
    
    func respuestacode(respuesta: Bool, respuestacode: String) {
        switch respuesta {
        case true:
            HUD.flash(.success, delay: 1.0) { _ in

            }
            self.dismiss(animated: true, completion: nil)
            break
        case false:
            HUD.flash(.error, delay: 1.0) { _ in
                let alert = UIAlertController(title: "¡ATENTION!".localized, message: respuestacode, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                //self.dismiss(animated: true, completion: nil)
            }
            break
        }
    }
}

extension RedeemCodeDialogViewController: UITextFieldDelegate {
    @objc func textFieldDidChange(_ textField: UITextField) {
        if textField.text?.count ?? 0 < 7 {
            textField.text = "Espidy-"
        }
    }
}


