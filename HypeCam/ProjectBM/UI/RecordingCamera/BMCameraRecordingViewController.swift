//
//  ViewController.swift
//  ProjectBM
//
//  Created by Jiahe Kuang on 11/20/17.
//  Copyright © 2017 JHK_Development. All rights reserved.
//

import UIKit
import AVFoundation
import Mixpanel
import RealmSwift
import Alamofire

enum CameraType {
    case front
    case back
}

class BMCameraRecordingViewController: UIViewController, UITextFieldDelegate {
    // MARK: IB Outlets

    @IBOutlet weak var cameraSwitchButton: UIButton!
    @IBOutlet weak var editBoardButton: UIButton!
    @IBOutlet weak var soundBoardContainerView: UIView!
    @IBOutlet weak var musicBoardButton: UIButton!
    @IBOutlet weak var recordingButton: UIButton!
    @IBOutlet weak var barImageView: UIImageView!
    @IBOutlet weak var arrowImageView: UIImageView!
    
//    @IBOutlet weak var editingButton: UIButton!
    
    @IBOutlet weak var buttonVerticalStackViewContainer: UIStackView!
    @IBOutlet weak var buttonTopStackView: UIStackView!
    @IBOutlet weak var buttonBottomStackView: UIStackView!
    
    @IBOutlet weak var recordingTimerLabel: UILabel!
    // MARK: Constraints

    @IBOutlet weak var soundboardContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet var buttonSpacingConstraints: [NSLayoutConstraint]!

    var currentCameraType: CameraType = .front
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    let dateFormatter = DateFormatter()
    var recordedFileURL: URL?
    var videoTitle: String = ""
    let videoFileOutput =  AVCaptureMovieFileOutput()
    var isMicrophonePluggedIn = false {
        didSet {
            if isMicrophonePluggedIn {
                do {
                    try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSessionPortOverride.none)
                } catch _ {
                    
                }
            }
            else {
                do {
                    try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
                } catch _ {
                    
                }

            }
        }
    }

    //Used for clean up
    
    var mergedAudioTracksURL: URL? = nil

    //TimeCount
    
    var recordingTimer: Timer? = nil
    var startTime: Double = 0
    var currentRecordingTime: Double = 0
    var audioPlayersArray = [AVAudioPlayer?]()
    var pressedStartRecordingTime:Double = 0.0
    var actualStartRecording: Double = 0.0
    var timerDelay:Double = 0.0
    
    //Test
    let testSound0 = Bundle.main.url(forResource: "test_0", withExtension: "wav")
    var audioPlayer: AVAudioPlayer? = nil
    var intervalMap = [String:[Double]]()
    var currentGif: Gif?
    

    let neonColorMap = [0:0xE6FB04,
                        1:0xFF0000,
                        2:0xFF6600,
                        3:0x00FF33,
                        4:0x00FFFF,
                        5:0x099FFF,
                        6:0xFF0099,
                        7:0x9D00FF]

    var currentBoard: BMSoundBoard?


    @IBOutlet weak var recordingProgressViewContainer: UIView!
    @IBOutlet weak var recordingTimeLabel: UILabel!
    @IBOutlet weak var recordingProgressView: UIProgressView!

    @IBOutlet weak var discoverContainer: UIView!
    var discoverVC: DiscoverViewController?
    
    var isRecording: Bool = false {
        didSet{
            if isRecording == true {
                recordingButton.setImage(#imageLiteral(resourceName: "stopRecording"), for: .normal)
                recordingButton.attachShadow(nil, nil)
//                startRecording(captureSession)
            }
            else{
                recordingButton.setImage(#imageLiteral(resourceName: "newRecordBtn"), for: .normal)
                recordingButton.setBackgroundImage(#imageLiteral(resourceName: "newRecordBtn"), for: .normal)
                recordingButton.attachShadow(nil, nil)
                //isRecording could be manually altered when it reaches max time limit
                if videoFileOutput.isRecording{
//                    stopRecording()
                }
            }
            isMicrophonePluggedIn = isAudioInputDevicePluggedIn()
//            recordingTimerLabel.isHidden = !isRecording
        }
    }
    
    // Audio
    let audioService: AudioService = DefaultAudioService.sharedInstance
    var currentDownloadedGifURL: URL?

    var masterClock: CMClock?
    var clockStartTime: CMTime?
    var clockEndTime: CMTime?

    @IBOutlet weak var textField: UITextField!

    @IBAction func searchTapped(_ sender: UIButton) {
        
        self.dismissKeyboardWhenSearch()
        if textField.text?.isEmpty == false {
            self.resetDiscoverCollectionView(textField.text!)
        } else {
            AlertView.instance.presentAlertView("Please enter a valid search keyword", self)
        }
    }
    
  func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toGifDiscover" {
            discoverVC = segue.destination as? DiscoverViewController
        }
    }
    
    func dismissKeyboardWhenSearch() {
        textField.resignFirstResponder()
    }
    
    func resetDiscoverCollectionView(_ searchWord: String) {
        self.discoverVC?.isSearched = true
        self.discoverVC?.searchKeyWord = searchWord
        // clear trendy gifs as collection view data source
        self.discoverVC?.gifObejcts = [Gif]()
        self.discoverVC?.searchOffset = 0
        self.discoverVC?.searchGiphy(searchWord: searchWord)
        self.discoverVC?.reStartView()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField.text?.isEmpty == false {
            self.resetDiscoverCollectionView(textField.text!)
        } else {
            AlertView.instance.presentAlertView("Please enter a valid search keyword", self)
        }
        
        return true
    }
    
//    // MARK: - Stages
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textField.delegate = self
        self.hideKeyboardWhenTappedAround()
        isMicrophonePluggedIn = isAudioInputDevicePluggedIn()
        registerNotificationObservers()
//        recordingTimerLabel.isHidden = !isRecording
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.textField.attributedPlaceholder = NSAttributedString(string: "Search Gifs", attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        recordingTimerLabel.text = "30"
//        configureStaticUIs()
////        adjustConstraints()
////        configureSoundBoard()
        configureButtons()
        recordingButton.setImage(#imageLiteral(resourceName: "newRecordBtn"), for: .normal)
//        editingButton.setImage(#imageLiteral(resourceName: "startRecording"), for: .normal)
//        startSession(captureSession)
    }
    
    func registerNotificationObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(audioRouteChangeListener(notification:)), name: Notification.Name.AVAudioSessionRouteChange, object: nil)
    }
    
    func endTimeCount(){
        startTime = 0
        currentRecordingTime = 0
        if let timer = recordingTimer{
            timer.invalidate()
        }
    }
    
    func startTimeCount(){
        endTimeCount()
        intervalMap.removeAll()
        startTime = Date().timeIntervalSinceReferenceDate
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: { (timer) in
            self.currentRecordingTime = Date().timeIntervalSinceReferenceDate - self.startTime
            self.recordingTimerLabel.text = "\(30-Int(self.currentRecordingTime))"
            if self.currentRecordingTime >= 30.0 {
                self.stopRecording()
            }
        })
    }
    
    @objc private func audioRouteChangeListener(notification: Notification) {
        let rawReason = notification.userInfo![AVAudioSessionRouteChangeReasonKey] as! UInt
        let reason = AVAudioSessionRouteChangeReason(rawValue: rawReason)!
        
        switch reason {
        case .newDeviceAvailable:
            print("headphone plugged in")
            //if the head phone is plugged in during a recording, the status wont be updated
            if !videoFileOutput.isRecording{
                isMicrophonePluggedIn = true
            }
        case .oldDeviceUnavailable:
            print("headphone pulled out")
            isMicrophonePluggedIn = false
        default:
            break
        }
    }


    func configureButtons(){
//        editBoardButton.attachShadow(nil, nil)
        recordingButton.attachShadow(nil, nil)
    }
//
    func configureStaticUIs(){
//        recordingProgressViewContainer.attachShadow(nil, nil)
//        recordingProgressViewContainer.isHidden = !isRecording
        // FIXME: Hiding soundboard option
        barImageView.attachShadow(nil, nil)
        arrowImageView.attachShadow(nil, nil)
    }

    func addLoadingIndicator(){

        guard let loadingIndicator = Bundle.main.loadNibNamed("BMLoadingIndicator",
                                                              owner:self, options:nil)![0] as? BMLoadingIndicatorView else{
                                                                return
        }
        loadingIndicator.configView(with: "Processing", at: view.center)
        view.addSubview(loadingIndicator)
    }

    func removeLoadingIndcator(){
        for view in view.subviews{
            if view is BMLoadingIndicatorView{
                view.removeFromSuperview()
                break
            }
        }
    }

    @IBAction func recordingButtonPressed(_ sender: UIButton) {
        print("recording pressed")
        if !isRecording {
            audioService.startRecording(for: nil, callBackQueue: DispatchQueue.main) { [weak self] (result) in
                guard let strongSelf = self else { return }
                switch result{
                case .success:
                    strongSelf.discoverVC?.reStartView()
                    strongSelf.isRecording = true
                    strongSelf.startTimeCount()
                case .failure:
                    // Do something
                    break
                }
            }
        }
        else {
            stopRecording()
        }
    }
    
    func stopRecording() {
        recordingButton.isEnabled = false
        audioService.stopRecording(callBackQueue: DispatchQueue.main) { [weak self] (result) in
            guard let strongSelf = self else { return }
            strongSelf.endTimeCount()
            switch result{
            case .success(let url):
                guard let audioURL = url else { return }
                strongSelf.isRecording = false
                guard let gifURL = strongSelf.currentGif?.gifUrl else { return }
                strongSelf.addLoadingIndicator()
                strongSelf.startDownload(video: gifURL, queue: DispatchQueue.main, callBack: { (data) in
                    guard let downLoadedVideoURL = data.destinationURL else { return }
                    strongSelf.dateFormatter.dateFormat = "yyyy-MM-dd_hh:mm:ss"
                    let currentTimeString = strongSelf.dateFormatter.string(from: Date())
                    strongSelf.videoTitle = currentTimeString + "_final"
                    if !strongSelf.isMicrophonePluggedIn {
                        strongSelf.intervalMap.removeAll()
                    }
                    BMDefaultMediaServiceManager.shared.mixAudiTracks(with: strongSelf.intervalMap, with: audioURL, { (url, error) in
                        var finalAudioURL = audioURL
                        if let mergedAudioURL = url {
                            finalAudioURL = mergedAudioURL
                        }
                        BMDefaultMediaServiceManager.shared.mergeContents(finalAudioURL, downLoadedVideoURL, strongSelf.videoTitle, { (url, error) in
                            if let finalOutputURL = url{
                                DispatchQueue.main.async {
                                    strongSelf.recordingButton.isEnabled = true
                                    strongSelf.removeLoadingIndcator()
                                    strongSelf.recordedFileURL = finalOutputURL
                                    strongSelf.performSegue(withIdentifier: "fromRecordingToPostEdit", sender: self)
                                }
                            }
                        })
                        
                    })
                })
            case .failure:
                // Do something
                break
            }
        }
    }
    
    //Detetect microphone as the app is launched
    func isAudioInputDevicePluggedIn()->Bool{
        let route = AVAudioSession.sharedInstance().currentRoute
        for port in route.outputs {
            if port.portType == AVAudioSessionPortHeadphones {
                return true
            }
        }
        return false
    }
    
    func playSound(soundUrl: URL) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundUrl)
            audioPlayer?.volume = 1.0
            audioPlayer?.play()
        }catch let error {
            print("Error: \(error.localizedDescription)")
        }
    }
    
    func startDownload(video:String, queue: DispatchQueue, callBack: @escaping (DownloadResponse<Data>)->Void) -> Void {
        let fileUrl = self.getSaveFileUrl(fileName: video)
        let destination: DownloadRequest.DownloadFileDestination = { _, _ in
            return (fileUrl, [.removePreviousFile, .createIntermediateDirectories])
        }
        
        Alamofire.download(video, to:destination)
            .downloadProgress { (progress) in
                
            }
            .responseData { (data) in
                queue.async {
                    callBack(data)
                }
        }
    }
    
    func getSaveFileUrl(fileName: String) -> URL {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        var videoTitle = fileName
        let components = fileName.components(separatedBy: "/")
        if components.count >= 2 {
            videoTitle = components[components.count-2]+".mp4"
        }

        let nameUrl = URL(string: videoTitle)
        let fileURL = documentsURL.appendingPathComponent((nameUrl?.lastPathComponent)!)
        NSLog(fileURL.absoluteString)
        return fileURL;
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fromRecordingToPostEdit" {
            let destinationVC: BMVideoEditingViewController = segue.destination as! BMVideoEditingViewController
            destinationVC.viewModel.contentURL = recordedFileURL
            destinationVC.viewModel.selectedBoard = currentBoard
        }
        if segue.identifier == "toShouldBoardVC"{
            guard let destinationVC = segue.destination as? SoundBoardViewController else{
                fatalError("SoundBoardViewController ")
            }
            destinationVC.delegate = self
        }
        if segue.identifier == "toGifDiscover" {
            guard let discoverViewController = segue.destination as? DiscoverViewController else { return }
            discoverViewController.delegate = self
            discoverVC = discoverViewController
        }
    }

    @IBAction func feedButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true) {
            //Do something
        }
    }
    
    deinit {
        NSLog("Leaving recording view")
        if let timer = recordingTimer{
            timer.invalidate()
        }
        NotificationCenter.default.removeObserver(self, name: Notification.Name.AVAudioSessionRouteChange, object: nil)
    }

}

extension BMCameraRecordingViewController: DiscoverProtocol {

    func passPlayingResourceObject(gifObject: Gif) {
        print(gifObject.gifUrl)
        currentGif = gifObject
    }
    
}

extension BMCameraRecordingViewController: SoundBoardDelegate {
    // FIXME: This is very bad, it needs to return a string id not a tag.
    func passSoundTrackID(id: Int) {
        let trackId  = "default_\(id-6)"
        if var intervals = intervalMap[trackId]{
            intervals.append(Double(self.currentRecordingTime))
            intervalMap[trackId] = intervals
        }
        else{
            let intervals = [Double(self.currentRecordingTime)]
            intervalMap[trackId] = intervals
        }
    }
}

