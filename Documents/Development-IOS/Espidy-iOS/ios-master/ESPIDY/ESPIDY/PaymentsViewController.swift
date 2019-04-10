//
//  PaymentsViewController.swift
//  ESPIDY
//
//  Created by FreddyA on 9/5/16.
//  Copyright © 2016 Kretum. All rights reserved.
//

import UIKit
import PKHUD

class PaymentsViewController: UIViewController {
    
    var titleNavigationBar: String?
    var creditCards = [Credit_card]()
    
    var constraintTopTableViewController: NSLayoutConstraint?
    
    @IBOutlet weak var tableViewCreditCard: UITableView!
    @IBOutlet weak var constraintTopBalance: NSLayoutConstraint!
    @IBOutlet weak var constraintBottomBalance: NSLayoutConstraint!
    @IBOutlet weak var stackViewBalance: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let titleNavigationBar = titleNavigationBar {
            let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 44))
            titleLabel.text = titleNavigationBar
            titleLabel.textColor = UIColor.white
            titleLabel.font = UIFont(name: "Montserrat-Regular", size: 15)
            titleLabel.textAlignment = .center
            navigationItem.titleView = titleLabel
        }
        
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Methods
    func setupView() {
        
        if stackViewBalance.isHidden {
            constraintTopBalance.isActive = false
            constraintBottomBalance.isActive = false
            constraintTopTableViewController = NSLayoutConstraint(
                item: tableViewCreditCard,
                attribute: .top,
                relatedBy: .equal,
                toItem: self.topLayoutGuide,
                attribute: .bottom,
                multiplier: 1,
                constant: 16)
            constraintTopTableViewController?.isActive = true
        }
        
//        let creditCard0 = Credit_card(fullname: "Jason Bourne",
//                                     card_number: "4502125506634120",
//                                     cvc_number: 121,
//                                     card_expiration_month: 3,
//                                     card_expiration_year: 2020)
//        
//        let creditCard1 = Credit_card(fullname: "Jason Bourne",
//                                     card_number: "5450344392042400",
//                                     cvc_number: 323,
//                                     card_expiration_month: 10,
//                                     card_expiration_year: 2026)
//        
//        let creditCard2 = Credit_card(fullname: "Jason Bourne",
//                                     card_number: "6011652127645515",
//                                     cvc_number: 565,
//                                     card_expiration_month: 1,
//                                     card_expiration_year: 2035)
//        
//        let creditCard3 = Credit_card(fullname: "Jason Bourne",
//                                     card_number: "370831167399955",
//                                     cvc_number: 878,
//                                     card_expiration_month: 12,
//                                     card_expiration_year: 2021)
//        
//        let creditCard4 = Credit_card(fullname: "Jason Bourne",
//                                      card_number: "36781082370936",
//                                      cvc_number: 375,
//                                      card_expiration_month: 9,
//                                      card_expiration_year: 2028)
//        
//        creditCards = [creditCard0, creditCard1, creditCard4, creditCard2, creditCard3]
        
        tableViewCreditCard.rowHeight = 90
        tableViewCreditCard.tableFooterView = UIView(frame: CGRect.zero)
        
        let cellNib = UINib(nibName: "CreditCardCell", bundle: nil)
        tableViewCreditCard.register(cellNib, forCellReuseIdentifier: "CreditCardCell")
        
        fetchCreditCards()
        tableViewCreditCard.reloadData()
    }
    
    func fetchCreditCards() {
        HUD.show(.rotatingImage(UIImage(named: "progressHUD")))
        EspidyApiManager.sharedInstance.creditCards { (result) in

            guard result.error == nil else {
                // TODO: display error
                HUD.flash(.error, delay: 1.0) { _ in
                }
                return
            }
            if let fetchedCreditCards = result.value {
                HUD.hide(animated: true, completion: { (true) in
                    Global_creditCards = [Credit_card]()
                    Global_creditCards.append(Credit_card(payment_method_id: 2,
                                                          imageCard: UIImage(named: "ic-cash-green")!,
                                                          cardNumber: "CASH"))
                    
                    Global_creditCards.append(contentsOf: fetchedCreditCards)
                    self.tableViewCreditCard.reloadData()
                })
            }
        }
    }
    
    func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
    
    // MARK: - Actions
    @IBAction func buttonAddCard() {
        let storyboard = UIStoryboard(name: Storyboard.FlowLoginRegister.rawValue, bundle: nil)
        let registerCardViewController = storyboard.instantiateViewController(withIdentifier: "RegisterCardViewController") as! RegisterCardViewController
        registerCardViewController.titleNavigationBar = "ADD A NEW CREDIT CARD!".localized
        registerCardViewController.info0 = ""
        registerCardViewController.info1 = "OR COMPLETE THE FIELDS PRESENTED BELOW".localized
        registerCardViewController.titleButton = "ADD!".localized
        registerCardViewController.delegate = self
        
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.pushViewController(registerCardViewController, animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension PaymentsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Global_creditCards.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CreditCardCell", for: indexPath) as! CreditCardTableViewCell
        let creditCard = Global_creditCards[indexPath.row]
        cell.loadData(creditCard)
        
        return cell
    }
    
//    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
//        if editingStyle == .Delete {
//            creditCards.removeAtIndex(indexPath.item)
//            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
//        }
//    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if indexPath.item == 0 {
            let deleteAction = UITableViewRowAction(style: .default, title: "           ") { (_, _) in }
            deleteAction.backgroundColor = UIColor.white
            return [deleteAction]
        } else {
            let deleteAction = UITableViewRowAction(style: .normal, title: "           ") { (rowAction:UITableViewRowAction, indexPath:IndexPath) -> Void in
                
                let idCreditCard = Global_creditCards[indexPath.item].id!
                EspidyApiManager.sharedInstance.deleteCreditCard(String(idCreditCard), completionHandler: { (error) in
                    if error == nil {
                        Global_creditCards.remove(at: indexPath.item)
                        tableView.deleteRows(at: [indexPath], with: .fade)
                    }
                })
            }
            
            deleteAction.backgroundColor = UIColor(patternImage: UIImage(named: "iconDeleteRow")!)
            
            return [deleteAction]
        }
    }
}

extension PaymentsViewController: UITableViewDelegate {
    
}

extension PaymentsViewController: RegisterCardViewControllerDelegate {
    func successRegister() {
        isExistsCreditCard()
        navigationController?.popViewController(animated: true)
        fetchCreditCards()
        tableViewCreditCard.reloadData()
    }
}
