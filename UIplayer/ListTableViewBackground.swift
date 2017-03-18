//
//  ListTableViewBackground.swift
//  UIplayer
//
//  Created by Neven Hsu on 01/03/2017.
//  Copyright © 2017 Neven. All rights reserved.
//

import UIKit

class ListTableViewBackground: UITableView {

    let mainVC = MainVCBackground()
    override func draw(_ rect: CGRect) {
        mainVC.setBackground()
    }
}
