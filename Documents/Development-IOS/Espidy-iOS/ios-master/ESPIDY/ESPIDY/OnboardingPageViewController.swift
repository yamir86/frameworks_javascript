//
//  OnboardingPageViewController.swift
//  ESPIDY
//
//  Created by FreddyA on 8/26/16.
//  Copyright © 2016 Kretum. All rights reserved.
//

import UIKit

enum OnboardingData: String {
    case Page1
    case Page2
    case Page3
    
    static let allValues = [Page1, Page2, Page3]
    
    var wizardImage: String {
        switch self {
        case .Page1:
            return "view1-wizard"
        case .Page2:
            return "view2-wizard"
        case .Page3:
            return "view3-wizard"
        }
    }
    
    var titleText: String {
        switch self {
        case .Page1:
            return "TIRED OF".localized
        case .Page2:
            return "REQUEST".localized
        case .Page3:
            return "SAVE TIME".localized
        }
    }
    
    var subtitleText: String {
        switch self {
        case .Page1:
            return "WASTE TIME?".localized
        case .Page2:
            return "YOUR SERVICE".localized
        case .Page3:
            return "WITH ESPIDY".localized
        }
    }
    
}

class OnboardingPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    // MARK: - Properties
    var flag = false
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self
        delegate = self
        
        setViewControllers([getViewControllerAtIndex(0)!] as [UIViewController],
                           direction: UIPageViewControllerNavigationDirection.forward,
                           animated: false, completion: nil)
        
        UIPageControl.appearance().pageIndicatorTintColor = UIColor.lightGray
        UIPageControl.appearance().currentPageIndicatorTintColor = UIColor.darkGray
        UIPageControl.appearance().bounds = CGRect(x: 0, y: 10, width: 0, height: 0)
        view.backgroundColor = UIColor.white

    }
    override func viewDidLayoutSubviews() {
        for subView in self.view.subviews {
            if subView is UIScrollView {
                subView.frame = self.view.bounds
            } else if subView is UIPageControl {
                self.view.bringSubview(toFront: subView)
            }
        }
        super.viewDidLayoutSubviews()
    }
    
    // MARK: - UIPageViewController DataSource
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let pageContent: OnboardingViewController = viewController as! OnboardingViewController
        if pageContent.pageIndex > 0 {
            return getViewControllerAtIndex(pageContent.pageIndex - 1)
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController?    {
        let pageContent: OnboardingViewController = viewController as! OnboardingViewController
        if pageContent.pageIndex + 1 <= OnboardingData.allValues.count {
            return getViewControllerAtIndex(pageContent.pageIndex + 1)
        }
        return nil
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return OnboardingData.allValues.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    // MARK: - UIPageViewController Delegate
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        let controller = pendingViewControllers.first as! OnboardingViewController
        if controller.pageIndex == OnboardingData.allValues.count {
            flag = true
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if flag {
            Settings.groupDefaults().set(true, forKey: onboardingKey)
            let storyboard = UIStoryboard(name: Storyboard.FlowLoginRegister.rawValue, bundle: nil)
            let loginViewController = storyboard.instantiateViewController(withIdentifier: "loginViewController") as! LoginViewController
            self.present(loginViewController, animated: true, completion: nil)
//            let ad = UIApplication.sharedApplication().delegate as! AppDelegate
//            ad.launchStoryboard(Storyboard.FlowLoginRegister, animated: false)
        }
        
    }

    // MARK: - Methods
    func getViewControllerAtIndex(_ index: NSInteger) -> OnboardingViewController? {
        
        let controller: OnboardingViewController
        
        if index < OnboardingData.allValues.count {
            controller = storyboard?.instantiateViewController(withIdentifier: "PageContent") as! OnboardingViewController
            controller.wizardImage = OnboardingData.allValues[index].wizardImage
            controller.titleText = OnboardingData.allValues[index].titleText
            controller.subtitleText = OnboardingData.allValues[index].subtitleText
            controller.pageIndex = index
        } else {
            controller = OnboardingViewController()
            controller.pageIndex = index
        }

        return controller
    }
}
