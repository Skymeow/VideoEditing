//
//  DefaultRecordingStrategy.swift
//  ProjectBM
//
//  Created by Jiahe Kuang on 4/15/18.
//  Copyright © 2018 JHK_Development. All rights reserved.
//

import Foundation
final class DefaultRecordingStrategy: RecordingStrategy {
    func startRecording(for target: String, callBackQueue queue: DispatchQueue, completionCallBack callBack: @ escaping (AudioRecordingResult) -> Void) {
        guard let destinationURL = getRecordingDestinationURL(for: target) else {
            queue.async {
                callBack(AudioRecordingResult(error: .URLError))
            }
            return
        }
        DefaultAudioRecordingManager.sharedInstance.statRecording(saveTo: destinationURL, callBackQueue: queue, completionCallBack: callBack)
    }
    
    func stopRecording(callBackQueue queue: DispatchQueue,
                       completionCallBack callBack: @escaping (AudioRecordingResult)->Void) {
        DefaultAudioRecordingManager.sharedInstance.stopRecording(callBackQueue: queue, completionCallBack: callBack)
    }
    
    
    // Within the context of the this recording strategy, we decided to use the cached directory to save our recorded file
    fileprivate func getRecordingDestinationURL(for target: String) -> URL? {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        guard let docDir = paths.first else { return nil }
        return docDir.appendingPathComponent("\(target).m4a")
    }
}
