//
//  ItemCell.swift
//  UIplayer
//
//  Created by Neven on 16/02/2017.
//  Copyright © 2017 Neven. All rights reserved.
//

import UIKit

class ItemCell: UITableViewCell {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var catagoryLbl: UILabel!
    @IBOutlet weak var coverImg: UIImageView!

    func updateCell(item: Item) {
        
        titleLbl.text = item.title
        catagoryLbl.text = item.category
        coverImg.image = item.cover as? UIImage
        
    }
    
    
    

}
