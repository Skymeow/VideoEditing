//
//  BMSoundBoardsViewModel.swift
//  ProjectBM
//
//  Created by Jiahe Kuang on 12/4/17.
//  Copyright © 2017 JHK_Development. All rights reserved.
//

import Foundation
class BMSoundBoardsViewModel {
    
    var selectedSoundBoardId: String?
    
    fileprivate var soundBoardsArray = [BMSoundBoard]()
    fileprivate let premadeBoardIds = ["horror", "hypemeup", "so", "ss", "ij", "kf", "zldr", "shrek", "pf", "nn", "mg", "kayn", "fly", "chr", "bry"]
    fileprivate let premadeBoardTitles = ["#Horrify", "#HypeMeUp", "#SoapOpera", "#BananaPeel", "#IndianaJones", "#BruceLee", "#Zoolander", "#Shrek", "#Pulp Fiction", "#Nikki Minaj", "#Mean Girls", "#Kanye", "#Filayyy", "#Call Him Renny", "#Britney"]
    fileprivate let premadeBoardDescriptions = ["Creaking doors, heavy breathing, and screams to make your own horror film.",
                                                "Make the ultimate pump-up video with the sounds of cheering crowds, awed fans, and shocked reactions.",
                                                "Turn your life into a soap opera with gasps, gunshots, and a cheesy smooth jazz score.",
                                                "Good old-fashioned slapstick fun for comedy videos. Farts, burps, crashing sounds, and more for pranking your friends or perfecting your comedy short.",
                                                "Cars swerving, punches landing, whips cracking… everything needed for a great action adventure video.",
                                                "Choreograph and film the perfect fight scene with kicks, falls, and grunting bad guys.",
                                                 Constants.zoolanderSoundBoardDescription,
                                                 Constants.shrekSoundBoardDescription,
                                                 Constants.pulpFictionSoundBoardDescription,
                                                 Constants.nickiSoundBoardDescription,
                                                 Constants.meanGirlsSoundBoardDescription,
                                                 Constants.kayneSoundBoardDescription,
                                                 Constants.filayyySoundBoardDescription,
                                                 Constants.callHimRennySoundBoardDescription,
                                                 Constants.britneySoundBoardDescription]
    
    var totalSoundBoardsCount: Int  {
        return soundBoardsArray.count
    }
    
    //FIX ME: Hard coding a bunch of premade soundbaords
    func createPremadeBoards(){
        var selectedIndex: Int? = nil
        for i in 0..<premadeBoardIds.count{
            var isInUsed = false
            if premadeBoardIds[i] == selectedSoundBoardId{
                isInUsed = true
                selectedIndex = i
            }
            let premadeSoundBoard = BMPremadeSoundBoard(id: premadeBoardIds[i], title: premadeBoardTitles[i], description: premadeBoardDescriptions[i], isInUse: isInUsed)
            add(premadeSoundBoard)
        }
        if let selectedSoundBoardIndex = selectedIndex{
            selectBoard(at: selectedSoundBoardIndex)
        }
    }
    
    func showAllBoards(){
        for i in 0..<premadeBoardIds.count{
            let premadeSoundBoard = BMPremadeSoundBoard(id: premadeBoardIds[i], title: premadeBoardTitles[i], description: premadeBoardDescriptions[i], isInUse: false)
            add(premadeSoundBoard)
        }
    }
    
    func selectBoard(at index:Int){
        if index != 0{
            var newBoard = soundBoardsArray[index]
            newBoard.isInUse = true
            var previousltSelectedBoard = soundBoardsArray[0]
            previousltSelectedBoard.isInUse = false
            soundBoardsArray[0] = newBoard
            soundBoardsArray[index] = previousltSelectedBoard
        }
    }
    
    func add(_ soundboard: BMSoundBoard) {
        soundBoardsArray.append(soundboard)
    }
    
    func soundBoard(at index: Int)->BMSoundBoard?{
        if index >= totalSoundBoardsCount{
            return nil
        }
        return soundBoardsArray[index]
    }
}
