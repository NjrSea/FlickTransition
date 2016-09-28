//
//  FlickTransitionCoordinator.swift
//  FlickTransition
//
//  Created by paul on 16/9/18.
//  Copyright © 2016年 paul. All rights reserved.
//

import UIKit

public protocol FlickTransitionDelegate: class {
    
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

    func setTransitionDelegate(_ coordinator: FlickTransitionCoordinator) {
        (self as? UIViewController)?.transitioningDelegate = coordinator
    }
    
}

private let verticalDismissDuration: Double = 0.45

private let horizontalDismissDuration: Double = 0.6

private let verticalDismissCompletionThreshHold: CGFloat = 0.3

private let horizontalDismissCompletionThreshHold: CGFloat = 0.35


public final class FlickTransitionCoordinator: NSObject, FlickProgressProvider {
    
    let presentAnimationController = PresentAnimationController()
    
    let dismissAnimationController = DismissAnimationController()
    
    let flickInteractionController = FlickInteractionController()
    
    fileprivate var defaultOriginFrame: CGRect {
        let height: CGFloat = 80.0
        let width: CGFloat = UIScreen.main.bounds.size.width
        let screenHeight: CGFloat = UIScreen.main.bounds.size.height
        return CGRect(x: 0, y: (screenHeight - height) / 2.0, width: width, height: height)
    }
    
    fileprivate var panGesture: UIPanGestureRecognizer = {
        return UIPanGestureRecognizer()
    }()
    
    fileprivate var originFrame: CGRect?
    
    // MARK: FlickProgressProvider
    
    var begin: ((Void) -> Void)?
    
    var changed: ((CGFloat, CGFloat)-> Void)?
    
    var end: ((Void) -> Void)?
    
    var cancel: ((Void) -> Void)?
    
    var setUsingFlickInteractiveTransition: ((Bool) -> Void)?
    
    // MARK: Singleton
    
    public static var sharedCoordinator: FlickTransitionCoordinator {
        struct StructWrapper {
            static var instance = FlickTransitionCoordinator()
        }
        return StructWrapper.instance
    }
    
    fileprivate weak var delegate: FlickTransitionDelegate? {
        didSet {
            if let delegate = delegate {
                presentAnimationController.originFrame = originFrame ?? defaultOriginFrame
                flickInteractionController.progressProvider = self
                
                if let scrollView = delegate.scrollView() , delegate.useInteractiveDismiss() {
                    scrollView.addGestureRecognizer(panGesture)
                    scrollView.bounces = false
                    panGesture.delegate = self
                    panGesture.addTarget(self, action: #selector(pan(_:)))
                }
                delegate.setTransitionDelegate(self)
            }
        }
    }
    
    fileprivate override init() {
        
    }
    
    // MARK: Gesture
    
    fileprivate var inDismiss: Bool = false
    
    func pan(_ pan: UIPanGestureRecognizer) {
        guard let scrollView = delegate?.scrollView(),
            let interactive = delegate?.useInteractiveDismiss(),
            let shouldBegin = delegate?.shouldBeginInteractiveDismiss() , interactive && shouldBegin else {
                return
        }
        let coordinator = FlickTransitionCoordinator.sharedCoordinator
        let translation = pan.translation(in: pan.view)
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
            scrollView.isScrollEnabled = true
        }
        let cancelDismiss = {
            coordinator.cancel?()
            self.inDismiss = false
            scrollView.isScrollEnabled = true
        }
        if !inDismiss {
            if draggingDirection == .Left && pan.state == .began {
                coordinator.dismissAnimationController.dismissDirection = .Left
                coordinator.dismissAnimationController.dismissDuration = horizontalDismissDuration
                inDismiss = true
                beginDismiss()
                scrollView.isScrollEnabled = false
            } else if draggingDirection == .Right && pan.state == .began {
                coordinator.dismissAnimationController.dismissDirection = .Right
                coordinator.dismissAnimationController.dismissDuration = horizontalDismissDuration
                inDismiss = true
                beginDismiss()
                scrollView.isScrollEnabled = false
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
            pan.setTranslation(CGPoint.zero, in: pan.view)
            return
        }
        switch pan.state {
        case .changed:
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
        case .ended:
            endDismiss()
        case .cancelled:
            cancelDismiss()
        default:
            break
        }
    }
    
    public func presentViewController<T: UIViewController>(_ viewController: T, presentOriginFrame: CGRect? = nil) where T: FlickTransitionDelegate {
        originFrame = presentOriginFrame
        delegate = viewController
        setUsingFlickInteractiveTransition?(false)
        
        if let viewController = viewController as? UINavigationController {
            viewController.delegate = self
        }
        UIViewController.topMostViewController()?.present(viewController, animated: true, completion: nil)
    }
    
    public func dismissViewControllerNoninteractively(_ dismissDirection: Direction = .Right) {
        dismissAnimationController.dismissDirection = dismissDirection
        dismissAnimationController.dismissDuration = 0.2
        setUsingFlickInteractiveTransition?(false)
        dismissViewController()
    }
    
    fileprivate func dismissViewController() {
        UIViewController.topMostViewController()?.dismiss(animated: true, completion: { [weak self] in
            if let presentingViewController = UIViewController.topMostViewController() as? FlickTransitionDelegate {
                self?.delegate = presentingViewController
            }
        })
    }
    
}

extension FlickTransitionCoordinator: UIViewControllerTransitioningDelegate {
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return presentAnimationController
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return dismissAnimationController
    }
    
    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return flickInteractionController.usingInteractiveTransition ? flickInteractionController : nil
    }
    
}

extension FlickTransitionCoordinator: UINavigationControllerDelegate {
    
    public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if let navigationController = navigationController as? FlickTransitionDelegate {
            delegate = navigationController
        }
    }
    
}

extension FlickTransitionCoordinator: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
}
