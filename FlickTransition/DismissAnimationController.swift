//
//  DismissAnimationController.swift
//  FlickTransition
//
//  Created by paul on 16/9/18.
//  Copyright © 2016年 paul. All rights reserved.
//

import UIKit

class DismissAnimationController: NSObject, UIViewControllerAnimatedTransitioning {

    fileprivate let scaling: CGFloat = 0.95
    
    var dismissDirection: Direction = .Left
    var dismissDuration = 0.2
    
    fileprivate var dimmingView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0, alpha: 0.4)
        return view
    }()
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return dismissDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from),
            let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) else {
                return
        }
     
        let containerView = transitionContext.containerView
        guard let snapshot = toVC.view.snapshotView(afterScreenUpdates: true) else {
            return
        }
        snapshot.addSubview(dimmingView)
        snapshot.frame = toVC.view.bounds
        
        dimmingView.frame = snapshot.bounds
        dimmingView.alpha = 1.0
        
        snapshot.layer.transform = CATransform3DScale(CATransform3DIdentity, self.scaling, self.scaling, 1)
        containerView.insertSubview(snapshot, at: 0)
        
        toVC.view.isHidden = true
        
        let duration = transitionDuration(using: transitionContext)
        
        UIView.animate(withDuration: duration, delay: 0, options: .curveLinear, animations: {
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
            toVC.view.isHidden = false
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
    
}
