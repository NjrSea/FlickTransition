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
    
    fileprivate let scaling: CGFloat = 0.95
    
    fileprivate var animatingView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }()
    
    fileprivate var dimmingView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.5)
        return view
    }()
    
    fileprivate var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black
        return view
    }()
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1.0
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) else {
                return
        }
        
        let containerView = transitionContext.containerView
        let finalFrame = transitionContext.finalFrame(for: toVC)
        
        guard let snapshot = fromVC.view.snapshotView(afterScreenUpdates: false) else {
            return
        }
        snapshot.frame = fromVC.view.bounds
        dimmingView.frame = snapshot.bounds
        snapshot.addSubview(dimmingView)
        
        animatingView.frame = originFrame
        backgroundView.frame = fromVC.view.bounds
        containerView.addSubview(animatingView)
        containerView.addSubview(toVC.view)
        containerView.insertSubview(snapshot, at: 0)
        containerView.insertSubview(backgroundView, at: 0)
        
        animatingView.alpha = 0
        dimmingView.alpha = 0
        fromVC.view.isHidden = true
        toVC.view.alpha = 0
        
        let duration = transitionDuration(using: transitionContext)
        let stepDuration = duration / 3.0
        UIView.animateKeyframes(withDuration: duration, delay: 0, options: .calculationModeCubic, animations: { 
            
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: stepDuration, animations: {
                snapshot.layer.transform = CATransform3DScale(CATransform3DIdentity, self.scaling, self.scaling, 1)
                self.dimmingView.alpha = 1.0
                self.animatingView.alpha = 1.0
            })
            
            UIView.addKeyframe(withRelativeStartTime: stepDuration, relativeDuration: stepDuration, animations: {
                self.animatingView.frame = finalFrame
            })
            
            UIView.addKeyframe(withRelativeStartTime: 2 * stepDuration, relativeDuration: stepDuration, animations: {
                toVC.view.alpha = 1
            })
            
        }) { _ in
            self.animatingView.removeFromSuperview()
            self.dimmingView.removeFromSuperview()
            snapshot.removeFromSuperview()
            self.backgroundView.removeFromSuperview()
            fromVC.view.isHidden = false
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
        
    }
}
