//
//  UIViewController+TopMostViewController.swift
//  FlickTransition
//
//  Created by paul on 16/9/18.
//  Copyright © 2016年 paul. All rights reserved.
//

import UIKit

extension UIViewController {
    
    /// Returns the current application's top most view controller.
    public class func topMostViewController() -> UIViewController? {
        let rootViewController = UIApplication.sharedApplication().windows.first?.rootViewController
        return self.topMostViewControllerOfViewController(rootViewController)
    }
    
    class func topMostViewControllerOfViewController(viewController: UIViewController?) -> UIViewController? {
        if let tabBarController = viewController as? UITabBarController,
            let selectedViewController = tabBarController.selectedViewController {
            return self.topMostViewControllerOfViewController(selectedViewController)
        }
        
        if let navigationController = viewController as? UINavigationController,
            let visibleViewController = navigationController.visibleViewController {
            return self.topMostViewControllerOfViewController(visibleViewController)
        }
        
        if let presentedViewController = viewController?.presentedViewController {
            return self.topMostViewControllerOfViewController(presentedViewController)
        }
        
        for subview in viewController?.view?.subviews ?? [] {
            if let childViewController = subview.nextResponder() as? UIViewController {
                return self.topMostViewControllerOfViewController(childViewController)
            }
        }
        
        return viewController
    }
    
}
