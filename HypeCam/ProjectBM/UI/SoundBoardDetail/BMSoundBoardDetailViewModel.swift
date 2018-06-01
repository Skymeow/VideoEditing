//
//  BMSoundBoardDetailViewModel.swift
//  ProjectBM
//
//  Created by Jiahe Kuang on 12/7/17.
//  Copyright © 2017 JHK_Development. All rights reserved.
//

import Foundation
import AVFoundation

class BMSoundBoardDetailViewModel {
    
    var audioPlayersArray = [AVAudioPlayer?]()
    
    var soundBoard: BMSoundBoard? = nil {
        didSet{
            if let board  = soundBoard{
                print("a soundboar has been assigned \(board.id)")
                prepareAudioPlayers(with: board.id)
            }
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
    
    func playTrack(at index:Int)->AVAudioPlayer?{
        if let player = audioPlayersArray[index]{
            if player.isPlaying{
                player.pause()
            }
            player.currentTime = 0
            player.play()
            return player
        }
        return nil
    }
    
}
