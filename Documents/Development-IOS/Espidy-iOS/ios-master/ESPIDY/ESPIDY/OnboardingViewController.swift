//
//  OnboardingViewController.swift
//  ESPIDY
//
//  Created by FreddyA on 8/26/16.
//  Copyright © 2016 Kretum. All rights reserved.
//

import UIKit

class OnboardingViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var wizardImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    // MARK: - Properties
    var pageIndex: Int = 0
    var wizardImage: String?
    var titleText: String?
    var subtitleText: String?
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let wizardImage = wizardImage {
            wizardImageView.image = UIImage(named: wizardImage)
        }
        
        if let titleText = titleText {
            titleLabel.text = titleText
        }
        
        if let subtitleText = subtitleText {
            subtitleLabel.text = subtitleText
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
