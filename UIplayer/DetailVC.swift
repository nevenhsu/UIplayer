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
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.layer.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.navigationBar.layer.isHidden = true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func playVideoBtn(_ sender: Any) {
        playerVC.player = player
        
        navigationController?.pushViewController(playerVC, animated: true)
        self.player?.play()

        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player?.currentItem, queue: nil) { (notification) in
            self.player?.seek(to: kCMTimeZero)
            self.player?.play()
        }
    }
    
    @IBAction func tappedDoneBtn(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func tappedShareBtn(_ sender: UIButton) {
        var shareInfo: String
        var activityController: UIActivityViewController
        if let videoURL = item.url {
            shareInfo = "Check out this great UI animation!\n" + videoURL
        } else {
            shareInfo = "Check out this great UI animation!\n"
        }
        
        if let img = item.cover as? UIImage {
            activityController = UIActivityViewController(activityItems: [shareInfo,img], applicationActivities: nil)
        } else {
            activityController = UIActivityViewController(activityItems: [shareInfo], applicationActivities: nil)
        }
        
        self.present(activityController, animated: true, completion: nil)
    }
    
    
    func dissmissPlayerVC() {
        
    }

}
