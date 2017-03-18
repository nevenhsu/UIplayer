//
//  DetailVCBackhround.swift
//  UIplayer
//
//  Created by Neven on 02/03/2017.
//  Copyright © 2017 Neven. All rights reserved.
//

import UIKit

class DetailVCBackhround: UIView {
    @IBOutlet weak var cover: UIImageView!
    let mainVCBackground = MainVCBackground()
    let gradient = CAGradientLayer()
    
    override func draw(_ rect: CGRect) {
        mainVCBackground.setBackground()
        
        let color1 = UIColor(white: 0, alpha: 0.15).cgColor
        let color2 = UIColor(white: 0, alpha: 0).cgColor
        let color3 = UIColor(white: 0, alpha: 0).cgColor
        let color4 = UIColor(white: 0, alpha: 0.2).cgColor
        gradient.frame = cover.bounds
        gradient.colors = [color1, color2, color3, color4]
        gradient.locations = [0.0, 0.15, 0.8, 1.0]
        cover.layer.insertSublayer(gradient, at: 1)
    }


}
