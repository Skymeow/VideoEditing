//
//  SoundBoardViewController.swift
//  ProjectBM
//
//  Created by Sky Xu on 4/12/18.
//  Copyright © 2018 JHK_Development. All rights reserved.
//

import UIKit
import AVFoundation

protocol SoundBoardDelegate: class {
    func passSoundTrackID(id: Int)
}

class SoundBoardViewController: UIViewController {

    //    CM Time clock
    var recordingTimer: Timer? = nil
    var masterClock: CMClock?
    var clockStartTime: CMTime?
    var clockEndTime: CMTime?
    var startTime: Double = 0
    var audioPlayer: AVAudioPlayer? = nil
    var intervalMap: [String:[Double]]? = nil
    var audioPlayersArray = [AVAudioPlayer?]()
    var playerIndexMap = [String:Int]()
    //SoundBoard
    var currentBoard: BMSoundBoard?
    var currentPlayingMap = [Int:Bool]()
    
    var currentSoundBoardId: String = UserServiceManger.shared.loadStoredSoundBoardId() {
        didSet{
            currentBoard = createDefaultSoundBoard(withId: currentSoundBoardId)
        }
    }
    
    let videoFileOutput =  AVCaptureMovieFileOutput()
    
    @IBOutlet weak var soundBoardCollectionView: UICollectionView!
    weak var delegate: SoundBoardDelegate?
    
    let colorStickers = [#imageLiteral(resourceName: "soundBoard7"), #imageLiteral(resourceName: "soundBoard8"), #imageLiteral(resourceName: "soundBoard6"), #imageLiteral(resourceName: "soundBoard5"), #imageLiteral(resourceName: "soundBoard9"), #imageLiteral(resourceName: "soundBoard0"), #imageLiteral(resourceName: "soundBoard1"), #imageLiteral(resourceName: "soundBoard2"), #imageLiteral(resourceName: "soundBoard3"), #imageLiteral(resourceName: "soundBoard4"), #imageLiteral(resourceName: "soundBoard10"), #imageLiteral(resourceName: "soundBoard11"), #imageLiteral(resourceName: "soundBoard12"), #imageLiteral(resourceName: "soundBoard13"), #imageLiteral(resourceName: "soundBoard14"), #imageLiteral(resourceName: "soundBoard15"), #imageLiteral(resourceName: "soundBoard37"), #imageLiteral(resourceName: "soundBoard36"), #imageLiteral(resourceName: "soundBoard35"), #imageLiteral(resourceName: "soundBoard34"), #imageLiteral(resourceName: "soundBoard33"), #imageLiteral(resourceName: "soundBoard32"), #imageLiteral(resourceName: "soundBoard31"),#imageLiteral(resourceName: "soundBoard30"), #imageLiteral(resourceName: "soundBoard29"), #imageLiteral(resourceName: "soundBoard28"), #imageLiteral(resourceName: "soundBoard27"),#imageLiteral(resourceName: "soundBoard26"), #imageLiteral(resourceName: "soundBoard25"), #imageLiteral(resourceName: "soundBoard24") , #imageLiteral(resourceName: "soundBoard23"), #imageLiteral(resourceName: "soundBoard22"), #imageLiteral(resourceName: "soundBoard16"), #imageLiteral(resourceName: "soundBoard17"), #imageLiteral(resourceName: "soundBoard18"), #imageLiteral(resourceName: "soundBoard19"), #imageLiteral(resourceName: "soundBoard20"), #imageLiteral(resourceName: "soundBoard21")]
    
    let soundBoardImages = [#imageLiteral(resourceName: "soundBoard7"), #imageLiteral(resourceName: "soundBoard8"), #imageLiteral(resourceName: "soundBoard6"), #imageLiteral(resourceName: "soundBoard5"), #imageLiteral(resourceName: "soundBoard9"), #imageLiteral(resourceName: "soundBoard0"), #imageLiteral(resourceName: "soundBoard1"), #imageLiteral(resourceName: "soundBoard2"), #imageLiteral(resourceName: "soundBoard3"), #imageLiteral(resourceName: "soundBoard4"), #imageLiteral(resourceName: "soundBoard10"), #imageLiteral(resourceName: "soundBoard11"), #imageLiteral(resourceName: "soundBoard12"), #imageLiteral(resourceName: "soundBoard13"), #imageLiteral(resourceName: "soundBoard14"), #imageLiteral(resourceName: "soundBoard15"), #imageLiteral(resourceName: "soundBoard37"), #imageLiteral(resourceName: "soundBoard36"), #imageLiteral(resourceName: "soundBoard35"), #imageLiteral(resourceName: "soundBoard34"), #imageLiteral(resourceName: "soundBoard33"), #imageLiteral(resourceName: "soundBoard32"), #imageLiteral(resourceName: "soundBoard31"),#imageLiteral(resourceName: "soundBoard30"), #imageLiteral(resourceName: "soundBoard29"), #imageLiteral(resourceName: "soundBoard28"), #imageLiteral(resourceName: "soundBoard27"),#imageLiteral(resourceName: "soundBoard26"), #imageLiteral(resourceName: "soundBoard25"), #imageLiteral(resourceName: "soundBoard24") , #imageLiteral(resourceName: "soundBoard23"), #imageLiteral(resourceName: "soundBoard22"), #imageLiteral(resourceName: "soundBoard16"), #imageLiteral(resourceName: "soundBoard17"), #imageLiteral(resourceName: "soundBoard18"), #imageLiteral(resourceName: "soundBoard19"), #imageLiteral(resourceName: "soundBoard20"), #imageLiteral(resourceName: "soundBoard21")].flatMap{ $0.noir }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.soundBoardCollectionView.isPagingEnabled = false
        currentBoard = createDefaultSoundBoard(withId: currentSoundBoardId)
        prepareAudioPlayers(with: currentSoundBoardId)
        intervalMap = [String:[Double]]()
       
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 2
        layout.minimumLineSpacing = 2
        soundBoardCollectionView.collectionViewLayout = layout
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        currentPlayingMap.removeAll()
        self.soundBoardCollectionView.reloadData()
    }
    
    func prepareAudioPlayers(with soundBoardId:String){
        audioPlayersArray.removeAll()
        for i in 0...37{
            //      FIXME:   change soudBoardID into \(soundBoardId)_  later
            if let soundURL = Bundle.main.url(forResource: ("default_" + String(i)), withExtension: "mp3"){
                do {
                    let tempAudioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                    tempAudioPlayer.delegate = self
                    audioPlayersArray.append(tempAudioPlayer)
                    playerIndexMap["default_\(i).mp3"] = i
                } catch {
                    //Puts an empty player in the array incase of empty file
                    audioPlayersArray.append(AVAudioPlayer())
                }
            }
            else{
                if let soundURL = Bundle.main.url(forResource: ("ss_" + String(i)), withExtension: "wav"){
                    do {
                        let tempAudioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                        tempAudioPlayer.delegate = self
                        audioPlayersArray.append(tempAudioPlayer)
                    } catch {
                        //Puts an empty player in the array incase of empty file
                        audioPlayersArray.append(AVAudioPlayer())
                    }
                }
            }
        }
    }
    
    @objc func tapSoundBoardBtn(_ sender: UIButton) {
//        print(CMTimeGetSeconds(videoFileOutput.recordedDuration))
        playAudioAtIndex(sender.tag)
        currentPlayingMap[Int(sender.tag)] = true
        self.delegate?.passSoundTrackID(id: sender.tag)
    }
    
//    public func resetMasterClock(_ session: AVCaptureSession?) -> CMClock {
//        startTimeCount()
//        self.masterClock = session?.masterClock
//        
//        return masterClock!
//    }
//    
    func playAudioAtIndex(_ index: Int){

        if videoFileOutput.isRecording{
            // MasterClock is a high precision timer
            clockEndTime = CMClockGetTime(masterClock!)
            let difference : CMTime = CMTimeSubtract(clockEndTime!, clockStartTime!)
            let seconds = CMTimeGetSeconds(difference)

            let audioName = currentSoundBoardId + "_" + String(index)
            if var intervals = intervalMap?[audioName]{

                intervals.append(Double(seconds))
                intervalMap?[audioName] = intervals
            }
            else{
                let intervals = [Double(seconds)]
                intervalMap?[audioName] = intervals
            }
        }

        if let player = audioPlayersArray[index]{
            if player.isPlaying{
                player.pause()
            }
            player.currentTime = 0
            //            FIXME: set this in recording vc?
//            if isMicrophonePluggedIn == false{
//                player.volume = 0.5
//            }
//            else{
//                player.volume = 1.0
//            }
            player.volume = 1.0
            player.play()
        }
    }

    fileprivate func createDefaultSoundBoard(withId id: String) -> BMSoundBoard{
        
        let premadeBoardIdIndexMap = ["horror":0, "hypemeup":1, "so":2, "ss":3, "ij":4, "kf":5, "zldr":6, "shrek":7, "pf":8, "nn":9, "mg":10]
        
        let premadeBoardTitles = ["#Horrify", "#HypeMeUp", "#SoapOpera", "#BananaPeel", "#IndianaJones", "#BruceLee", "#Zoolander", "#Shrek", "#Pulp Fiction", "#Nikki Minaj", "#Mean Girls"]
        let premadeBoardDescriptions = ["Creaking doors, heavy breathing, and screams to make your own horror film.",
                                        "Make the ultimate pump-up video with the sounds of cheering crowds, awed fans, and shocked reactions.",
                                        "Turn your life into a soap opera with gasps, gunshots, and a cheesy smooth jazz score.",
                                        "Good old-fashioned slapstick fun for comedy videos. Farts, burps, crashing sounds, and more for pranking your friends or perfecting your comedy short.",
                                        "Cars swerving, punches landing, whips cracking… everything needed for a great action adventure video.",
                                        "Choreograph and film the perfect fight scene with kicks, falls, and grunting bad guys.",
                                        Constants.zoolanderSoundBoardDescription,
                                        Constants.shrekSoundBoardDescription,
                                        Constants.pulpFictionSoundBoardDescription,
                                        Constants.nickiSoundBoardDescription,
                                        Constants.meanGirlsSoundBoardDescription]
                                        
        
        guard let defaultBoardIndex = premadeBoardIdIndexMap[id] else{
            fatalError("Premade soundboard doesn't exist for id \(id) \n")
        }
        let defaultBoard = BMPremadeSoundBoard(id: id, title: premadeBoardTitles[defaultBoardIndex], description: premadeBoardDescriptions[defaultBoardIndex], isInUse: true)
        
        return defaultBoard
    }
    
    @objc func btnBounce(_ sender: UIButton) {
//        UIView.animate(withDuration: 0.6, animations: {sender.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)},
//                       completion: { _ in
//                        UIView.animate(withDuration: 0.6) {
//                            sender.transform = CGAffineTransform.identity
//                        }
//        })
    }
    
    @objc func transformColor(_ sender: UIButton) {
        if let pressedButtonSoundTrack = audioPlayersArray[sender.tag] {
            NSLog("transformColor color for button with duration \(pressedButtonSoundTrack.duration)")
            let colorSticker = colorStickers[sender.tag]
            guard let cell = soundBoardCollectionView.cellForItem(at: IndexPath(row: sender.tag, section: 0)) as? SoundBoardCollectionViewCell else { return }
            cell.soundBoardBtn.setBackgroundImage(colorSticker, for: .normal)
            cell.soundBoardBtn.setBackgroundImage(colorSticker, for: .highlighted)
        }
    }

    
    @objc func attachshadow(_ sender: UIButton) {
        
        sender.attachShadow(UIColor.init(rgb: 0x47D3FF), BMUIViewShadowType.filled)
    }
}

extension SoundBoardViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return soundBoardImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? SoundBoardCollectionViewCell else {fatalError("collection view cell not configured") }
        let tag = indexPath.row
        cell.soundBoardBtn.tag = tag
        cell.soundBoardBtn.imageView?.contentMode = .scaleAspectFit
        if let isPlaying = currentPlayingMap[Int(indexPath.item)], isPlaying {
            cell.soundBoardBtn.setBackgroundImage(colorStickers[indexPath.row], for: .normal)
        }
        else {
            cell.soundBoardBtn.setBackgroundImage(soundBoardImages[indexPath.row], for: .normal)
        }
        cell.soundBoardBtn.setBackgroundImage(colorStickers[indexPath.row], for: .highlighted)


        cell.soundBoardBtn.addTarget(self, action: #selector(transformColor(_:)), for: .touchUpInside)
//        cell.soundBoardBtn.addTarget(self, action: #selector(btnBounce(_:)), for: .touchUpInside)
//        cell.soundBoardBtn.addTarget(self, action: #selector(attachshadow(_:)), for: .touchUpInside)
        cell.soundBoardBtn.addTarget(self, action: #selector(tapSoundBoardBtn), for: .touchUpInside)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
         guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? SoundBoardCollectionViewCell else {fatalError("collection view cell not configured") }

    }
    
}

extension SoundBoardViewController: AVAudioPlayerDelegate {
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if let url = player.url {
            NSLog(url.absoluteString)
            let urlString = url.absoluteString
            if let audioName = urlString.components(separatedBy: "/").last {
                NSLog(audioName)
                if let index = playerIndexMap[audioName] {
//                    let modifiedIndex = index + 6
                    currentPlayingMap[Int(index)] = false
                    guard let cell = soundBoardCollectionView.cellForItem(at: IndexPath(row: index, section: 0)) as? SoundBoardCollectionViewCell else { return }
                    cell.soundBoardBtn.setBackgroundImage(soundBoardImages[index], for: .normal)
                    cell.soundBoardBtn.setBackgroundImage(soundBoardImages[index], for: .highlighted)
                }
            }
        }
    }
}

extension SoundBoardViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        let itemSpacing = layout.minimumInteritemSpacing
        let sectionSpacing = layout.minimumLineSpacing
        let insets = layout.sectionInset.left + layout.sectionInset.right
        let width = collectionView.bounds.width / 3.3 - itemSpacing - insets
        let height = self.soundBoardCollectionView.bounds.size.height - 2 * sectionSpacing
        
        return CGSize(width: width, height: height)
    }
}
