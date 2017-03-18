//
//  SegueFromRight.swift
//  UIplayer
//
//  Created by Neven on 16/03/2017.
//  Copyright © 2017 Neven. All rights reserved.
//

import UIKit

class SegueFromRight: UIStoryboardSegue {
    override func perform()
    {
        let src = self.source
        let dst = self.destination
        
        src.view.superview?.insertSubview(dst.view, aboveSubview: src.view)
        dst.view.frame = src.view.frame
        dst.view.transform = CGAffineTransform(translationX: src.view.frame.size.width, y: 0)
        src.navigationController?.navigationBar.alpha = 1
        
        UIView.animate(withDuration: 0.25,
                        delay: 0.0,
                        options: .curveEaseInOut,
                        animations: {
                            dst.view.transform = CGAffineTransform(translationX: 0, y: 0)
                            src.navigationController?.navigationBar.alpha = 0
        },
                        completion: { finished in
                            src.present(dst, animated: false, completion: nil)
        }
        )
    }
    
}
