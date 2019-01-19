//
//  SearchCollectionViewController.swift
//  PhotoViewer
//
//  Created by Alexander Batalov on 1/18/19.
//  Copyright © 2019 Alexander Batalov. All rights reserved.
//

import UIKit

class SearchCollectionViewController: UICollectionViewController {

    private let reuseIdentifier = "PhotoCell"
    
    public var photos = [Photo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    fileprivate func configureUI() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.largeTitleDisplayMode = .automatic
    }

}

// MARK: UICollectionViewDataSource

extension SearchCollectionViewController {
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        return cell
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
            
        case UICollectionView.elementKindSectionHeader:
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath as IndexPath) as? SearchCollectionHeaderView else { fatalError("Invalid view type") }
            let backgrounds: [String: String] = [
                "1":"Photo by Ishan @seefromthesky on Unsplash",
                "2":"Photo by Adam Azim on Unsplash",
                "3":"Photo by Sebastian Pena Lambarri on Unsplash"
            ]
            let element = backgrounds.randomElement()!
            headerView.backgroundImageView.image = UIImage(named: element.key)
            headerView.authorLabel.text = element.value
            return headerView
        default:
            assert(false, "Unexpected element kind")
        }
    }
}


extension SearchCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.bounds.width, height: view.bounds.height / 3)
    }
}
