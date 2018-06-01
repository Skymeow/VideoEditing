//
//  BMDefaultMediaServiceClient.swift
//  ProjectBM
//
//  Created by Jiahe Kuang on 11/24/17.
//  Copyright © 2017 JHK_Development. All rights reserved.
//

import Foundation
import AVFoundation


//Implementation from Stackover Flow
class BMDefaultMediaServiceClient: BMMediaServiceClient {
    
    func removeContent(at url: URL?, _ completionHandler: @escaping (URL?, Error?) -> ()) {
        
    }
    
    func mixAudiTracks(with intervalMap: [String : [Double]], with recordedAudioURL: URL, _ completionCallback: @escaping (URL?, Error?) -> Void) {
        
        let outputFileName = "\(Int64(Date().timeIntervalSince1970))_mixed"

        var intervalMap = intervalMap
        
        // Sort all timestamp array in interval map because during looping of the video,
        // later added timestamps could have a smaller time before the previous one, and it will cause a negative time value
        // in the processing
        
        for key in intervalMap.keys{
            var timestamps = intervalMap[key]
            timestamps = timestamps?.sorted(by: <)
            intervalMap[key] = timestamps
        }
        
        let composition: AVMutableComposition = AVMutableComposition()
        var assetMap = [String:AVURLAsset]()
        var compositionTrackMap =  [String:AVMutableCompositionTrack]()
        //prepare data
        for key in intervalMap.keys{
            //Store compositionAudioTrack into map
            let compositionAudioTrack: AVMutableCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)!
            compositionTrackMap[key] = compositionAudioTrack
            
            //Extrac sound asset and store into map
            if let soundURL: String = Bundle.main.path(forResource: key, ofType: "mp3") {
                let url: URL = URL(fileURLWithPath: soundURL)
                let avAsset: AVURLAsset = AVURLAsset(url: url)
                assetMap[key] = avAsset
            }
            else if let soundURL = Bundle.main.path(forResource: key, ofType: "wav") {
                let url: URL = URL(fileURLWithPath: soundURL)
                let avAsset: AVURLAsset = AVURLAsset(url: url)
                assetMap[key] = avAsset
            }
            else {
                completionCallback(nil, nil)
                return
            }
        }
        
        let avAsset: AVURLAsset = AVURLAsset(url: recordedAudioURL)
        assetMap["recorded"] = avAsset
        intervalMap["recorded"] = [0.0]
        let compositionAudioTrack: AVMutableCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)!
        compositionTrackMap["recorded"] = compositionAudioTrack

        
        //Process each added sound track
        for key in intervalMap.keys{
            if let addedSoundTrackTimestamps = intervalMap[key]{
                if let avAsset = assetMap[key], let compositionAudioTrack = compositionTrackMap[key] {
                    // FIXME
                    var i = 0
                    for time in addedSoundTrackTimestamps{
                        var soundDuration = avAsset.duration
                        if i != 0{
                            let timeGap = time - addedSoundTrackTimestamps[i-1]
                            // FIXME: checking of the same sound was pressed during a pause
                            if timeGap < 0.0000001{
                                continue
                            }
                            let durationInSeconds = CMTimeGetSeconds(soundDuration)
                            if timeGap <= durationInSeconds{
                                soundDuration = CMTimeMakeWithSeconds(timeGap, 50000)
                            }
                        }
                        let timeRange: CMTimeRange = CMTimeRangeMake(kCMTimeZero, soundDuration)
                        let audioTrack: AVAssetTrack = avAsset.tracks(withMediaType: AVMediaType.audio)[0]
                        try! compositionAudioTrack.insertTimeRange(timeRange, of: audioTrack, at: CMTimeMakeWithSeconds(time, 50000))
                        i = i + 1
                    }
                }
            }
        }
        
        let exportPath: String = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].path+"/"+outputFileName+".m4a"
        
        let export: AVAssetExportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetAppleM4A)!
        
        export.outputURL = URL(fileURLWithPath: exportPath)
        export.outputFileType = AVFileType.m4a
        
        export.exportAsynchronously {
            if export.status == AVAssetExportSessionStatus.completed {
                completionCallback(export.outputURL, nil)
            }
            else{
                completionCallback(nil, BMMediaServiceError.MergeAudiosExportFail)
            }
        }

        
    }
    
    fileprivate func trimVideo(with tiltle: String, from  sourceURL: URL, startFrom: Float64, endAt: Float64, callBackQueue: DispatchQueue, completionCallback: @escaping (URL?, Error?)-> Void) {
        
        DispatchQueue.global().async{
            let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            
            let asset = AVAsset(url: sourceURL)
            
            let outputURL = documentsURL.appendingPathComponent("\(tiltle).mp4")
            
            guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else {return}
            exportSession.outputURL = outputURL
            exportSession.outputFileType = AVFileType.mp4
            
            let startTime = CMTime(seconds: Double(startFrom), preferredTimescale: 1000)
            let endTime = CMTime(seconds: Double(endAt), preferredTimescale: 1000)
            let timeRange = CMTimeRange(start: startTime, end: endTime)
            
            exportSession.timeRange = timeRange
            exportSession.exportAsynchronously{
                switch exportSession.status {
                case .completed:
                    callBackQueue.async {
                        completionCallback(outputURL, nil)
                    }
                case .cancelled, .failed:
                    callBackQueue.async {
                        completionCallback(nil, exportSession.error)
                    }
                default: break
                }
            }
        }
    }
    
    fileprivate func combine(_ videos: [URL], with fileTitle: String, queue: DispatchQueue, callBack: @escaping (URL?, Error?)->Void) {
        var videoAssets = [AVAsset]()
        for videoURL in videos {
            videoAssets.append(AVAsset(url: videoURL))
        }
        KVVideoManager.shared.merge(arrayVideos: videoAssets) { (url, error) in
            if let mergedVideoURL = url {
                callBack(mergedVideoURL, nil)
            }
            else {
                callBack(nil, error)
            }
        }
    }
    
    fileprivate func runGiftVideoProcessingStrategy(audioURL: URL, videoURL: URL, _ fileTitle:String, queue: DispatchQueue, _ completionCallBack: @escaping (URL?, Error?) -> ()) {
        let audioAsset: AVURLAsset = AVURLAsset(url: audioURL)
        let audioLength = CMTimeGetSeconds(audioAsset.duration)
        
        let videoAsset = AVAsset(url: videoURL)
        let videoLength = CMTimeGetSeconds(videoAsset.duration)

        if videoLength >= audioLength {
            queue.async {
                completionCallBack(videoURL, nil)
            }
        }
        else {
            // FIXMME: Make a better implementation than this
            var counter  = 1.0
            while ((videoLength * counter) < audioLength) {
                counter = counter + 1.0
            }
            let offset = audioLength - (videoLength * (counter-1.0))
            trimVideo(with: fileTitle, from: videoURL, startFrom: 0.0, endAt: offset, callBackQueue: DispatchQueue.global()) {[weak self] (url, error) in
                guard let strongSelf = self else { return }
                if let trimmedVideoURL = url {
                    var videos = [URL]()
                    for _ in 1...Int(counter-1.0) {
                        videos.append(videoURL)
                    }
                    videos.append(trimmedVideoURL)
                    strongSelf.combine(videos, with: fileTitle,  queue: DispatchQueue.global(), callBack: { (url, error) in
                        if let mergedVideoURL = url {
                            queue.async {
                                completionCallBack(mergedVideoURL, nil)
                            }
                        }
                        else {
                            queue.async {
                                completionCallBack(nil, error)
                            }
                        }
                    })
                }
                else {
                    queue.async {
                        completionCallBack(videoURL, nil)
                    }
                }
            }
        }
    }
        
    func mergeContents(_ audioURL: URL?, _ videoURL: URL, _ fileTitle:String, _ completionCallBack: @escaping (URL?, Error?) -> ()) {
        guard let soundURL = audioURL else {
          completionCallBack(videoURL, nil)
          return
        }
        
        runGiftVideoProcessingStrategy(audioURL: soundURL, videoURL: videoURL, fileTitle, queue: DispatchQueue.global()) { (url, error) in
            if let finalVideoURL = url {
                let mixComposition : AVMutableComposition = AVMutableComposition()
                var mutableCompositionVideoTrack : [AVMutableCompositionTrack] = []
                var mutableCompositionAudioTrack : [AVMutableCompositionTrack] = []
                var mutableCompositionBackTrack : [AVMutableCompositionTrack] = []
                
                let totalVideoCompositionInstruction : AVMutableVideoCompositionInstruction = AVMutableVideoCompositionInstruction()
                
                let audioMix: AVMutableAudioMix = AVMutableAudioMix()
                var audioMixParam: [AVMutableAudioMixInputParameters] = []
                
                //start merge
                
                let aVideoAsset : AVAsset = AVAsset(url: finalVideoURL)
                //FIX ME
                let aAudioAsset : AVAsset = AVAsset(url: soundURL)
                
                var videoOriginalAudioAssestTrack : AVAssetTrack? = nil
                if aVideoAsset.tracks(withMediaType: AVMediaType.audio).count > 0 {
                    videoOriginalAudioAssestTrack = aVideoAsset.tracks(withMediaType: AVMediaType.audio)[0]
                }
                
                
                mutableCompositionBackTrack.append(mixComposition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)!)
                
                mutableCompositionVideoTrack.append(mixComposition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid)!)
                
                mutableCompositionAudioTrack.append( mixComposition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)!)
                
                let aVideoAssetTrack : AVAssetTrack = aVideoAsset.tracks(withMediaType: AVMediaType.video)[0]
                let aAudioAssetTrack : AVAssetTrack = aAudioAsset.tracks(withMediaType: AVMediaType.audio)[0]
                
                //FIX ME
                //recorded sound
                if videoOriginalAudioAssestTrack != nil{
                    let recordedParam: AVMutableAudioMixInputParameters = AVMutableAudioMixInputParameters(track: videoOriginalAudioAssestTrack)
                    let recordedCompositionTrack = mutableCompositionBackTrack[0]
                    recordedParam.trackID = recordedCompositionTrack.trackID
                    recordedParam.setVolume(5.0, at: kCMTimeZero)
                    audioMixParam.append(recordedParam)
                }
                
                //added sound
                let musicParam: AVMutableAudioMixInputParameters = AVMutableAudioMixInputParameters(track: aAudioAssetTrack)
                let compositionTrack = mutableCompositionAudioTrack[0]
                musicParam.trackID = compositionTrack.trackID
                //set volume
                musicParam.setVolume(1.0, at: kCMTimeZero)
                //Add setting
                audioMixParam.append(musicParam)
                
                do{
                    
                    try mutableCompositionVideoTrack[0].insertTimeRange(CMTimeRangeMake(kCMTimeZero, aVideoAssetTrack.timeRange.duration), of: aVideoAssetTrack, at: kCMTimeZero)
                    
                    //In my case my audio file is longer then video file so i took videoAsset duration
                    //instead of audioAsset duration
                    
//                    try mutableCompositionAudioTrack[0].insertTimeRange(CMTimeRangeMake(kCMTimeZero, aVideoAssetTrack.timeRange.duration), of: aAudioAssetTrack, at: kCMTimeZero)
                    
                    if videoOriginalAudioAssestTrack != nil{
                        try mutableCompositionBackTrack[0].insertTimeRange(CMTimeRangeMake(kCMTimeZero, aVideoAssetTrack.timeRange.duration), of: videoOriginalAudioAssestTrack!, at: kCMTimeZero)
                    }
                    
                    
                    //Use this instead above line if your audiofile and video file's playing durations are same
                    
                    try mutableCompositionAudioTrack[0].insertTimeRange(CMTimeRangeMake(kCMTimeZero, aVideoAssetTrack.timeRange.duration), of: aAudioAssetTrack, at: kCMTimeZero)
                    
                }catch{
                    
                }
                
                //            //Add parameter
                audioMix.inputParameters = audioMixParam
                
                totalVideoCompositionInstruction.timeRange = CMTimeRangeMake(kCMTimeZero,aVideoAssetTrack.timeRange.duration )
                
                let mutableVideoComposition : AVMutableVideoComposition = AVMutableVideoComposition()
                mutableVideoComposition.frameDuration = CMTimeMake(1, 30)
                
                let assetVideoTrack = (aVideoAsset.tracks(withMediaType: AVMediaType.video)).last! as AVAssetTrack
                
                let compositionVideoTrack = (mixComposition.tracks(withMediaType: AVMediaType.video)).last! as AVMutableCompositionTrack
                
                if (assetVideoTrack.isPlayable && compositionVideoTrack.isPlayable) {
                    compositionVideoTrack.preferredTransform = assetVideoTrack.preferredTransform
                }
                
                let savePathUrl : URL = URL(fileURLWithPath: NSHomeDirectory() + "/Documents/\(fileTitle).mov")
                
                let assetExport: AVAssetExportSession = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality)!
                assetExport.outputFileType = AVFileType.mov
                assetExport.outputURL = savePathUrl
                assetExport.shouldOptimizeForNetworkUse = true
                assetExport.audioMix = audioMix
                
                assetExport.exportAsynchronously { () -> Void in
                    switch assetExport.status {
                    case AVAssetExportSessionStatus.completed:
                        completionCallBack(savePathUrl, nil)
                        print("success")
                    case  AVAssetExportSessionStatus.failed:
                        print("failed \(String(describing: assetExport.error))")
                        completionCallBack(nil, BMMediaServiceError.MergeVideoAudioExportFail)
                    case AVAssetExportSessionStatus.cancelled:
                        completionCallBack(nil, BMMediaServiceError.MergeVideoAudioExportCancel)
                    default:
                        print("complete")
                    }
                }
            }
        }
    }

    func mergeAudios(_ intervalMap: [String : [Double]]?, _ outputFileName: String, _ completionCallBack: @escaping (URL?, Error?) -> ()) {
        guard var soundMap = intervalMap else{
            completionCallBack(nil, nil)
            return
        }
        
        // Sort all timestamp array in interval map because during looping of the video,
        // later added timestamps could have a smaller time before the previous one, and it will cause a negative time value
        // in the processing
        
        for key in soundMap.keys{
            var timestamps = soundMap[key]
            timestamps = timestamps?.sorted(by: <)
            soundMap[key] = timestamps
        }
        
        let composition: AVMutableComposition = AVMutableComposition()
        var assetMap = [String:AVURLAsset]()
        var compositionTrackMap =  [String:AVMutableCompositionTrack]()
        //prepare data
        for key in soundMap.keys{
            //Store compositionAudioTrack into map
            let compositionAudioTrack: AVMutableCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)!
            compositionTrackMap[key] = compositionAudioTrack
            
            //Extrac sound asset and store into map
            if let soundURL: String = Bundle.main.path(forResource: key, ofType: "mp3") {
                let url: URL = URL(fileURLWithPath: soundURL)
                let avAsset: AVURLAsset = AVURLAsset(url: url)
                assetMap[key] = avAsset
            }
            else if let soundURL = Bundle.main.path(forResource: key, ofType: "wav") {
                let url: URL = URL(fileURLWithPath: soundURL)
                let avAsset: AVURLAsset = AVURLAsset(url: url)
                assetMap[key] = avAsset
            }
            else {
                completionCallBack(nil, nil)
                return
            }
        }
        
        //Process each added sound track
        for key in soundMap.keys{
            if let addedSoundTrackTimestamps = soundMap[key]{
                if let avAsset = assetMap[key], let compositionAudioTrack = compositionTrackMap[key] {
                    // FIXME
                    var i = 0
                    for time in addedSoundTrackTimestamps{
                        var soundDuration = avAsset.duration
                        if i != 0{
                            let timeGap = time - addedSoundTrackTimestamps[i-1]
                            // FIXME: checking of the same sound was pressed during a pause
                            if timeGap < 0.0000001{
                                continue
                            }
                            let durationInSeconds = CMTimeGetSeconds(soundDuration)
                            if timeGap <= durationInSeconds{
                                soundDuration = CMTimeMakeWithSeconds(timeGap, 50000)
                            }
                        }
                        let timeRange: CMTimeRange = CMTimeRangeMake(kCMTimeZero, soundDuration)
                        let audioTrack: AVAssetTrack = avAsset.tracks(withMediaType: AVMediaType.audio)[0]
                        try! compositionAudioTrack.insertTimeRange(timeRange, of: audioTrack, at: CMTimeMakeWithSeconds(time, 50000))
                        i = i + 1
                    }
                }
            }
        }
        
        let exportPath: String = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].path+"/"+outputFileName+".m4a"
        
        let export: AVAssetExportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetAppleM4A)!
        
        export.outputURL = URL(fileURLWithPath: exportPath)
        export.outputFileType = AVFileType.m4a
        
        export.exportAsynchronously {
            if export.status == AVAssetExportSessionStatus.completed {
                completionCallBack(export.outputURL, nil)
            }
            else{
                completionCallBack(nil, BMMediaServiceError.MergeAudiosExportFail)
            }
        }
    }
    
    /**
    / Deprecated
    */
    func mergeAudios(_ audioFileNames: [String], _ outputFileName: String, _ completionCallBack: @escaping (URL?, Error?) -> ()) {
        var startTime: CMTime = kCMTimeZero
        let composition: AVMutableComposition = AVMutableComposition()
        
        //Test prepare tracks
        var trackHash = [String:AVMutableCompositionTrack]()
        for audioFile in audioFileNames{
            if trackHash[audioFile] == nil{
                let compositionAudioTrack: AVMutableCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)!
                trackHash[audioFile] = compositionAudioTrack
            }
        }
        
        for fileName in audioFileNames {
            let compositionAudioTrack = trackHash[fileName]
            let sound: String = Bundle.main.path(forResource: fileName, ofType: "wav")!
            let url: URL = URL(fileURLWithPath: sound)
            let avAsset: AVURLAsset = AVURLAsset(url: url)
            //test
            let duration = avAsset.duration
            let timeRange: CMTimeRange = CMTimeRangeMake(kCMTimeZero, duration)
            let audioTrack: AVAssetTrack = avAsset.tracks(withMediaType: AVMediaType.audio)[0]
            
            if fileName == "test_1"{
                try! compositionAudioTrack?.insertTimeRange(timeRange, of: audioTrack, at: kCMTimeZero)
            }
            else if fileName == "test_4"{
                try! compositionAudioTrack?.insertTimeRange(timeRange, of: audioTrack, at: startTime)
                startTime = CMTimeAdd(startTime, CMTimeMake(1, 1))
            }
            else{
                try! compositionAudioTrack?.insertTimeRange(timeRange, of: audioTrack, at: kCMTimeZero)
            }
        }
        
        let exportPath: String = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].path+"/"+outputFileName+".m4a"
        
        let export: AVAssetExportSession = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetAppleM4A)!
        
        export.outputURL = URL(fileURLWithPath: exportPath)
        export.outputFileType = AVFileType.m4a
        
        export.exportAsynchronously {
            if export.status == AVAssetExportSessionStatus.completed {
                completionCallBack(export.outputURL, nil)
            }
            else{
                completionCallBack(nil, BMMediaServiceError.MergeAudiosExportFail)
            }
        }
    }
}
