//
//  detailVC.swift
//  UIplayer
//
//  Created by Neven Hsu on 18/02/2017.
//  Copyright © 2017 Neven. All rights reserved.
//

import UIKit

class DetailVC: UIViewController {
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var infoLbl: UILabel!
    @IBOutlet weak var cover: UIImageView!
    private var _item: Item!
    
    var item: Item {
        get {
            return _item
        }
        set {
            _item = newValue
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let title = item.title {
            titleLbl.text = title
        }

        if let info = item.info {
            infoLbl.text = info
        }
        
        if let coverImg = item.cover as? UIImage {
            cover.image = coverImg
        }

    }

    @IBAction func tappedDoneBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }



}
