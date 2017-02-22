//
//  detailVC.swift
//  UIplayer
//
//  Created by Neven Hsu on 18/02/2017.
//  Copyright © 2017 Neven. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class DetailVC: UIViewController,AVPlayerViewControllerDelegate {
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var infoLbl: UILabel!
    @IBOutlet weak var cover: UIImageView!
    private var _item: Item!
    var playerVC: AVPlayerViewController!
    var player: AVPlayer?
    
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
        playerVC = AVPlayerViewController()
        playerVC.delegate = self
        
        if let url = item.url {
            let videoUrl = URL(string: url)
            player = AVPlayer(url: videoUrl!)
        }

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
    
    @IBAction func playVideoBtn(_ sender: Any) {
        playerVC.player = player
        self.present(playerVC, animated: true) { 
            self.player?.play()
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player?.currentItem, queue: nil) { (notification) in
            self.player?.seek(to: kCMTimeZero)
            self.player?.play()
        }
    }

    @IBAction func tappedDoneBtn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }



}
