//
//  GradientView.swift
//  PhotoViewer
//
//  Created by Alexander Batalov on 1/20/19.
//  Copyright © 2019 Alexander Batalov. All rights reserved.
//

import UIKit

class GradientView: UIView {

    override open class var layerClass: AnyClass {
        return CAGradientLayer.classForCoder()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let gradientLayer = layer as! CAGradientLayer
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
    }

}
