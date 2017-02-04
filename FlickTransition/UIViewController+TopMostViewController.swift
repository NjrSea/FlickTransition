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
        let rootViewController = UIApplication.shared.windows.first?.rootViewController
        return self.topMostViewControllerOfViewController(viewController: rootViewController)
    }
    
    class func topMostViewControllerOfViewController(viewController: UIViewController?) -> UIViewController? {
        if let tabBarController = viewController as? UITabBarController,
            let selectedViewController = tabBarController.selectedViewController {
            return self.topMostViewControllerOfViewController(viewController: selectedViewController)
        }
        
        if let navigationController = viewController as? UINavigationController,
            let visibleViewController = navigationController.visibleViewController {
            return self.topMostViewControllerOfViewController(viewController: visibleViewController)
        }
        
        if let presentedViewController = viewController?.presentedViewController {
            return self.topMostViewControllerOfViewController(viewController: presentedViewController)
        }
        
        for subview in viewController?.view?.subviews ?? [] {
            if let childViewController = subview.next as? UIViewController {
                return self.topMostViewControllerOfViewController(viewController: childViewController)
            }
        }
        
        return viewController
    }
    
}
