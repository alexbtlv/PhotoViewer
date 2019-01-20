//
//  GreedoCollectionViewLayout.swift
//  PhotoViewer
//
//  Created by Alexander Batalov on 1/17/19.
//  Copyright © 2019 Alexander Batalov. All rights reserved.
//

import UIKit

public class GreedoCollectionViewLayout: UICollectionViewLayout {

    public var rowMaximumHeight: CGFloat = 50
    public var fixedHeight: Bool = true
    public var cellPadding: CGFloat = 5
    public var headerHeight: CGFloat = 0
    
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
            rowMaximumHeight = collectionView!.bounds.height / 5
            height = 10 + 10 + headerHeight
            
            var xOffsets: [CGFloat] = []
            var yOffset: CGFloat = headerHeight > 0 ? headerHeight + cellPadding : 0
            let columnWidth = width / 2.0
            var col = 0
            for col in 0..<2 {
                let offset = col == 0 ? cellPadding : 0
                xOffsets.append((CGFloat(col) * columnWidth) + offset)
            }
        
            // cell attributes
            for item in 0..<collectionView!.numberOfItems(inSection: 0) {
                let indexPath = IndexPath(item: item, section: 0)
                let rowHeight = rowMaximumHeight
                let width = columnWidth - cellPadding - cellPadding / 2
                var xOffset = xOffsets[col]
                if col > 0 {
                    xOffset += cellPadding / 2
                }
                let frame = CGRect(x: xOffset, y: yOffset, width: width, height: rowHeight)
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
            
            // header attributes
            if headerHeight > 0 {
                let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, with: IndexPath(item: 0, section: 0))
                attributes.frame = CGRect(x: 0, y: -150, width: width, height: headerHeight + 150)
                cache.append(attributes)
            }
            collectionView?.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 50, right: 0)
            if headerHeight > 0 {
                collectionView?.contentInset.bottom += 50
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
    
    public override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        for attributes in cache {
            if attributes.representedElementKind == elementKind {
                return attributes
            }
        }
        return nil
    }
    
    public override func invalidateLayout() {
        super.invalidateLayout()
        cache = []
    }
}
