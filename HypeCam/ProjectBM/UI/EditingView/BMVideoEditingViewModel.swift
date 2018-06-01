//
//  BMVideoEditingViewModel.swift
//  ProjectBM
//
//  Created by Jiahe Kuang on 12/25/17.
//  Copyright © 2017 JHK_Development. All rights reserved.
//

import Foundation
import AVFoundation

class BMVideoEditingViewModel {
    
    public let player = AVPlayer()

    var audioPlayersArray = [AVAudioPlayer?]()
    var intervalMap = [String:[Double]]()
    
    var selectedBoard: BMSoundBoard? {
        didSet{
            if let board = selectedBoard{
                prepareAudioPlayers(with: board.id)
            }
        }
    }

    public var contentURL: URL? = nil{
        didSet{
            if let url = contentURL{
                asset = AVURLAsset(url: url, options: nil)
            }
        }
    }
    
    var videoTitle: String = ""
    
    public var currentTime: Double{
        get {
            return CMTimeGetSeconds(player.currentTime())
        }
        set {
            let newTime = CMTimeMakeWithSeconds(newValue, 1)
            player.seek(to: newTime, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
        }
    }
    
    func prepareAudioPlayers(with soundBoardId:String){
        audioPlayersArray.removeAll()
        for i in 0...7{
            if let soundURL = Bundle.main.url(forResource: ("\(soundBoardId)_" + String(i)), withExtension: "mp3"){
                do {
                    let tempAudioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                    audioPlayersArray.append(tempAudioPlayer)
                } catch {
                    //Puts an empty player in the array incase of empty file
                    audioPlayersArray.append(AVAudioPlayer())
                }
            }
            else {
                if let soundURL = Bundle.main.url(forResource: ("\(soundBoardId)_" + String(i)), withExtension: "wav"){
                    do {
                        let tempAudioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                        audioPlayersArray.append(tempAudioPlayer)
                    } catch {
                        //Puts an empty player in the array incase of empty file
                        audioPlayersArray.append(AVAudioPlayer())
                    }
                }
            }
        }
    }
    
    
    func playAudioAtIndex(_ index: Int){
        if let player = audioPlayersArray[index]{
            if player.isPlaying{
                player.pause()
            }
            player.currentTime = 0
            player.play()
        }
    }
    
    func playerDuration(atIndex index: Int) -> TimeInterval?{
        if let player = audioPlayersArray[index]{
            return player.duration
        }
        return nil
    }
    
    var asset: AVURLAsset? {
        didSet{
            if let newAsset = asset{
                playerItem = AVPlayerItem(asset: newAsset)
            }
        }
    }
    
    func videoDuration() -> Float?{
        guard let videoAsset = asset else{
            return nil
        }
        return Float(CMTimeGetSeconds(videoAsset.duration))
    }
    
    func insertTracks(atIndex index: Int){
        
        guard let board = selectedBoard else{
            fatalError("Playing board without ID")
        }
        
        let audioName = board.id + "_" + String(index)
        if var intervals = intervalMap[audioName]{
            intervals.append(currentTime)
            intervalMap[audioName] = intervals
        }
        else{
            let intervals = [currentTime]
            intervalMap[audioName] = intervals
        }
    }
    
    func processTracks(_ completionHanlder: @escaping (URL?, Error?) -> ()){
        player.pause()
        if intervalMap.count == 0 {
            completionHanlder(nil, nil)
        }
        else{
            videoTitle = newEditedVideoName()
            let outputAudioFileName = "mergedSoundsFor" + videoTitle
            BMDefaultMediaServiceManager.shared.mergeAudioFiles(intervalMap, outputAudioFileName) { (mergedAudioURL, error) in
                //Recored videos store in movie directory
                BMDefaultMediaServiceManager.shared.mergeContents(mergedAudioURL, self.contentURL!, self.videoTitle, { (url, error) in
                    if let finalOutputURL = url{
                        self.contentURL = finalOutputURL
                        self.player.play()
                        completionHanlder(finalOutputURL, nil)
                    }
                })
            }
        }
    }
    
    @objc fileprivate func playerDidFinishPlaying() {
        currentTime = 0.0
        player.play()
    }

    
    fileprivate func newEditedVideoName() -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_hh:mm:ss"
        let currentTimeString = dateFormatter.string(from: Date())
        return  currentTimeString + "_edited.mov"

    }
    
    
    private var playerItem: AVPlayerItem? {
        didSet {
            player.replaceCurrentItem(with: self.playerItem)
            NotificationCenter.default.addObserver(self, selector: #selector(BMVideoEditingViewModel.playerDidFinishPlaying),
                                                   name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
