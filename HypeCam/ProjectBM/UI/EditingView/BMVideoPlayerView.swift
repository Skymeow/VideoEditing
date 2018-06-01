//
//  BMVideoPlayerView.swift
//  ProjectBM
//
//  Created by Jiahe Kuang on 12/25/17.
//  Copyright © 2017 JHK_Development. All rights reserved.
//

import UIKit
import AVFoundation

class BMVideoPlayerView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    var player: AVPlayer? {
        get {
            return playerLayer.player
        }
        
        set {
            playerLayer.player = newValue
        }
    }
    
    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
}
