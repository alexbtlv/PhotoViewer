//
//  GreedoSizeCalculator.swift
//  PhotoViewer
//
//  Created by Alexander Batalov on 1/17/19.
//  Copyright © 2019 Alexander Batalov. All rights reserved.
//

import UIKit

protocol GreedoSizeCalculatorDataSource {
    var contentWidth: CGFloat { get }
    var rowMaximumHeight: CGFloat { get  }
    var fixedHeight: Bool { get }
    var interItemSpacing: CGFloat { get }
    func originalImageSize(atIndexPath indexPath: IndexPath) -> CGSize
}


class GreedoSizeCalculator: NSObject {
    public var dataSource: GreedoSizeCalculatorDataSource!
    
    private var sizeCache = [IndexPath:CGSize]()
    private var leftOvers = [CGSize]()
    private var lastIndexPathAdded: IndexPath!
    
    func sizeForPhoto(at indexPath: IndexPath) -> CGSize {
        if sizeCache[indexPath] == nil {
            lastIndexPathAdded = indexPath
            computeSize(atIndexPath: indexPath)
        }
        
        guard let size = sizeCache[indexPath] else { return CGSize.zero }
        if size.width < 0 || size.height < 0 { return CGSize.zero }
        return size
    }
    
    func clearCache() {
        self.sizeCache.removeAll()
    }
    
    func clearCache(afterIndexPath indexPath: IndexPath) {
        sizeCache.removeValue(forKey: indexPath)
        // Remove the indexPath for anything after
        for existingIndexPath in sizeCache.keys {
            if indexPath.compare(existingIndexPath) == ComparisonResult.orderedDescending {
                sizeCache.removeValue(forKey: existingIndexPath)
            }
        }
    }
    
    private func computeSize(atIndexPath indexPath: IndexPath) {
        print(dataSource.debugDescription)
        var photoSize = dataSource.originalImageSize(atIndexPath: indexPath)
        if (photoSize.width < 1 || photoSize.height < 1) {
            // Photo with no height or width
            photoSize.width  = dataSource.rowMaximumHeight;
            photoSize.height = dataSource.rowMaximumHeight;
        }
        
        leftOvers.append(photoSize)
        
        var enoughContentForTheRow = false
        var rowHeight = dataSource.rowMaximumHeight
        var widthMultiplier: CGFloat = 1.0
        
        // Calculations for variable height grid
        if dataSource.fixedHeight {
            var totalWidth: CGFloat = 0
            var index = 0
            for leftOver in leftOvers {
                var scaledWidth = ceil((rowHeight * leftOver.width) / leftOver.height)
                scaledWidth += dataSource.interItemSpacing
                
                if ((totalWidth + (scaledWidth * 0.66)) > dataSource.contentWidth) {
                    // Adding this photo would mean less than 2/3 of it would be visible
                    enoughContentForTheRow = true
                    leftOvers.remove(at: index)
                    break
                }
                
                totalWidth += scaledWidth
                enoughContentForTheRow = totalWidth > dataSource.contentWidth
                index += 1
            }
            
            if enoughContentForTheRow {
                widthMultiplier = totalWidth / dataSource.contentWidth
            }
        } else {
            var totalAspectRatio: CGFloat = 0
            
            for leftOver in leftOvers {
                totalAspectRatio += leftOver.width / leftOver.height
            }
            
            rowHeight = dataSource.contentWidth / totalAspectRatio
            enoughContentForTheRow = rowHeight < dataSource.rowMaximumHeight
        }
        
        if enoughContentForTheRow {
            // The line is full!
            var availableSpace: CGFloat = dataSource.contentWidth
            var index = 1
            
            for leftOver in leftOvers {
                var newWidth:CGFloat = floor((rowHeight * leftOver.width) / leftOver.height)
                
                if dataSource.fixedHeight {
                    if index == leftOvers.count - 1 {
                        newWidth = availableSpace
                    } else {
                        newWidth = floor(newWidth * widthMultiplier)
                    }
                } else {
                    newWidth = min(availableSpace, newWidth)
                }
                
                // Add the size in the cache
                sizeCache[lastIndexPathAdded] = CGSize(width: newWidth, height: rowHeight)
                
                availableSpace -= newWidth
                availableSpace -= dataSource.interItemSpacing
                
                // We need to keep track of the last index path added
                lastIndexPathAdded = IndexPath(item: lastIndexPathAdded.item + 1, section: lastIndexPathAdded.section)
                index += 1
            }
            leftOvers.removeAll()
        } else {
            // The line is not full, let's ask the next photo and try to fill up the line
            let newIndexPath = IndexPath(item: indexPath.item + 1, section: indexPath.section)
            let _ = computeSize(atIndexPath: newIndexPath)
        }
    }
}
