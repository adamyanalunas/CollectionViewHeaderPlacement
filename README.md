# UICollectionElementKindSectionHeader incorrectly animating in from origin zero

This repo contains an iOS app to showcase a bug where `UICollectionElementKindSectionHeader` instances animate in from origin `0,0` instead of their last known origin. This happens when a supplementary view pushes the cells above a header and, in turn, the header gets pushed off screen.

## About the demo

Clone or download the repo and run it in in Xcode 7, targeting iOS 9.3. Earlier versions of iOS may be susceptible but have not been tested, nor has the upcoming Xcode 8/iOS 10 combo.

All relevant logic is in [CollectionViewController](https://github.com/adamyanalunas/CollectionViewHeaderPlacement/blob/master/CollectionViewHeaderPlacement/Controllers/CollectionViewController.swift). The resize of the `UICollectionReusableView` comes from a `UICollectionViewFlowLayout` subclass that knows about the need to make room in the collection for the `UICollectionReusableView` height.

When a cell is tapped the supplementary view appears below the cell and the controller sets a new target height in the [layout](https://github.com/adamyanalunas/CollectionViewHeaderPlacement/blob/master/CollectionViewHeaderPlacement/Layouts/FlowLayout.swift) and triggers a layout animation using `performBatchUpdates` on the collection. 

## Failure case

The demo’s initial state showcases the failure state. Tapping any visible cell will present an invisible supplementary view which causes a space between the bottom of that cell and the row below. The demo sections are populated such that any time a supplementary view is shown some header will disappear off screen.

Tapping the same cell will collapse the supplementary view and you’ll see a header view start at origin `{0,0}` and animate down to its destination.

Even with the different colors the bug is a bit difficult to see so tapping “Enable Slow Animations” will allow you to see the header starting at the top left and animating down.

## Success case

Tapping the “Enable Header Hack” bar button will engage the workaround I’ve found. It’s a simple matter of [boxing the header’s last known origin point](https://github.com/adamyanalunas/CollectionViewHeaderPlacement/blob/master/CollectionViewHeaderPlacement/Controllers/CollectionViewController.swift#L63) when it disappears and using the unboxed origin when it’s [about to be redrawn](https://github.com/adamyanalunas/CollectionViewHeaderPlacement/blob/master/CollectionViewHeaderPlacement/Layouts/FlowLayout.swift#L46).

## Thanks

A sincere thanks to every Apple engineer that spent time with me in the 2016 WWDC labs to diagnose, debug, and attempt to solve this issue.
