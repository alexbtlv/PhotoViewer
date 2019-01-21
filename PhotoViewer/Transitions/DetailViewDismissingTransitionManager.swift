//
//  DetailViewDismissingTransitionManager.swift
//  PhotoViewer
//
//  Created by Alexander Batalov on 1/21/19.
//  Copyright © 2019 Alexander Batalov. All rights reserved.
//

import UIKit

class DetailViewDismissingTransitionManager: NSObject, UIViewControllerAnimatedTransitioning {
    
    private let destinationFrame: CGRect
    
    init(destinationFrame: CGRect) {
        self.destinationFrame = destinationFrame
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from) as? PhotoDetailViewController,
            let toVC = transitionContext.viewController(forKey: .to),
            let snapshot = fromVC.view.snapshotView(afterScreenUpdates: false),
            let photoSnapshot = fromVC.imageView.snapshotView(afterScreenUpdates: false)
            else {
                return
        }
        
        let containerView = transitionContext.containerView
        photoSnapshot.frame = fromVC.imageView.frame
        containerView.insertSubview(toVC.view, at: 0)
        containerView.addSubview(snapshot)
        containerView.addSubview(photoSnapshot)
        fromVC.view.isHidden = true
        
        let duration = transitionDuration(using: transitionContext)
        
        
        UIView.animateKeyframes(withDuration: duration, delay: 0, options: .calculationModeCubic, animations: {
            
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 2/3) {
                snapshot.frame = CGRect(x: self.destinationFrame.minX, y: self.destinationFrame.midY, width: self.destinationFrame.width, height: 0)
                photoSnapshot.frame = self.destinationFrame
                snapshot.alpha = 0
            }
            
            UIView.addKeyframe(withRelativeStartTime: 2/3, relativeDuration: 1/3) {
                photoSnapshot.alpha = 0
            }
            
        }) {_ in
            fromVC.view.isHidden = false
            snapshot.removeFromSuperview()
            photoSnapshot.removeFromSuperview()
            if transitionContext.transitionWasCancelled {
                toVC.view.removeFromSuperview()
            }
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
    
}
