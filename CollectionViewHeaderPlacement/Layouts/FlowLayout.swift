//
//  FlowLayout.swift
//  CollectionViewHeaderPlacement
//
//  Created by Adam Yanalunas on 6/20/16.
//  Copyright © 2016 Adam Yanalunas. All rights reserved.
//

import Foundation
import UIKit

protocol RestorableHeaders {
    func remember(point:CGPoint, atIndexPath indexPath:NSIndexPath)
    func restore(indexPath:NSIndexPath, inAttributes attributes:UICollectionViewLayoutAttributes)
}

class FlowLayout:UICollectionViewFlowLayout {
    private var forgottenHeaders = [NSIndexPath:NSValue]()
    private var selectedTopOffset:CGFloat = 0
    
    var detailHeight:CGFloat = 300
    var selected:Bool = false
    var selectedIndexPath = NSIndexPath(forItem: 0, inSection: 0)
    var useHeaderHack = true
    
    override init() {
        super.init()
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        sectionInset = UIEdgeInsetsMake(20, 20, 20, 20)
        itemSize = CGSizeMake(140, 140)
        headerReferenceSize = CGSizeMake(100, 40)
    }
    
    override func initialLayoutAttributesForAppearingSupplementaryElementOfKind(elementKind: String, atIndexPath elementIndexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = super.initialLayoutAttributesForAppearingSupplementaryElementOfKind(elementKind, atIndexPath: elementIndexPath)
        
        if useHeaderHack && attributes != nil {
            restore(elementIndexPath, inAttributes: attributes!)
        }
        
        return attributes
    }
    
    
    // MARK: Boilerplate
    func selectionLayoutAttributes(layoutAttributes:UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let isSelectedPath = layoutAttributes.indexPath.compare(selectedIndexPath) == .OrderedSame
        let isAfterSelected = layoutAttributes.indexPath.compare(selectedIndexPath) == .OrderedDescending
        let isCellType = layoutAttributes.representedElementCategory == .Cell;
        let isDifferentRow = CGRectGetMinY(layoutAttributes.frame) > selectedTopOffset;
        let shouldPushDown = isAfterSelected && isDifferentRow;
        
        let layoutAttributesCopy = layoutAttributes.copy() as! UICollectionViewLayoutAttributes
        
        if selected && isSelectedPath && isCellType
        {
            selectedTopOffset = CGRectGetMinY(layoutAttributes.frame);
            var frame = layoutAttributes.frame;
            frame.size.height += detailHeight;
            layoutAttributesCopy.frame = frame;
        }
        else if selected && shouldPushDown
        {
            var frame = layoutAttributes.frame;
            frame.origin.y += detailHeight;
            layoutAttributesCopy.frame = frame;
        }
        
        return layoutAttributesCopy;
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let allAttributes = super.layoutAttributesForElementsInRect(rect) else { return nil }
        var attributes = [UICollectionViewLayoutAttributes]()
        attributes = allAttributes.map {
            selectionLayoutAttributes($0)
        }
        
        if selected {
            if let suppAttributes = layoutAttributesForSupplementaryViewOfKind(Supplementary.reuseID, atIndexPath: selectedIndexPath) {
                attributes.append(suppAttributes)
            }
        }
        
        return attributes
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        guard let attributes = super.layoutAttributesForItemAtIndexPath(indexPath) else { return nil }
        return selectionLayoutAttributes(attributes)
    }
    
    override func layoutAttributesForSupplementaryViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: elementKind, withIndexPath: indexPath)
        if elementKind == Supplementary.reuseID {
            if let cellAttributes = self.layoutAttributesForItemAtIndexPath(indexPath), let collectionView = collectionView {
                var frame = cellAttributes.frame
                let spaceFromCellTop = itemSize.height
                
                frame.origin.x = 0 - collectionView.contentInset.left;
                frame.origin.y += spaceFromCellTop;
                frame.size.height = detailHeight;
                frame.size.width = CGRectGetWidth(collectionView.frame);
                
                attributes.frame = frame;
            }
        }
        
        return attributes
    }
    
    override func collectionViewContentSize() -> CGSize {
        var size = super.collectionViewContentSize()
        if selected {
            size.height += detailHeight
        }
        
        return size
    }
    
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        guard let collectionView = collectionView else { return false }
        return !CGRectEqualToRect(newBounds, collectionView.frame)
    }
}

extension FlowLayout: RestorableHeaders {
    func remember(point:CGPoint, atIndexPath indexPath:NSIndexPath) {
        if useHeaderHack {
            forgottenHeaders[indexPath] = NSValue(CGPoint: point)
        }
    }
    
    func restore(indexPath:NSIndexPath, inAttributes attributes:UICollectionViewLayoutAttributes) {
        if let point = forgottenHeaders[indexPath]?.CGPointValue() {
            var frame = attributes.frame
            frame.origin = point
            attributes.frame = frame
            forgottenHeaders.removeValueForKey(indexPath)
        }
    }
}
