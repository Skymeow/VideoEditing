//
//  BMVideoFeedViewModel .swift
//  ProjectBM
//
//  Created by Sky Xu on 4/9/18.
//  Copyright © 2018 JHK_Development. All rights reserved.
//

import Foundation
import AVFoundation

class BMVideoFeedViewModel {
    
    public var contentURL: URL? = nil{
        didSet{
            if let url = contentURL{
                asset = AVURLAsset(url: url, options: nil)
            }
        }
    }
    
    var asset: AVURLAsset? {
        didSet{
            if let newAsset = asset{
                playerItem = AVPlayerItem(asset: newAsset)
            }
        }
    }
    
    private var playerItem: AVPlayerItem? {
        didSet {
            player.replaceCurrentItem(with: self.playerItem)
            NotificationCenter.default.addObserver(self, selector: #selector(BMVideoFeedViewModel.playerDidFinishPlaying),
                                                   name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
        }
    }
    
   public private(set) var player = AVPlayer()
   
   public var currentTime: Double{
        get {
            return CMTimeGetSeconds(player.currentTime())
        }
        set {
            let newTime = CMTimeMakeWithSeconds(newValue, 1)
            player.seek(to: newTime, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
        }
    }
    
    func videoDuration() -> Float?{
        guard let videoAsset = asset else{
            return nil
        }
        return Float(CMTimeGetSeconds(videoAsset.duration))
    }
    
   @objc fileprivate func playerDidFinishPlaying() {
        currentTime = 0.0
        player.play()
    }
 
    public func configureAVPlayer(url: URL!) {
//        set contentURL so it can play video
        self.contentURL = url
//        self.player.play()
    }
    
    public func playVideo() {
        self.player.play()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}
