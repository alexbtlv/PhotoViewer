//
//  GreedoCollectionViewLayout.swift
//  PhotoViewer
//
//  Created by Alexander Batalov on 1/17/19.
//  Copyright © 2019 Alexander Batalov. All rights reserved.
//

import UIKit

protocol GreedoLayoutDelegate  {
    func collectionView(_ collectionView: UICollectionView, widthForItemAtIndexPath indexPath: IndexPath) -> CGFloat
}

public class GreedoCollectionViewLayout: UICollectionViewLayout {

    public var rowMaximumHeight: CGFloat = 50
    public var fixedHeight: Bool = true
    
    private var cache = [UICollectionViewLayoutAttributes]()
    private var width: CGFloat {
        return self.collectionView!.bounds.size.width
    }
    
    public override var collectionViewContentSize: CGSize {
        return CGSize(width: width, height: 800)
    }
    
    public override func prepare() {
        if cache.isEmpty {
            var xOffsets: [CGFloat] = []
            var yOffset: CGFloat = 30.0
            let columnWidth = width / 2.0
            var col = 0
            
            for col in 0..<2 {
                xOffsets.append(CGFloat(col) * columnWidth)
            }
            
            for item in 0..<collectionView!.numberOfItems(inSection: 0) {
                let indexPath = IndexPath(item: item, section: 0)
                let height = rowMaximumHeight
                let frame = CGRect(x: xOffsets[col], y: yOffset, width: columnWidth, height: height)
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = frame
                cache.append(attributes)
                if col >= 1 {
                    col = 0
                    yOffset += height
                } else {
                    col += 1
                }
            }
        }
    }
    
    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var layoutAttributes = [UICollectionViewLayoutAttributes]()
        for attributes in cache {
            if rect.intersects(attributes.frame) {
                layoutAttributes.append(attributes)
            }
        }
        return layoutAttributes
    }
}
