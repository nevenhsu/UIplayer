////
////  DissmissAnimationRight.swift
////  UIplayer
////
////  Created by Neven on 17/03/2017.
////  Copyright © 2017 Neven. All rights reserved.
////
//
//import UIKit
//
//class DismissTransition: NSObject, UIViewControllerAnimatedTransitioning {
//
//    var reverse: Bool = false
//    
//    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
//        return 0.25
//    }
//    
//    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
//        
//        let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!
//        let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!
//        let finalFrameForVC = transitionContext.finalFrame(for: toVC)
//        let containerView = transitionContext.containerView
//        let direction: CGFloat = reverse ? -1 : 1
//        
//        let snapshotView = fromVC.view.snapshotView(afterScreenUpdates: false)!
//        snapshotView.frame = fromVC.view.frame
//        containerView.addSubview(snapshotView)
//        fromVC.view.alpha = 0
//        
//        if direction == 1 {
//            
//        } else {
//            snapshotView.transform = CGAffineTransform(translationX: 0, y: 0)
//        }
//        
//        
//        toVC.view.frame = finalFrameForVC
//        toVC.view.alpha = 0.5
//        toVC.navigationController?.navigationBar.alpha = 0.5
//        containerView.addSubview(toVC.view)
//        containerView.sendSubview(toBack: toVC.view)
//        
//        UIView.animate(withDuration: 0.25,
//                       delay: 0.0,
//                       options: .curveEaseInOut,
//                       animations: {
//            snapshotView.transform = CGAffineTransform(translationX: fromVC.view.frame.size.width, y: 0)
//                            toVC.view.alpha = 1.0
//                            toVC.navigationController?.navigationBar.alpha = 1
//        }, completion: {
//            finished in
//            snapshotView.removeFromSuperview()
//            transitionContext.completeTransition(true)
//            
//        })
//    }
//}
