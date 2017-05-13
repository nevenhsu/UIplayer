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
import Social

class DetailVC: UIViewController,AVPlayerViewControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var infoLbl: UILabel!
    @IBOutlet weak var cover: UIImageView!
    @IBOutlet weak var tagsCollectionView: UICollectionView!
    @IBOutlet weak var flowLayout: FlowLayout!
    @IBOutlet weak var playBtn: UIButton!
    
    var tags = [String]()
    
    private var _item: Item!
    var sizingCell: TagCell?
    var observer:Any!
    var videoLayer :AVPlayerLayer!
    var playerVC: AVPlayerViewController!
    var player: AVPlayer?
    var _videoUrl: URL!
    var item: Item {
        get {
            if _item != nil {
                return _item
            } else {
                return Item()
            }
        }
        set {
            _item = newValue
        }
    }
    
    var videoUrl: URL! {
        get {
            if _videoUrl != nil {
                return _videoUrl
            } else {
                return URL(fileURLWithPath: "")
            }
        }
        
        set {
            _videoUrl = newValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let tagsData = item.tags {
            for tag in tagsData.allObjects {
                if let tag = (tag as! Tag).name {
                    tags.append(tag)
                }
                
            }
        }
        
        playBtn.isHidden = false
        
        let cellNib = UINib(nibName: "TagCell", bundle: nil)
        self.tagsCollectionView.register(cellNib, forCellWithReuseIdentifier: "TagCell")
        self.tagsCollectionView.backgroundColor = UIColor.clear
        self.sizingCell = (cellNib.instantiate(withOwner: nil, options: nil) as NSArray).firstObject as! TagCell?
        self.flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 8)
        
        playerVC = AVPlayerViewController()
        playerVC.delegate = self
        tagsCollectionView.delegate = self
        tagsCollectionView.dataSource = self
        
        if let url = item.url {
            videoUrl = URL(string: url)
            player = AVPlayer(url: videoUrl!)
            videoLayer = AVPlayerLayer(player: player)
            videoLayer.frame = self.view.bounds
            videoLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            self.cover.layer.addSublayer(videoLayer)
            self.player?.play()
        }
        
        observer = self.player?.addPeriodicTimeObserver(forInterval: CMTimeMake(1, 600), queue: DispatchQueue.main) {
            [weak self] time in
            if self?.player?.currentItem?.status == AVPlayerItemStatus.readyToPlay && self?.player?.currentItem?.isPlaybackLikelyToKeepUp != nil {
                self?.playBtn.isHidden = true
                self?.replay(player: self?.player, item: self?.player?.currentItem)
            }
        }
        
        if let title = item.title {
            titleLbl.text = title
        } else {
            titleLbl.text = "Error, please try again."
        }

        if let info = item.info {
            infoLbl.text = info
        } else {
            infoLbl.text = ""
        }
        
        if let coverImg = item.cover as? UIImage {
            cover.image = coverImg
        } else {
            cover.image = UIImage(named: "background")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.layer.isHidden = true
        navigationItem.hidesBackButton = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.navigationBar.layer.isHidden = true
        self.player?.pause()
        self.player?.play()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.navigationBar.barTintColor = UIColor(red: 41/255, green: 21/255, blue: 74/255, alpha: 1)
        navigationItem.hidesBackButton = true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @IBAction func playVideoBtn(_ sender: Any) {
        let player2 = AVPlayer(url: videoUrl)
        playerVC.player = player2
        
        navigationController?.present(playerVC, animated: true, completion: {
            player2.play()
            self.replay(player: player2, item: player2.currentItem)
        })
    }
    
    func replay(player: AVPlayer?,item: AVPlayerItem?) {
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: item, queue: nil) { [weak player = player] notification in
            player?.seek(to: kCMTimeZero)
            player?.play()
        }
    }
    
    @IBAction func tappedDoneBtn(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func tappedShareBtn(_ sender: UIButton) {
        let shareInfo = self.item.url != nil ? "\(self.titleLbl.text!)\n\(self.infoLbl.text!)\n\n\(self.item.url!)\n\nfrom Motion UI iOS App" : "\(self.titleLbl.text!)\n\(self.infoLbl.text!)\n\nfrom Motion UI iOS App\n\n"
        
        let actionSheet = UIAlertController(title: "", message: "Share this cool motion", preferredStyle: UIAlertControllerStyle.actionSheet)
        
        let tweetAction = UIAlertAction(title: "Share on Twitter", style: UIAlertActionStyle.default) { (action) -> Void in
            if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter) {
                if let twitterComposeVC = SLComposeViewController(forServiceType: SLServiceTypeTwitter) {
                    
                    twitterComposeVC.setInitialText(shareInfo)
                    
                    if let img = self.cover.image {
                        twitterComposeVC.add(img)
                    }
                    
                    self.present(twitterComposeVC, animated: true, completion: nil)
                }
            }
            else {
                self.showAlertMessage(message: "You are not logged in to your Twitter account.")
            }
        }
        
        
        let facebookPostAction = UIAlertAction(title: "Share on Facebook", style: UIAlertActionStyle.default) { (action) -> Void in
            if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook) {
                if let facebookComposeVC = SLComposeViewController(forServiceType: SLServiceTypeFacebook) {
                    facebookComposeVC.setInitialText(shareInfo)
                    
                    if let img = self.cover.image {
                        facebookComposeVC.add(img)
                    }
                    
                    self.present(facebookComposeVC, animated: true, completion: nil)
                }
            }
            else {
                self.showAlertMessage(message: "You are not connected to your Facebook account.")
            }
        }
        
        // 設定顯示 UIActivityViewController 的新動作
        let moreAction = UIAlertAction(title: "More", style: UIAlertActionStyle.default) { (action) -> Void in
            var activityController: UIActivityViewController
        
            if let img = self.cover.image {
                activityController = UIActivityViewController(activityItems: [img,shareInfo], applicationActivities: nil)
            } else {
                activityController = UIActivityViewController(activityItems: [shareInfo], applicationActivities: nil)
            }
    
            activityController.excludedActivityTypes = [UIActivityType.print, UIActivityType.copyToPasteboard, UIActivityType.addToReadingList, UIActivityType.postToVimeo, UIActivityType.postToFacebook, UIActivityType.postToTwitter]
    
            activityController.popoverPresentationController?.sourceView = self.view
            self.present(activityController, animated: true, completion: nil)
        }
        
        
        let dismissAction = UIAlertAction(title: "Close", style: UIAlertActionStyle.cancel) { (action) -> Void in
            
        }
        
        actionSheet.addAction(facebookPostAction)
        actionSheet.addAction(tweetAction)
        actionSheet.addAction(moreAction)
        actionSheet.addAction(dismissAction)
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    
    func showAlertMessage(message: String!) {
        let alertController = UIAlertController(title: "Oops!", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tags.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TagCell", for: indexPath) as! TagCell
        self.configureCell(cell: cell, forIndexPath: indexPath)
        cell.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        return cell
    }
    
    func configureCell(cell: TagCell, forIndexPath indexPath: IndexPath) {
        let tag = tags[indexPath.row]
        cell.tagName.text = "#\(tag)"
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if let cell = self.sizingCell {
            self.configureCell(cell: cell, forIndexPath: indexPath)
            return cell.systemLayoutSizeFitting(UILayoutFittingCompressedSize)
        } else {
            return CGSize(width: 0, height: 0)
        }
    }


}
