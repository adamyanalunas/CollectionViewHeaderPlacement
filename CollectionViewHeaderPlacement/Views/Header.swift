//
//  Header.swift
//  CollectionViewHeaderPlacement
//
//  Created by Adam Yanalunas on 6/20/16.
//  Copyright © 2016 Adam Yanalunas. All rights reserved.
//

import Foundation
import UIKit

class Header:UICollectionReusableView {
    static let reuseID = "Header"
    
//    @IBOutlet weak var title:UILabel!
    
    var title:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        title = UILabel(frame: frame)
    }
}