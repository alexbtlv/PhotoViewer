//
//  GreedoSizeCalculator.swift
//  PhotoViewer
//
//  Created by Alexander Batalov on 1/17/19.
//  Copyright © 2019 Alexander Batalov. All rights reserved.
//

import UIKit

struct GreedoSizeCalculator {
    private var sizeCache = [IndexPath:CGFloat]()
    private var leftOvers = [CGSize]()
    private var lastIndexPathAdded: IndexPath!
}
