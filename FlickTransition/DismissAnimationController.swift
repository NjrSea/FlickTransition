//
//  DismissAnimationController.swift
//  FlickTransition
//
//  Created by paul on 16/9/18.
//  Copyright © 2016年 paul. All rights reserved.
//

import UIKit

class DismissAnimationController: NSObject, UIViewControllerAnimatedTransitioning {

    private let scaling: CGFloat = 0.95
    
    var dismissDirection: Direction = .Left
    var dismissDuration = 0.2
    
    private var dimmingView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.4)
        return view
    }()
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return dismissDuration
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        
        guard let fromVC = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey),
            let toVC = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey),
            let containerView = transitionContext.containerView() else {
                return
        }
     
        let snapshot = toVC.view.snapshotViewAfterScreenUpdates(true)
        snapshot.addSubview(dimmingView)
        snapshot.frame = toVC.view.bounds
        
        dimmingView.frame = snapshot.bounds
        dimmingView.alpha = 1.0
        
        snapshot.layer.transform = CATransform3DScale(CATransform3DIdentity, self.scaling, self.scaling, 1)
        containerView.insertSubview(snapshot, atIndex: 0)
        
        toVC.view.hidden = true
        
        let duration = transitionDuration(transitionContext)
        
        UIView.animateWithDuration(duration, delay: 0, options: .CurveLinear, animations: {
            snapshot.layer.transform = CATransform3DIdentity
            self.dimmingView.alpha = 0.0
            var frame = fromVC.view.frame
            switch self.dismissDirection {
            case .Left:
                frame.origin.x = -frame.width
                fromVC.view.frame = frame
            case .Right:
                frame.origin.x = frame.width
                fromVC.view.frame = frame
            case .Up:
                frame.origin.y = -frame.height
                fromVC.view.frame = frame
            case .Down:
                frame.origin.y = frame.height
                fromVC.view.frame = frame
            }
        }) { _ in
            snapshot.removeFromSuperview()
            self.dimmingView.removeFromSuperview()
            toVC.view.hidden = false
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        }
    }
    
}
