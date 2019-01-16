//
//  PhotoCollectionViewCell.swift
//  PhotoViewer
//
//  Created by Alexander Batalov on 1/16/19.
//  Copyright © 2019 Alexander Batalov. All rights reserved.
//

import UIKit
import Kingfisher

class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var photo: Photo! {
        didSet {
            updateUI()
        }
    }
    
    fileprivate func updateUI() {
        print(photo.thumbURL)
        imageView.kf.setImage(with: photo.thumbURL)
        imageView.kf.indicatorType = .activity
    }
}
