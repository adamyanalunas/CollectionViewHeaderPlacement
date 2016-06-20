//
//  CollectionViewController.swift
//  CollectionViewHeaderPlacement
//
//  Created by Adam Yanalunas on 6/20/16.
//  Copyright © 2016 Adam Yanalunas. All rights reserved.
//

import Foundation
import UIKit

class CollectionViewController:UICollectionViewController {
    
    let layout = FlowLayout()
    
    @IBOutlet weak var headerHackButton: UIBarButtonItem!
    @IBOutlet weak var slowAnimationButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layout.useHeaderHack = false
        collectionView?.collectionViewLayout = layout
        
        collectionView?.registerClass(Header.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: Header.reuseID)
        collectionView?.registerClass(Supplementary.self, forSupplementaryViewOfKind: Supplementary.reuseID, withReuseIdentifier: Supplementary.reuseID)
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 10
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Cell.reuseID, forIndexPath: indexPath) as! Cell
        cell.title.text = "Cell \(indexPath.item)"
        cell.layer.borderColor = UIColor.blackColor().CGColor
        cell.layer.borderWidth = 1
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionElementKindSectionHeader {
            let view = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: Header.reuseID, forIndexPath: indexPath) as! Header
            view.backgroundColor = UIColor.lightGrayColor()
            
            return view
        } else {
            return collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: Supplementary.reuseID, forIndexPath: indexPath) as! Supplementary
        }
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        toggleSupplementary(indexPath, collectionView: collectionView)
    }
    
    override func collectionView(collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, atIndexPath indexPath: NSIndexPath) {
        layout.remember(view.frame.origin, atIndexPath: indexPath)
    }
    
    // MARK: Toggle supplementary
    func toggleSupplementary(indexPath:NSIndexPath, collectionView:UICollectionView) {
        collectionView.performBatchUpdates({
            if !self.layout.selected {
                self.layout.selectedIndexPath = indexPath
                self.layout.selected = true
            } else {
                self.layout.selected = false
            }
            }, completion: { (done) in
                self.layout.invalidateLayout()
        })
    }
    
    // MARK: Bar button handles
    @IBAction func handleHackButton(button: UIBarButtonItem) {
        if layout.useHeaderHack {
            button.title = "Enable Header Hack"
            layout.useHeaderHack = false
        } else {
            button.title = "Disable Header Hack"
            layout.useHeaderHack = true
        }
    }
    
    @IBAction func handleSpeedButton(button: UIBarButtonItem) {
        let rootLayer = UIApplication.sharedApplication().keyWindow?.layer
        if rootLayer?.speed == 1 {
            button.title = "Enable Slow Animations"
            rootLayer?.speed = 0.1
        } else {
            button.title = "Disable Slow Animations"
            rootLayer?.speed = 1
        }
    }
}