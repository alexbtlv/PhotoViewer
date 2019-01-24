//
//  GreedoCollectionViewLayout.swift
//  PhotoViewer
//
//  Created by Alexander Batalov on 1/17/19.
//  Copyright © 2019 Alexander Batalov. All rights reserved.
//

import UIKit

public protocol GreedoCollectionViewLayoutDataSource {
    func originalImageSize(atIndexPath indexPath: IndexPath) -> CGSize?
}

public class GreedoCollectionViewLayout: UICollectionViewLayout {
    public var rowMaximumHeight: CGFloat = 50
    public var fixedHeight: Bool = false
    public var cellPadding: CGFloat = 5
    public var headerHeight: CGFloat = 0
    public var dataSource: GreedoCollectionViewLayoutDataSource!
    
    private var cache = [UICollectionViewLayoutAttributes]()
    private var greedo: GreedoSizeCalculator {
        let g = GreedoSizeCalculator()
        g.dataSource = self
        return g
    }
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
        
            var xOffset: CGFloat = 0
            var yOffset: CGFloat = headerHeight > 0 ? headerHeight + cellPadding : 0
            var rowCache = [IndexPath:(origin: CGPoint, size: CGSize)]()
            
            // cell attributes
            for item in 0..<collectionView!.numberOfItems(inSection: 0) {
                let indexPath = IndexPath(item: item, section: 0)
                guard let size = greedo.sizeForPhoto(at: indexPath) else { continue }
                
                if let nextSize = greedo.sizeForPhoto(at: IndexPath(item: indexPath.item + 1, section: indexPath.section)) {
                    if xOffset + nextSize.width < width { // keep adding photos to the row
                        let origin = CGPoint(x: xOffset, y: yOffset)
                        rowCache[indexPath] = (origin: origin, size: size)
                        
                        xOffset += size.width + cellPadding
                    } else {
                        // calculate current row attributes
                        for (i, e) in rowCache {
                            let frame = CGRect(x: e.origin.x, y: e.origin.y, width: e.size.width, height: e.size.height)
                            let attributes = UICollectionViewLayoutAttributes(forCellWith: i)
                            attributes.frame = frame
                            cache.append(attributes)
                        }
                        
                        // update row
                        rowCache.removeAll()
                        xOffset = 0
                        yOffset += size.height + cellPadding
                        height += size.height + cellPadding
                    }
                }
            }
            
            // header attributes
            if headerHeight > 0 {
                let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, with: IndexPath(item: 0, section: 0))
                attributes.frame = CGRect(x: 0, y: -150, width: width, height: headerHeight + 150)
                cache.append(attributes)
            }
            collectionView?.contentInset = UIEdgeInsets(top: 10, left: cellPadding, bottom: 50, right: cellPadding)
            if headerHeight > 0 {
                collectionView?.contentInset.bottom += 100
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

extension GreedoCollectionViewLayout: GreedoSizeCalculatorDataSource {
    var contentWidth: CGFloat {
        return width
    }
    
    var interItemSpacing: CGFloat {
        return cellPadding
    }
    
    func originalImageSize(atIndexPath indexPath: IndexPath) -> CGSize? {
        return dataSource.originalImageSize(atIndexPath: indexPath)
    }
}
