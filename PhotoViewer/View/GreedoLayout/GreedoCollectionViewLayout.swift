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
    public var cellPadding: CGFloat = 5
    
    private var cache = [UICollectionViewLayoutAttributes]()
    private var height: CGFloat = 0
    private var width: CGFloat {
        let insets = collectionView!.contentInset
        return self.collectionView!.bounds.size.width - (insets.left + insets.right)
    }
    
    public override var collectionViewContentSize: CGSize {
        return CGSize(width: width, height: height)
    }
    
    public override func prepare() {
        if cache.isEmpty {
            rowMaximumHeight = collectionView!.bounds.height / 4
            height = 30 + 10
            var xOffsets: [CGFloat] = []
            var yOffset: CGFloat = 0
            let columnWidth = width / 2.0
            var col = 0
            
            for col in 0..<2 {
                xOffsets.append(CGFloat(col) * columnWidth)
            }
            
            for item in 0..<collectionView!.numberOfItems(inSection: 0) {
                let indexPath = IndexPath(item: item, section: 0)
                let rowHeight = rowMaximumHeight
                let width = columnWidth - (cellPadding * 2)
                let frame = CGRect(x: xOffsets[col], y: yOffset, width: width, height: rowHeight)
                let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                attributes.frame = frame
                cache.append(attributes)
                if col >= 1 {
                    col = 0
                    yOffset += rowHeight + cellPadding
                    height += rowHeight
                } else {
                    col += 1
                }
                
            }
            collectionView?.contentInset = UIEdgeInsets(top: 30, left: cellPadding, bottom: 10, right: cellPadding)
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
    
    public override func invalidateLayout() {
        super.invalidateLayout()
        cache = []
    }
}
