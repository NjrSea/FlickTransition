//
//  FlickInteractionController.swift
//  FlickTransition
//
//  Created by paul on 16/9/18.
//  Copyright © 2016年 paul. All rights reserved.
//

import UIKit

protocol FlickProgressProvider {
    
    var begin: (Void -> Void)? { set get }
    var changed: ((CGFloat, CGFloat)-> Void)? { set get }
    var end: (Void -> Void)? { set get }
    var cancel: (Void -> Void)? { set get }
    var setUsingFlickInteractiveTransition: (Bool -> Void)? { set get }
    
}

class FlickInteractionController: UIPercentDrivenInteractiveTransition {
    
    var usingInteractiveTransition: Bool = false
    
    var interactionInProgress = false
    
    private var shouldCompleteTransition = false
    
    var isVertical = false
    
    var progressProvider: FlickProgressProvider? {
        didSet {
            progressProvider?.begin = { [weak self] in
                self?.interactionInProgress = true
            }
            progressProvider?.changed = { [weak self] (progress, completeProgress) in
                self?.shouldCompleteTransition = progress > completeProgress
                self?.updateInteractiveTransition(progress)
            }
            progressProvider?.cancel = { [weak self] in
                self?.interactionInProgress = false
                self?.cancelInteractiveTransition()
            }
            progressProvider?.end = { [weak self] in
                self?.interactionInProgress = false
                if self?.shouldCompleteTransition == false {
                    self?.completionSpeed = (self?.isVertical == false) ? 0.5 : 0.25
                    self?.cancelInteractiveTransition()
                } else {
                    self?.completionSpeed = 1.0
                    self?.finishInteractiveTransition()
                }
            }
            progressProvider?.setUsingFlickInteractiveTransition = { [weak self] (using) in
                self?.usingInteractiveTransition = using
            }
        }
    }
    
}
