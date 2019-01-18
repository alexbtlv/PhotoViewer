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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    fileprivate func configureUI() {
        UIView.animate(withDuration: 0.5) {
            let width = self.view.bounds.width
            let height = width / self.photo.aspectRatio
            self.imageViewHeightConstraint.constant = height
            self.imageViewWidthConstraint.constant = width
            self.view.layoutIfNeeded()
        }
        imageView.kf.indicatorType = .activity
        imageView.kf.setImage(with: photo.regularURL)
        authorImageView.kf.setImage(with: photo.author.profileImageURL)
        authorLabel.text = photo.author.name
        sourceLabel.text = photo.source
    }
    
    // MARK: Action handlers
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
