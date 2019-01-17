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
    lazy var networkManager = NetworkManager()
    var currentPage = 1
    var isLoadingList : Bool = false
    var photos = [Photo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        loadPhotos()
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
                        self.photos = photos
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
