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
    private var indexPath: IndexPath
    
    init(originFrame: CGRect, photoAspectRatio: CGFloat, indexPath: IndexPath) {
        self.originFrame = originFrame
        self.photoAspectRatio = photoAspectRatio
        self.indexPath = indexPath
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.75
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from) as? UITabBarController,
            let toVC = transitionContext.viewController(forKey: .to) as? PhotoDetailViewController,
            let snapshot = toVC.view.snapshotView(afterScreenUpdates: true),
            let navVC = fromVC.selectedViewController as? UINavigationController,
            let collectionVC = navVC.viewControllers.first as? UICollectionViewController,
            let cell = collectionVC.collectionView.cellForItem(at: indexPath),
            let photoSnapshot = cell.snapshotView(afterScreenUpdates: false)
            else {
                return
        }
        
        let containerView = transitionContext.containerView
        let finalFrame = transitionContext.finalFrame(for: toVC)
        snapshot.frame = originFrame
        snapshot.alpha = 0
        photoSnapshot.frame = originFrame
        
        containerView.addSubview(toVC.view)
        containerView.addSubview(snapshot)
        containerView.addSubview(photoSnapshot)
        toVC.view.isHidden = true
        
        let duration = transitionDuration(using: transitionContext)
        let newPhotoHeight = finalFrame.width / photoAspectRatio
        let finalPhotoYOffset = finalFrame.height / 2 - newPhotoHeight / 2
        let finalPhotoFrame = CGRect(x: 0, y: finalPhotoYOffset, width: finalFrame.width, height: newPhotoHeight)
        
        UIView.animateKeyframes(withDuration: duration, delay: 0, options: .calculationModeCubic, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1/2) {
                photoSnapshot.frame = finalPhotoFrame
                snapshot.frame = finalFrame
                snapshot.alpha = 1
            }
            UIView.addKeyframe(withRelativeStartTime: 1/2, relativeDuration: 1/2) {
                photoSnapshot.alpha = 0
            }
        }) {_ in
            toVC.view.isHidden = false
            snapshot.removeFromSuperview()
            photoSnapshot.removeFromSuperview()
            fromVC.view.layer.transform = CATransform3DIdentity
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}
