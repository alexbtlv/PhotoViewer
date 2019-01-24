//
//  MainCollectionViewController.swift
//  PhotoViewer
//
//  Created by Alexander Batalov on 1/16/19.
//  Copyright © 2019 Alexander Batalov. All rights reserved.
//

import UIKit
import MBProgressHUD

class MainCollectionViewController: UICollectionViewController {
    
    private let reuseIdentifier = "Cell"
    private let scrollOffsetToRequestAdditionalData: CGFloat = 100
    private var originFrame: CGRect = CGRect.zero
    lazy var networkManager = NetworkManager()
    private var currentPage = 1
    private var isLoadingList : Bool = false {
        didSet {
            if isLoadingList {
                MBProgressHUD.showAdded(to: view, animated: true)
            } else {
                MBProgressHUD.hide(for: view, animated: true)
            }
        }
    }
    private var photos = [Photo]()
    private var selectedPhoto: Photo?
    private var selectedIndexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        loadPhotos()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        guard let layout = collectionView.collectionViewLayout as? GreedoCollectionViewLayout else {
            return
        }
        layout.invalidateLayout()
    }

    fileprivate func configureUI() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.largeTitleDisplayMode = .automatic
        guard let layout = collectionView.collectionViewLayout as? GreedoCollectionViewLayout else {
            return
        }
        layout.dataSource = self
        layout.invalidateLayout()
    }
    
    fileprivate func loadPhotos() {
        isLoadingList = true
        DispatchQueue.global().async { [weak self] in
            guard let self = self else {
                return
            }
            self.networkManager.getPopularPhotos(page: self.currentPage) { photos, error in
                if let error = error {
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "Oops", message: error, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                        alert.addAction(okAction)
                        self.isLoadingList = false
                        self.present(alert, animated: true, completion: nil)
                    }
                }
                if let photos = photos {
                    DispatchQueue.main.async {
                        self.photos += photos
                        self.collectionView.reloadData()
                        self.isLoadingList = false
                    }
                }
            }
        }
    }
}

// MARK: UICollectionViewDataSource

extension MainCollectionViewController  {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoCollectionViewCell
        cell.photo = photos[indexPath.row]
        return cell
    }
}

// MARK: UICollectionViewDelegate

extension MainCollectionViewController {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let stb = UIStoryboard(name: "Main", bundle: Bundle.main)
        let photoDetailVC = stb.instantiateViewController(withIdentifier: "PhotoDetail") as! PhotoDetailViewController
        let attributes = collectionView.layoutAttributesForItem(at: indexPath)
        let cellRect = attributes!.frame
        originFrame = collectionView.convert(cellRect, to: view)
        selectedPhoto = photos[indexPath.row]
        selectedIndexPath = indexPath
        photoDetailVC.transitioningDelegate = self
        photoDetailVC.photo = photos[indexPath.row]
        photoDetailVC.originFrame = originFrame
        present(photoDetailVC, animated: true, completion: nil)
    }
}

// MARK: UIScrollViewDelegate

extension MainCollectionViewController {
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if ((scrollView.contentOffset.y + scrollView.frame.size.height - scrollOffsetToRequestAdditionalData) > scrollView.contentSize.height ) && !isLoadingList {
            currentPage += 1
            loadPhotos()
        }
    }
}


// MARK: UIViewControllerTransitioningDelegate

extension MainCollectionViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let photo = selectedPhoto, let indexPath = selectedIndexPath else { return nil }
        return DetailViewPresentingTransitionManager(originFrame: originFrame, photoAspectRatio: photo.aspectRatio, indexPath: indexPath)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let revealVC = dismissed as? PhotoDetailViewController else {
            return nil
        }
        return DetailViewDismissingTransitionManager(destinationFrame: originFrame, interactionController: revealVC.swipeInteractionController)
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard let animator = animator as? DetailViewDismissingTransitionManager, let interactionController = animator.interactionController, interactionController.interactionInProgress else { return nil }
        return interactionController
    }
}

extension MainCollectionViewController: GreedoCollectionViewLayoutDataSource {
    func originalImageSize(atIndexPath indexPath: IndexPath) -> CGSize? {
        return indexPath.row > photos.count - 1 ? nil : photos[indexPath.row].size
    }
}
