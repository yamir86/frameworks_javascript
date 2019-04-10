//
//  HistoryViewController.swift
//  ESPIDY
//
//  Created by FreddyA on 9/5/16.
//  Copyright © 2016 Kretum. All rights reserved.
//

import UIKit
import PKHUD

class HistoryViewController: UIViewController {
    
    var titleNavigationBar: String?
    var history = [Shipment]()
    
    @IBOutlet weak var tableViewHistory: UITableView!
    
    
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
//        let espidyService0 = Shipment(shippingMethod: .Bike,
//                                      driver: Driver(name: "Eddard Stark", picture: "", feedbackStars: 3),
//                                          delivery_time: "1 H 45 MIN",
//                                          cost: "$ 350")
//        let espidyService1 = Shipment(shippingMethod: .Motorcycle,
//                                          driver: Driver(name: "Catelyn Tully", picture: "", feedbackStars: 3),
//                                          delivery_time: "30 MIN",
//                                          cost: "$ 250")
//        let espidyService2 = Shipment(shippingMethod: .Car,
//                                          driver: Driver(name: "Robb Stark", picture: "", feedbackStars: 3),
//                                          delivery_time: "1 H",
//                                          cost: "$ 50")
//        let espidyService3 = Shipment(shippingMethod: .Bike,
//                                          driver: Driver(name: "Sansa Stark", picture: "", feedbackStars: 3),
//                                          delivery_time: "15 MIN",
//                                          cost: "$ 150")
//        let espidyService4 = Shipment(shippingMethod: .Motorcycle,
//                                          driver: Driver(name: "Arya Stark", picture: "", feedbackStars: 3),
//                                          delivery_time: "20 MIN",
//                                          cost: "$ 15")
//        
//        history = [espidyService0, espidyService1, espidyService2, espidyService3, espidyService4]
        
        //tableViewHistory.rowHeight = 100
        //tableViewHistory.tableFooterView = UIView(frame: CGRect.zero)
        
        let cellNib = UINib(nibName: "HistoryTableViewCell", bundle: nil)
        tableViewHistory.register(cellNib, forCellReuseIdentifier: "HistoryCell")
        
        fetchedShipments()
    }
    
    func fetchedShipments() {
        
        HUD.show(.rotatingImage(UIImage(named: "progressHUD")))
        EspidyApiManager.sharedInstance.shipments { (result) in
            
            guard result.error == nil else {
                // TODO: display error
                HUD.flash(.error, delay: 1.0) { _ in
//                    print("AlertMessageError \(result.error)")
                }
                return
            }
            if let fetched = result.value {
                HUD.hide(animated: true, completion: { (true) in
                    for aux in fetched{
                        if let status = aux.status, status != "CANCELLED_BY_USER"{
                            self.history.append(aux)
                        }else{
                            print("--> status: CANCELLED_BY_USER ")
                        }
                    }
                    self.tableViewHistory.reloadData()
                })
            }
        }
    }

    func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
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




extension HistoryViewController: UITableViewDataSource {
    
    func invertArray (){
        var auxArray = [Shipment]()
        for arrayIndex in stride(from: history.count - 1, through: 0, by: -1) {
            auxArray.append(history[arrayIndex])
        }
        self.history = auxArray
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if self.history.count > 0{
            self.history = history.sorted(by: {$0.date.compare($1.date) == .orderedDescending})
            //invertArray()
            return history.count
        }else{
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath) as! HistoryTableViewCell
        let shipment = history[indexPath.row]
        cell.loadData(shipment)
        
        return cell
    }
    
    //metodo de seleccion
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("---> selecciono: \(self.history[indexPath.row])")
        let index = indexPath.row
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let nextViewController = storyBoard.instantiateViewController(withIdentifier: "DetailsHistoryViewController") as! DetailsHistoryViewController
        //nextViewController.selectOperation = self.history[indexPath.row]
        nextViewController.markerDropOffLocalitation = self.history[index].dropoff_location
        nextViewController.markerPickUpLocalitation  = self.history[index].pickup_location
        
        navigationController?.pushViewController(nextViewController, animated: true)
        self.tableViewHistory.deselectRow(at: indexPath, animated: true)
    }
}

extension HistoryViewController: UITableViewDelegate {
    
}
