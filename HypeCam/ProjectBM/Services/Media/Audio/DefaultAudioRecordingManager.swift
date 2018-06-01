//
//  DefaultAudioRecordingManager.swift
//  ProjectBM
//
//  Created by Jiahe Kuang on 4/14/18.
//  Copyright © 2018 JHK_Development. All rights reserved.
//

import Foundation
import AVFoundation

final class DefaultAudioRecordingManager{
    static let sharedInstance = DefaultAudioRecordingManager()
    private var recordingSession: AVAudioSession = AVAudioSession.sharedInstance()
    private var audioRecorder: AVAudioRecorder!
    
    
    private init() { }
    
    public func requestPermission(queue: DispatchQueue,
                                  callBack: @escaping (AVAudioSession?, Error?)->Void) {
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [weak self] allowed in
                guard let strongSelf = self else { return }
                queue.async {
                    if allowed {
                        callBack(strongSelf.recordingSession, nil)
                    }
                    else {
                        callBack(nil, nil)
                    }
                }
            }
        }
        catch {
            queue.async {
                callBack(nil, error)
            }
        }
    }
    
    public func stopRecording(callBackQueue queue: DispatchQueue,
                              completionCallBack callBack: @escaping (AudioRecordingResult)->Void) {
        
        audioRecorder.stop()
        _ = try? recordingSession.setActive(false, with: AVAudioSessionSetActiveOptions.notifyOthersOnDeactivation)
        queue.async { [weak self] in
            guard let strongSelf = self else {
                callBack(AudioRecordingResult(error: .Unknown))
                return
            }
            callBack(AudioRecordingResult(value: strongSelf.audioRecorder.url))
        }
    }
    
    public func statRecording(saveTo url: URL,
                              callBackQueue queue: DispatchQueue,
                              completionCallBack callBack: @escaping (AudioRecordingResult)->Void) {
        
        requestPermission(queue: queue) {[weak self] (session, error) in
            guard let strongSelf = self else { return }
            if session != nil {
                let settings = [
                    AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                    AVSampleRateKey: 44100,
                    AVNumberOfChannelsKey: 1,
                    AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue
                ]
                
                do {
                    strongSelf.audioRecorder = try AVAudioRecorder(url: url, settings: settings)
                    strongSelf.audioRecorder.record()
                    queue.async {
                        callBack(AudioRecordingResult(value: url))
                    }
                } catch {
                    print(error.localizedDescription)
                    queue.async {
                        callBack(AudioRecordingResult(error: .Unknown))
                    }
                }

            }
        }
    }
}

