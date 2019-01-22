//
//  PhotoDetailViewController.swift
//  PhotoViewer
//
//  Created by Alexander Batalov on 1/18/19.
//  Copyright © 2019 Alexander Batalov. All rights reserved.
//

import UIKit
import Kingfisher

class PhotoDetailViewController: UIViewController {

    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var sourceLabel: UILabel!
    @IBOutlet weak var authorImageView: UIImageView!
    
    var photo: Photo!
    var originFrame: CGRect!
    var swipeInteractionController: SwipeInteractionController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        swipeInteractionController = SwipeInteractionController(viewController: self)
        configureUI()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    fileprivate func configureUI() {
        let width = self.view.bounds.width
        let height = width / self.photo.aspectRatio
        self.imageViewHeightConstraint.constant = height
        self.imageViewWidthConstraint.constant = width
        self.view.layoutIfNeeded()
        imageView.kf.indicatorType = .activity
        ImageCache.default.retrieveImage(forKey: photo.thumbURL.absoluteString) { result in
            switch result {
            case .success(let thumb):
                self.imageView.kf.setImage(with: self.photo.regularURL, placeholder: thumb.image)
            case .failure(let error):
                print(error)
                self.imageView.backgroundColor = .white
                self.imageView.kf.setImage(with: self.photo.regularURL)
            }
        }
        authorImageView.kf.setImage(with: photo.author.profileImageURL)
        authorLabel.text = photo.author.name
        sourceLabel.text = photo.source
    }
    
    // MARK: Action handlers
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
