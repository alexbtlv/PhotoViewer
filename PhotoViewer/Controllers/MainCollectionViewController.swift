//
//  MainCollectionViewController.swift
//  PhotoViewer
//
//  Created by Alexander Batalov on 1/16/19.
//  Copyright © 2019 Alexander Batalov. All rights reserved.
//

import UIKit

class MainCollectionViewController: UICollectionViewController {
    
    private let reuseIdentifier = "Cell"
    private let scrollOffsetToRequestAdditionalData: CGFloat = 150.0
    
    lazy var networkManager = NetworkManager()
    private var currentPage = 1
    private var isLoadingList : Bool = false
    private var photos = [Photo]()
    
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
        
    }
    
    fileprivate func loadPhotos() {
        isLoadingList = true
        DispatchQueue.global().async { [weak self] in
            guard let self = self else {
                return
            }
            self.networkManager.getPopularPhotos(page: self.currentPage) { photos, error in
                if let error = error {
                    print(error)
                    self.isLoadingList = false
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
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
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
        photoDetailVC.photo = photos[indexPath.row]
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
