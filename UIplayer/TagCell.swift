//
//  TagCell.swift
//  UIplayer
//
//  Created by Neven on 07/05/2017.
//  Copyright © 2017 Neven. All rights reserved.
//

import UIKit

class TagCell: UICollectionViewCell {
    
    

    @IBOutlet weak var tagName: UILabel!
    @IBOutlet weak var tagNameMaxWidthConstraint: NSLayoutConstraint!
    
    
    override func awakeFromNib() {
        self.tagName.textColor = UIColor.white
        self.layer.cornerRadius = 4
        
        self.tagNameMaxWidthConstraint.constant = UIScreen.main.bounds.width - 8 * 2 - 8 * 2
    }
}

