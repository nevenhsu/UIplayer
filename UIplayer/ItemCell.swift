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
    @IBOutlet weak var thumbnail: UIImageView!
    var viewGradient:CAGradientLayer!
    var color1 = UIColor(white: 0, alpha: 0).cgColor
    var color2 = UIColor(white: 0, alpha: 0.5).cgColor
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewGradient = CAGradientLayer()
        viewGradient.frame = CGRect(x: 0, y: 0, width: contentView.frame.width * 2, height: contentView.frame.height)

        viewGradient.colors = [color1,color2]
        viewGradient.locations = [0.25, 1.0]
        
        thumbnail.layer.insertSublayer(viewGradient, at: 1)
    }

    func updateCell(item: Item) {
        titleLbl.text = item.title
        catagoryLbl.text = item.category
        
        if let image = item.thumbnail as? UIImage {
            thumbnail.image = image
        } else {
            thumbnail.image = UIImage(named: "placeholder")
        }
    }
}
