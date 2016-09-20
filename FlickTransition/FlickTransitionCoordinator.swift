//
//  FlickTransitionCoordinator.swift
//  FlickTransition
//
//  Created by paul on 16/9/18.
//  Copyright © 2016年 paul. All rights reserved.
//

import UIKit

protocol FlickTransitionDelegate: class {
    
    func scrollView() -> UIScrollView?
    func useInteractiveDismiss() -> Bool
    func shouldBeginInteractiveDismiss() -> Bool
    
}

extension FlickTransitionDelegate {

    // MARK: Default implementation
    
    func scrollView() -> UIScrollView? {
        return nil
    }
    
    func useInteractiveDismiss() -> Bool {
        return false
    }

    func setTransitionDelegate(coordinator: FlickTransitionCoordinator) {
        (self as? UIViewController)?.transitioningDelegate = coordinator
    }
    
}

private let verticalDismissDuration: Double = 0.45

private let horizontalDismissDuration: Double = 0.6

private let verticalDismissCompletionThreshHold: CGFloat = 0.3

private let horizontalDismissCompletionThreshHold: CGFloat = 0.35


final class FlickTransitionCoordinator: NSObject, FlickProgressProvider {
    
    let presentAnimationController = PresentAnimationController()
    
    let dismissAnimationController = DismissAnimationController()
    
    let flickInteractionController = FlickInteractionController()
    
    private var defaultOriginFrame: CGRect {
        let height: CGFloat = 80.0
        let width: CGFloat = UIScreen.mainScreen().bounds.size.width
        let screenHeight: CGFloat = UIScreen.mainScreen().bounds.size.height
        return CGRect(x: 0, y: (screenHeight - height) / 2.0, width: width, height: height)
    }
    
    private var panGesture: UIPanGestureRecognizer = {
        return UIPanGestureRecognizer()
    }()
    
    private var originFrame: CGRect?
    
    // MARK: FlickProgressProvider
    
    var begin: (Void -> Void)?
    
    var changed: ((CGFloat, CGFloat)-> Void)?
    
    var end: (Void -> Void)?
    
    var cancel: (Void -> Void)?
    
    var setUsingFlickInteractiveTransition: (Bool -> Void)?
    
    // MARK: Singleton
    
    static var sharedCoordinator: FlickTransitionCoordinator {
        struct StructWrapper {
            static var instance = FlickTransitionCoordinator()
        }
        return StructWrapper.instance
    }
    
    private weak var delegate: FlickTransitionDelegate? {
        didSet {
            if let delegate = delegate {
                presentAnimationController.originFrame = originFrame ?? defaultOriginFrame
                flickInteractionController.progressProvider = self
                
                if let scrollView = delegate.scrollView() where delegate.useInteractiveDismiss() {
                    scrollView.addGestureRecognizer(panGesture)
                    scrollView.bounces = false
                    panGesture.delegate = self
                    panGesture.addTarget(self, action: #selector(pan(_:)))
                }
                delegate.setTransitionDelegate(self)
            }
        }
    }
    
    private override init() {
        
    }
    
    // MARK: Gesture
    
    private var inDismiss: Bool = false
    
    func pan(pan: UIPanGestureRecognizer) {
        guard let scrollView = delegate?.scrollView(),
            let interactive = delegate?.useInteractiveDismiss(),
            let shouldBegin = delegate?.shouldBeginInteractiveDismiss() where interactive && shouldBegin else {
                return
        }
        let coordinator = FlickTransitionCoordinator.sharedCoordinator
        let translation = pan.translationInView(pan.view)
        let offset = scrollView.contentOffset.y
        let reachTheTop = offset == 0
        let reachTheBottom = ceil(offset) ==  ceil(scrollView.contentSize.height - scrollView.frame.height + scrollView.contentInset.bottom)
        let draggingDirection = pan.direction
        
        let beginDismiss = {
            coordinator.setUsingFlickInteractiveTransition?(true)
            self.dismissViewController()
            coordinator.begin?()
        }
        let endDismiss = {
            coordinator.end?()
            self.inDismiss = false
            scrollView.scrollEnabled = true
        }
        let cancelDismiss = {
            coordinator.cancel?()
            self.inDismiss = false
            scrollView.scrollEnabled = true
        }
        if !inDismiss {
            if draggingDirection == .Left && pan.state == .Began {
                coordinator.dismissAnimationController.dismissDirection = .Left
                coordinator.dismissAnimationController.dismissDuration = horizontalDismissDuration
                inDismiss = true
                beginDismiss()
                scrollView.scrollEnabled = false
            } else if draggingDirection == .Right && pan.state == .Began {
                coordinator.dismissAnimationController.dismissDirection = .Right
                coordinator.dismissAnimationController.dismissDuration = horizontalDismissDuration
                inDismiss = true
                beginDismiss()
                scrollView.scrollEnabled = false
            } else if reachTheBottom && draggingDirection == .Up {
                coordinator.dismissAnimationController.dismissDirection = .Up
                coordinator.dismissAnimationController.dismissDuration = verticalDismissDuration
                inDismiss = true
                beginDismiss()
            } else if reachTheTop && draggingDirection == .Down {
                coordinator.dismissAnimationController.dismissDirection = .Down
                coordinator.dismissAnimationController.dismissDuration = verticalDismissDuration
                inDismiss = true
                beginDismiss()
            }
        }
        guard inDismiss else {
            pan.setTranslation(CGPoint.zero, inView: pan.view)
            return
        }
        switch pan.state {
        case .Changed:
            switch coordinator.dismissAnimationController.dismissDirection {
            case .Left:
                flickInteractionController.isVertical = false
                coordinator.changed?(-translation.x / pan.view!.frame.width, horizontalDismissCompletionThreshHold)
            case .Right:
                flickInteractionController.isVertical = false
                coordinator.changed?(translation.x / pan.view!.frame.width, horizontalDismissCompletionThreshHold)
            case .Up:
                flickInteractionController.isVertical = true
                coordinator.changed?(-translation.y / pan.view!.frame.height, verticalDismissCompletionThreshHold)
            case .Down:
                flickInteractionController.isVertical = true
                coordinator.changed?(translation.y / pan.view!.frame.height, verticalDismissCompletionThreshHold)
            }
        case .Ended:
            endDismiss()
        case .Cancelled:
            cancelDismiss()
        default:
            break
        }
    }
    
    public func presentViewController<T: UIViewController where T: FlickTransitionDelegate>(viewController: T, presentOriginFrame: CGRect? = nil) {
        originFrame = presentOriginFrame
        delegate = viewController
        setUsingFlickInteractiveTransition?(false)
        
        if let viewController = viewController as? UINavigationController {
            viewController.delegate = self
        }
        UIViewController.topMostViewController()?.presentViewController(viewController, animated: true, completion: nil)
    }
    
    public func dismissViewControllerNoninteractively(dismissDirection: Direction = .Right) {
        dismissAnimationController.dismissDirection = dismissDirection
        dismissAnimationController.dismissDuration = 0.2
        setUsingFlickInteractiveTransition?(false)
        dismissViewController()
    }
    
    private func dismissViewController() {
        UIViewController.topMostViewController()?.dismissViewControllerAnimated(true, completion: { [weak self] in
            if let presentingViewController = UIViewController.topMostViewController() as? FlickTransitionDelegate {
                self?.delegate = presentingViewController
            }
        })
    }
    
}

extension FlickTransitionCoordinator: UIViewControllerTransitioningDelegate {
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return presentAnimationController
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return dismissAnimationController
    }
    
    func interactionControllerForDismissal(animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return flickInteractionController.usingInteractiveTransition ? flickInteractionController : nil
    }
    
}

extension FlickTransitionCoordinator: UINavigationControllerDelegate {
    
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        if let navigationController = navigationController as? FlickTransitionDelegate {
            delegate = navigationController
        }
    }
    
}

extension FlickTransitionCoordinator: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
}