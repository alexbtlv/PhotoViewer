//
//  DetailViewPresentingTransitionManager.swift
//  PhotoViewer
//
//  Created by Alexander Batalov on 1/21/19.
//  Copyright © 2019 Alexander Batalov. All rights reserved.
//

import UIKit

class DetailViewPresentingTransitionManager: NSObject, UIViewControllerAnimatedTransitioning {

    private let originFrame: CGRect
    private let photoAspectRatio: CGFloat
    
    init(originFrame: CGRect, photoAspectRatio: CGFloat) {
        self.originFrame = originFrame
        self.photoAspectRatio = photoAspectRatio
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.75
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to) as? PhotoDetailViewController,
            let snapshot = toVC.view.snapshotView(afterScreenUpdates: true),
            let photoSnapshot = toVC.imageView.snapshotView(afterScreenUpdates: true)
            else {
                return
        }
        
        let containerView = transitionContext.containerView
        let finalFrame = transitionContext.finalFrame(for: toVC)
        snapshot.frame = originFrame
        snapshot.alpha = 0
        photoSnapshot.frame = originFrame
        photoSnapshot.alpha = 0
        
        containerView.addSubview(toVC.view)
        containerView.addSubview(snapshot)
        containerView.addSubview(photoSnapshot)
        toVC.view.isHidden = true
        
        let duration = transitionDuration(using: transitionContext)
        let newPhotoHeight = finalFrame.width / photoAspectRatio
        let finalPhotoYOffset = finalFrame.height / 2 - newPhotoHeight / 2
        let finalPhotoFrame = CGRect(x: 0, y: finalPhotoYOffset, width: finalFrame.width, height: newPhotoHeight)
        
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseInOut, animations: {
            photoSnapshot.frame = finalPhotoFrame
            photoSnapshot.alpha = 1
            snapshot.frame = finalFrame
            snapshot.alpha = 1
        }) {_ in
            toVC.view.isHidden = false
            snapshot.removeFromSuperview()
            fromVC.view.layer.transform = CATransform3DIdentity
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }

    }
}
