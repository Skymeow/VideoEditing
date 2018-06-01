//
//  BMVideoEditingViewController.swift
//  ProjectBM
//
//  Created by Jiahe Kuang on 12/25/17.
//  Copyright © 2017 JHK_Development. All rights reserved.
//

import UIKit
import AVFoundation
import RealmSwift

enum UploadButtonState {
    case beforeUpload
    case uploading
    case uploaded
    case linkCopied
}

private var videoEditingViewControllerKVOContext = 0

class BMVideoEditingViewController: UIViewController, UIGestureRecognizerDelegate {
    
    // MARK: - Referecing Outlets
    
    @IBOutlet weak var videoPlayerView: BMVideoPlayerView!
//    @IBOutlet weak var videoProgressSlider: UISlider!
//    @IBOutlet weak var userInputContainer: UIView!
//    @IBOutlet weak var soundBoardContainerView: UIView!
//    @IBOutlet weak var dismissButton: UIButton!
//    @IBOutlet weak var doneEditingButton: UIButton!
    @IBOutlet weak var topButtonStackView: UIStackView!
    @IBOutlet weak var bottomButtonStackView: UIStackView!
    @IBOutlet weak var buttonVerticalContainer: UIStackView!
    @IBOutlet weak var boardsButton: UIButton!
    @IBOutlet weak var saveVideoButton: UIButton!
    @IBOutlet weak var uploadToCloudButton: UIButton!
    @IBOutlet weak var createNewVideoButton: UIButton!
    // MARK: - Referecing Layout Outlets
    
//    @IBOutlet weak var userInputContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet var soundBoardButtonSpacingConstraints: [NSLayoutConstraint]!
    
    // MARK: - Driver Models

    let viewModel = BMVideoEditingViewModel()
    
    private var playerLayer: AVPlayerLayer? {
        return videoPlayerView.playerLayer
    }
    
    private var timeObserverToken: Any?
    
    var uploadButtonState: UploadButtonState = .beforeUpload {
        didSet {
            switch uploadButtonState {
            case .beforeUpload:
                uploadToCloudButton.setImage(#imageLiteral(resourceName: "uploadtohype"), for: .normal)
                uploadToCloudButton.setImage(#imageLiteral(resourceName: "uploadtohype"), for: .selected)
                uploadToCloudButton.isEnabled = true
            case .uploading:
                uploadToCloudButton.setImage(#imageLiteral(resourceName: "uploading"), for: .normal)
                uploadToCloudButton.setImage(#imageLiteral(resourceName: "uploading"), for: .selected)
                uploadToCloudButton.isEnabled = false
            case .uploaded:
                uploadToCloudButton.setImage(#imageLiteral(resourceName: "shareLink"), for: .normal)
                uploadToCloudButton.setImage(#imageLiteral(resourceName: "shareLink"), for: .selected)
                uploadToCloudButton.isEnabled = true
            case .linkCopied:
                uploadToCloudButton.setImage(#imageLiteral(resourceName: "copied"), for: .normal)
                uploadToCloudButton.setImage(#imageLiteral(resourceName: "copied"), for: .selected)

                uploadToCloudButton.isEnabled = false
            }
        }
    }
    
    var shareLink: String  = ""

    // MARK: - View Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        registerUIGuestureRecognizer()
        playerLayer?.player = viewModel.player
//        soundBoardContainerView.isHidden = true
        viewModel.player.volume = 1.0
        let isHeadPhoneOn = isAudioInputDevicePluggedIn()
        if !isHeadPhoneOn {
            do {
                try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
            } catch _ {
                
            }
        }
        registerNotificationObservers()
    }
    
    func registerNotificationObservers(){
        NotificationCenter.default.addObserver(self, selector: #selector(audioRouteChangeListener(notification:)), name: Notification.Name.AVAudioSessionRouteChange, object: nil)
    }
    
    @objc private func audioRouteChangeListener(notification: Notification) {
        let rawReason = notification.userInfo![AVAudioSessionRouteChangeReasonKey] as! UInt
        let reason = AVAudioSessionRouteChangeReason(rawValue: rawReason)!
        
        switch reason {
        case .newDeviceAvailable:
            print("headphone plugged in")
            do {
                try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSessionPortOverride.none)
            } catch _ {
                
            }
        case .oldDeviceUnavailable:
            do {
                try AVAudioSession.sharedInstance().overrideOutputAudioPort(AVAudioSessionPortOverride.speaker)
            } catch _ {
                
            }
            break
        default:
            break
        }
    }

    func isAudioInputDevicePluggedIn()->Bool{
        let route = AVAudioSession.sharedInstance().currentRoute
        for port in route.outputs {
            if port.portType == AVAudioSessionPortHeadphones {
                return true
            }
        }
        return false
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureUI()
        configureVideoPlayerLayer()
//        configureSlider()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        adjustButtonConstraints()
//        configureSoundBoard()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.player.play()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        removeSilderUpdate()
    }

    // MARK: - Memory Management

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UI Management

//    func adjustButtonConstraints(){
//        let requireBaseHeight = 69
//        let buttonSpacing = (self.view.frame.width - 72 * 4) / 5
//        let newInputContinerHeight = (CGFloat(requireBaseHeight + 144) + buttonSpacing)
////        userInputContainerHeightConstraint.constant = newInputContinerHeight
////        topButtonStackView.spacing = buttonSpacing
////        bottomButtonStackView.spacing = buttonSpacing
////        buttonVerticalContainer.spacing = buttonSpacing
////        for constraint in soundBoardButtonSpacingConstraints{
////            constraint.constant = buttonSpacing
////        }
//        self.view.layoutIfNeeded()
//    }
//
    func configureVideoPlayerLayer(){
        playerLayer?.videoGravity = .resizeAspectFill
    }
    
//    func configureSlider(){
//        guard let videoDuration = viewModel.videoDuration() else{
//            fatalError("Couldn't properly calculate video duration")
//        }
//        videoProgressSlider.maximumValue = videoDuration
//        videoProgressSlider.addTarget(self, action: #selector(onSliderValChanged(slider:event:)), for: .valueChanged)
//        registerSilderUpdate()
//    }
    
    func registerUIGuestureRecognizer(){
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tappedScreen(_:)))
        gesture.delegate = self
        videoPlayerView.addGestureRecognizer(gesture)
    }
    
    func configureUI() {
//        soundBoardContainerView.isHidden = true
//        doneEditingButton.isHidden = true
//        dismissButton.isHidden = true
//        boardsButton.isHidden = true
        
//        videoProgressSlider.attachShadow(nil, nil)
//        dismissButton.attachShadow(nil, nil)
//        doneEditingButton.attachShadow(nil, nil)
        saveVideoButton.attachShadow(nil, nil)
        uploadToCloudButton.attachShadow(nil, nil)
        createNewVideoButton.attachShadow(nil, nil)
    }
    
//    func configureSoundBoard(){
////        soundBoardContainerView.isHidden = viewModel.selectedBoard == nil
//        for subview in buttonVerticalContainer.subviews{
//            for button in subview.subviews{
//                let tag = button.tag
//                switch tag{
//                case 0, 4:
//                    (button as! UIButton).setImage(#imageLiteral(resourceName: "button0_normal"), for: .normal)
//                    (button as! UIButton).setImage(#imageLiteral(resourceName: "button0_pressed"), for: .selected)
//                    (button as! UIButton).setImage(#imageLiteral(resourceName: "button0_pressed"), for: .highlighted)
//                case 1, 5:
//                    (button as! UIButton).setImage(#imageLiteral(resourceName: "button1_normal"), for: .normal)
//                    (button as! UIButton).setImage(#imageLiteral(resourceName: "button1_pressed"), for: .selected)
//                    (button as! UIButton).setImage(#imageLiteral(resourceName: "button1_pressed"), for: .highlighted)
//
//                case 2, 6:
//                    (button as! UIButton).setImage(#imageLiteral(resourceName: "button2_normal"), for: .normal)
//                    (button as! UIButton).setImage(#imageLiteral(resourceName: "button2_pressed"), for: .selected)
//                    (button as! UIButton).setImage(#imageLiteral(resourceName: "button2_pressed"), for: .highlighted)
//
//                case 3, 7:
//                    (button as! UIButton).setImage(#imageLiteral(resourceName: "button3_normal"), for: .normal)
//                    (button as! UIButton).setImage(#imageLiteral(resourceName: "button3_pressed"), for: .selected)
//                    (button as! UIButton).setImage(#imageLiteral(resourceName: "button3_pressed"), for: .highlighted)
//
//                default:
//                    fatalError("Button tag reached out of range")
//                }
//            }
//        }
//    }
//
////    func registerSilderUpdate(){
////        let interval = CMTimeMake(1, 60)
////        timeObserverToken = viewModel.player.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) { [unowned self] time in
////            if !self.videoProgressSlider.isTracking{
////                let timeElapsed = Float(CMTimeGetSeconds(time))
////                self.videoProgressSlider.value = Float(timeElapsed)
////            }
////        }
//    }
    
//    func removeSilderUpdate(){
//        if let timeObserverToken = timeObserverToken {
//            viewModel.player.removeTimeObserver(timeObserverToken)
//            self.timeObserverToken = nil
//        }
//    }
    
    @objc func tappedScreen(_ sender: UITapGestureRecognizer) {
        print("screen is tapped")
        if viewModel.player.isPlaying {
            viewModel.player.pause()
        }
        else{
            viewModel.player.play()
        }
    }
    
//    @objc func onSliderValChanged(slider: UISlider, event: UIEvent) {
//        if let touchEvent = event.allTouches?.first {
//            switch touchEvent.phase {
//            case .began:
//            // handle drag began
//            viewModel.player.pause()
//            case .ended:
//            // handle drag ended
//            viewModel.player.play()
//            default:
//                break
//            }
//        }
//    }
   
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view == videoPlayerView
    }
    
    
//    func triggerButtonEffects(_ button:UIButton){
//        let tag: Int = button.tag
//        if let duration = viewModel.playerDuration(atIndex: tag){
//            button.applyPressedArcadeEffects(withColor: UIColor.init(rgb: 0x47D3FF), durationTime: duration, completionHandler: { (tag) in
//                // Do something here
//            })
//        }
//    }

    
    // MARK: - Outlet Actions
    
//    @IBAction func soundBoardButtonPressed(_ sender: UIButton) {
//        viewModel.playAudioAtIndex(sender.tag)
//        viewModel.insertTracks(atIndex: sender.tag)
//        triggerButtonEffects(sender)
//    }
    
    @IBAction func dismiss(_ sender: Any) {
        viewModel.player.pause()
        if let url = viewModel.contentURL{
            BMDefaultContentFileServiceManager.shared.removeContent(at: url, { (error, url) in
                //Do something
            })
        }
        self.dismiss(animated: true) {
            //do something
        }
    }
    @IBAction func saveVideo(_ sender: Any) {
        self.uploadToCloudButton.isUserInteractionEnabled = false
        if let url = viewModel.contentURL{
            let activityItems = [url, "Check out this video I just made!" ] as [Any]
            let activityController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
            activityController.completionWithItemsHandler = {(activityType: UIActivityType?, completed: Bool, returnedItems: [Any]?, error: Error?) in
                if !completed {
                    // User canceled
                    print("cancelled sending")
                    self.uploadToCloudButton.isUserInteractionEnabled = true
                    return
                }
                // User completed activity
                print("finished sending")
                self.uploadToCloudButton.isUserInteractionEnabled = true
            }
            
            activityController.popoverPresentationController?.sourceView = self.view
            activityController.popoverPresentationController?.sourceRect = self.view.frame
            self.present(activityController, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func uploadToCloudPressed(_ sender: UIButton) {
        if let url = viewModel.contentURL {
            if uploadButtonState == UploadButtonState.beforeUpload {
                uploadButtonState = UploadButtonState.uploading
                let uploadRealmQueue = DispatchQueue(
                    label: "uploadCloudVideoQueue",
                    attributes: .concurrent)
                VideoObjectProvider.sharedProvider.uploadToCloud(localVideoUrl: url, uploadRealmQueue, { [weak self] (params, err) in
                    guard let strongSelf = self else {
                        return
                    }
                    if err == nil, let params = params {
                        APIServiceManager.sharedInstance.postToHypeCam(with: params, queue: DispatchQueue.main, completionCallback: { (hypeCamURL, error) in
                            if let webURL = hypeCamURL {
                                if webURL.count > 0 {
                                    strongSelf.shareLink = webURL
                                    strongSelf.uploadButtonState = UploadButtonState.uploaded
                                }
                                else {
                                    strongSelf.uploadButtonState = UploadButtonState.beforeUpload
                                }
                            }
                            else {
                                strongSelf.uploadButtonState = UploadButtonState.beforeUpload
                            }
                        })
                    }
                    else {
                        DispatchQueue.main.async {
                           strongSelf.uploadButtonState = UploadButtonState.beforeUpload
                        }
                    }
                })
            }
            else if uploadButtonState == UploadButtonState.uploaded {
                DispatchQueue.main.async { [weak self] in
                    guard let strongSelf = self else { return }
                    UIPasteboard.general.string = strongSelf.shareLink
                    strongSelf.uploadButtonState = UploadButtonState.linkCopied
                }
            }
        }
    }
    
    @IBAction func doneEditingPressed(_ sender: Any) {
        viewModel.player.pause()
        viewModel.processTracks { (url, error) in
            DispatchQueue.main.async {
                print("Finshed processing!")
            }
        }
    }
    
//    @IBAction func sliderChanged(_ sender: UISlider) {
//        print("changing: \(sender.value)")
//        viewModel.currentTime = Double(sender.value)
//    }
    
//    @IBAction func boardsPressed(_ sender: Any) {
//        viewModel.player.pause()
//        self.performSegue(withIdentifier: "fromEditingToBoards", sender: self)
//    }
//
    
    // MARK: - BMSoundBoardsViewControllerDelegate
    
//    func didSelectSoundBoard(_ soundBoad: BMSoundBoard) {
//        viewModel.selectedBoard = soundBoad
//    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "fromEditingToBoards"{
            guard let destinationVC = segue.destination as? BMSoundBoardsViewController else{
                fatalError("fromCamerViewToSoundBoardsView gone wrong")
            }
//            destinationVC.delegate = self
//            destinationVC.viewModel.selectedSoundBoardId = viewModel.selectedBoard?.id
        }
    }
 
    
    deinit {
        print("deinit editing view")
        NotificationCenter.default.removeObserver(self, name: Notification.Name.AVAudioSessionRouteChange, object: nil)
    }

}

extension AVPlayer {
    var isPlaying: Bool {
        return rate != 0 && error == nil
    }
}
