//
//  PresentAnimationController.swift
//  FlickTransition
//
//  Created by paul on 16/9/18.
//  Copyright © 2016年 paul. All rights reserved.
//

import UIKit

class PresentAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    var originFrame = CGRect.zero
    
    private let scaling: CGFloat = 0.95
    
    private var animatingView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.whiteColor()
        return view
    }()
    
    private var dimmingView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        return view
    }()
    
    private var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.blackColor()
        return view
    }()
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 1.0
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        guard let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey),
            let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey),
            let containerView = transitionContext.containerView() else {
                return
        }
        
        let finalFrame = transitionContext.finalFrameForViewController(toVC)
        
        let snapshot = fromVC.view.snapshotViewAfterScreenUpdates(false)
        snapshot.frame = fromVC.view.bounds
        dimmingView.frame = snapshot.bounds
        snapshot.addSubview(dimmingView)
        
        animatingView.frame = originFrame
        backgroundView.frame = fromVC.view.bounds
        containerView.addSubview(animatingView)
        containerView.addSubview(toVC.view)
        containerView.insertSubview(snapshot, atIndex: 0)
        containerView.insertSubview(backgroundView, atIndex: 0)
        
        animatingView.alpha = 0
        dimmingView.alpha = 0
        fromVC.view.hidden = true
        toVC.view.alpha = 0
        
        let duration = transitionDuration(transitionContext)
        let stepDuration = duration / 3.0
        UIView.animateKeyframesWithDuration(duration, delay: 0, options: .CalculationModeCubic, animations: { 
            
            UIView.addKeyframeWithRelativeStartTime(0, relativeDuration: stepDuration, animations: {
                snapshot.layer.transform = CATransform3DScale(CATransform3DIdentity, self.scaling, self.scaling, 1)
                self.dimmingView.alpha = 1.0
                self.animatingView.alpha = 1.0
            })
            
            UIView.addKeyframeWithRelativeStartTime(stepDuration, relativeDuration: stepDuration, animations: {
                self.animatingView.frame = finalFrame
            })
            
            UIView.addKeyframeWithRelativeStartTime(2 * stepDuration, relativeDuration: stepDuration, animations: {
                toVC.view.alpha = 1
            })
            
        }) { _ in
            self.animatingView.removeFromSuperview()
            self.dimmingView.removeFromSuperview()
            snapshot.removeFromSuperview()
            self.backgroundView.removeFromSuperview()
            fromVC.view.hidden = false
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        }
        
    }
}
