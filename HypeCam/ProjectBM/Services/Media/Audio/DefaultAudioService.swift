//
//  DefaultRecordingService.swift
//  ProjectBM
//
//  Created by Jiahe Kuang on 4/15/18.
//  Copyright © 2018 JHK_Development. All rights reserved.
//

import Foundation
final class DefaultAudioService: AudioService {
    
    static let sharedInstance = DefaultAudioService()
    private let recordingStrategy: RecordingStrategy
    
    // AudioService could have different audio related tasks and corresponding strategies
    private init() {
        recordingStrategy = DefaultRecordingStrategy()
    }
    
    func startRecording(for target: String?, callBackQueue queue: DispatchQueue, completionCallBack callBack: @escaping (AudioRecordingResult) -> Void) {
        let mediaTarget = target ?? "user_recording_\(RecordingTimeKey(Date().timeIntervalSince1970))"
        
        recordingStrategy.startRecording(for: mediaTarget, callBackQueue: queue, completionCallBack: callBack)
    }
    
    func stopRecording(callBackQueue queue: DispatchQueue,
                       completionCallBack callBack: @escaping (AudioRecordingResult)->Void) {
        recordingStrategy.stopRecording(callBackQueue: queue, completionCallBack: callBack)
    }
    
}
