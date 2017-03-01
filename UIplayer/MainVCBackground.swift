//
//  MainVCBackground.swift
//  UIplayer
//
//  Created by Neven Hsu on 01/03/2017.
//  Copyright © 2017 Neven. All rights reserved.
//

import UIKit

class MainVCBackground: UITableView {

    override func draw(_ rect: CGRect) {
            
        //// Color Declarations
        let color1 = UIColor(red: 58/255, green: 170/255, blue: 210/255, alpha: 1.0).cgColor
        let color2 = UIColor(red: 222/255, green: 233/255, blue: 239/255, alpha: 1.0).cgColor
        let color3 = UIColor(red: 251/255, green: 224/255, blue: 217/255, alpha: 1.0).cgColor
        let context = UIGraphicsGetCurrentContext()
        
        //// Gradient Declarations
        let backgroundGradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: [color1, color2, color3] as CFArray, locations: [0.0, 0.7, 1.0])
        let mainScreen = UIScreen.main
        let width = mainScreen.bounds.size.width
        let height = mainScreen.bounds.size.height
        
        //// Background Drawing
        let backgroundPath = UIBezierPath(rect: CGRect(x: 0.0, y: -64.0, width: width, height: height + 20))
        context?.saveGState()
        backgroundPath.addClip()
        context?.drawLinearGradient(backgroundGradient!,
                                    start: CGPoint(x: 160, y: 0),
                                    end: CGPoint(x: 160, y: height - 64),
                                    options: [.drawsBeforeStartLocation, .drawsAfterEndLocation])
        context?.restoreGState()
    }
}
