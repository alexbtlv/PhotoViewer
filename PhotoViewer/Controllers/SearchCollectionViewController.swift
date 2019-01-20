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
    private var isLoadingList : Bool = false
    private var currentPage = 1
    lazy var networkManager = NetworkManager()
    public var photos = [Photo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        self.navigationController?.setNavigationBarHidden(true, animated: animated)
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        self.navigationController?.setNavigationBarHidden(false, animated: animated)
//    }
    
    fileprivate func configureUI() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.largeTitleDisplayMode = .automatic
        let singleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.singleTap(sender:)))
        singleTapGestureRecognizer.numberOfTapsRequired = 1
        singleTapGestureRecognizer.isEnabled = true
        singleTapGestureRecognizer.cancelsTouchesInView = false
        self.view.addGestureRecognizer(singleTapGestureRecognizer)
    }
    
    // MARK: Action handlers
    
    @objc func singleTap(sender: UITapGestureRecognizer) {
        resetSearchBar()
    }
    
    fileprivate func resetSearchBar() {
        guard let header = collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: IndexPath(row: 0, section: 0)) as? SearchCollectionHeaderView else { return }
        header.searchBar.text = ""
        header.searchBar.resignFirstResponder()
    }
    
    fileprivate func searchPhotosWith(_ query: String) {
        isLoadingList = true
        DispatchQueue.global().async { [weak self] in
            guard let self = self else {
                return
            }
            self.networkManager.searchForPhotos(withQuery: query, page: self.currentPage, completion: { (photos, error) in
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
            })
        }
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
        cell.backgroundColor = .white
        return cell
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
            
        case UICollectionView.elementKindSectionHeader:
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath) as? SearchCollectionHeaderView else { fatalError("Invalid view type") }
            let backgrounds: [String: String] = [
                "1":"Photo by Ishan @seefromthesky on Unsplash",
                "2":"Photo by Adam Azim on Unsplash",
                "3":"Photo by Sebastian Pena Lambarri on Unsplash"
            ]
            let element = backgrounds.randomElement()!
            headerView.backgroundImageView.image = UIImage(named: element.key)
            headerView.authorLabel.text = element.value
            headerView.visualEffectView.layer.cornerRadius = 10
            headerView.visualEffectView.clipsToBounds = true
            headerView.searchBar.tintColor = .white
            UITextField.appearance(whenContainedInInstancesOf: [type(of: headerView.searchBar)]).tintColor = .white
            if let textfield = headerView.searchBar.value(forKey: "searchField") as? UITextField {
                textfield.backgroundColor = .white
                textfield.attributedPlaceholder = NSAttributedString(string: textfield.placeholder ?? "", attributes: [NSAttributedString.Key.foregroundColor : UIColor.white])
                textfield.textColor = .white
                
                if let leftView = textfield.leftView as? UIImageView {
                    leftView.image = leftView.image?.withRenderingMode(.alwaysTemplate)
                    leftView.tintColor = .white
                }
            }
            return headerView
        default:
            assert(false, "Unexpected element kind")
        }
    }
}

// MARK: UICollectionViewDelegateFlowLayout

extension SearchCollectionViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: view.bounds.width, height: view.bounds.height / 3)
    }
}

// MARK: UISearchBarDelegate

extension SearchCollectionViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let query = searchBar.text, !query.isEmpty else {
            let alert = UIAlertController(title: "Oops", message: "Please enter search term", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
            return
        }
        photos = []
        searchPhotosWith(query)
        resetSearchBar()
    }
}
