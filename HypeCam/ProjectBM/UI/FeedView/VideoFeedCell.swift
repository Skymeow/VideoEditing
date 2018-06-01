//
//  VideoFeedCell.swift
//  ProjectBM
//
//  Created by Sky Xu on 3/9/18.
//  Copyright © 2018 JHK_Development. All rights reserved.
//

import UIKit
import AVFoundation

class VideoFeedCell: UITableViewCell {
    
    @IBOutlet weak var videoPlayerView: BMVideoPlayerView!
    @IBOutlet weak var videoThumbnail: UIImageView!
    
    public var playerLayer: AVPlayerLayer? {
        return videoPlayerView.playerLayer
    }
    
    let viewModel = BMVideoFeedViewModel()
    
    @IBOutlet weak var recordBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        //        feedImg.layer.cornerRadius = 10
        //        feedImg.layer.borderWidth = 1
        //        feedImg.layer.borderColor = UIColor.clear.cgColor
        //        feedImg.attachShadow(UIColor.init(red: 150.0/255, green: 155.0/255, blue: 163.0/255, alpha: 0.2), nil)
    }
    
    override func layoutSubviews() {
        configureVideoPlayerLayer()
    }
    
    func configureVideoPlayerLayer(){
        playerLayer?.videoGravity = .resizeAspectFill
    }
    
}

