//
//  SearchCollectionViewController.swift
//  PhotoViewer
//
//  Created by Alexander Batalov on 1/18/19.
//  Copyright © 2019 Alexander Batalov. All rights reserved.
//

import UIKit
import MBProgressHUD

class SearchCollectionViewController: UICollectionViewController {
    
    private let scrollOffsetToRequestAdditionalData: CGFloat = 100
    private let reuseIdentifier = "PhotoCell"
    private var originFrame: CGRect = CGRect.zero
    public var currentPage = 1
    public var currentQuery = ""
    lazy var networkManager = NetworkManager()
    public var photos = [Photo]()
    private var selectedPhoto: Photo?
    private var isLoadingList : Bool = false {
        didSet {
            if isLoadingList {
                MBProgressHUD.showAdded(to: view, animated: true)
            } else {
                MBProgressHUD.hide(for: view, animated: true)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        guard let layout = collectionView.collectionViewLayout as? GreedoCollectionViewLayout else {
            return
        }
        layout.invalidateLayout()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    fileprivate func configureUI() {
        guard let layout = collectionView.collectionViewLayout as? GreedoCollectionViewLayout else {
            return
        }
        layout.headerHeight = view.bounds.height / 3
        let headerNib = UINib(nibName: "SearchHeader", bundle: Bundle.main)
        collectionView.register(headerNib, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "Header")
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
                    DispatchQueue.main.async {
                        self.photos = []
                        self.collectionView.reloadData()
                        self.isLoadingList = false
                        let alert = UIAlertController(title: "Oops", message: error, preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                        alert.addAction(okAction)
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! PhotoCollectionViewCell
        cell.photo = photos[indexPath.row]
        return cell
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
            
        case UICollectionView.elementKindSectionHeader:
            guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "Header", for: indexPath) as? SearchCollectionHeaderView else { fatalError("Invalid view type") }
            headerView.backgroundImageView.clipsToBounds = true
            headerView.visualEffectView.layer.cornerRadius = 10
            headerView.visualEffectView.clipsToBounds = true
            headerView.searchBar.tintColor = .white
            headerView.searchBar.delegate = self
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

// MARK: UICollectionViewDelegate

extension SearchCollectionViewController {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let stb = UIStoryboard(name: "Main", bundle: Bundle.main)
        let photoDetailVC = stb.instantiateViewController(withIdentifier: "PhotoDetail") as! PhotoDetailViewController
        let attributes = collectionView.layoutAttributesForItem(at: indexPath)
        let cellRect = attributes!.frame
        originFrame = collectionView.convert(cellRect, to: view)
        selectedPhoto = photos[indexPath.row]
        photoDetailVC.transitioningDelegate = self
        photoDetailVC.photo = selectedPhoto!
        photoDetailVC.originFrame = originFrame
        present(photoDetailVC, animated: true, completion: nil)
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
        currentQuery = query
    }
}

// MARK: UIScrollViewDelegate

extension SearchCollectionViewController {
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if ((scrollView.contentOffset.y + scrollView.frame.size.height - scrollOffsetToRequestAdditionalData) > scrollView.contentSize.height ) && !isLoadingList && !photos.isEmpty {
            currentPage += 1
            searchPhotosWith(currentQuery)
        }
    }
}

// MARK: UIViewControllerTransitioningDelegate

extension SearchCollectionViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let photo = selectedPhoto else { return nil }
        return DetailViewPresentingTransitionManager(originFrame: originFrame, photoAspectRatio: photo.aspectRatio)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DetailViewDismissingTransitionManager(destinationFrame: originFrame)
    }
}
