//
//  BMDefaultMediaServiceManager.swift
//  ProjectBM
//
//  Created by Jiahe Kuang on 11/24/17.
//  Copyright © 2017 JHK_Development. All rights reserved.
//

import Foundation
class BMDefaultMediaServiceManager: BMMediaServiceManager {
    
    static public let shared = BMDefaultMediaServiceManager()
    private let mediaServiceClient: BMMediaServiceClient
    private init(){
        mediaServiceClient = BMDefaultMediaServiceClient()
    }
//    2. call this within callback of mergeaudio
    func mergeContents(_ audioURL: URL?, _ videoURL: URL, _ fileTitle:String, _ completionCallBack: @escaping (URL?, Error?) -> ()) {
        mediaServiceClient.mergeContents(audioURL, videoURL, fileTitle) { (url, error) in
            completionCallBack(url, error)
        }
    }
    
    func mergeAudioFiles(_ audioFileNames: [String], _ outputFileName: String, _ completionCallback: @escaping (URL?, Error?) -> ()) {
        mediaServiceClient.mergeAudios(audioFileNames, outputFileName) { (url, error) in
            completionCallback(url, error)
        }
    }
//   1.  call this
    func mergeAudioFiles(_ intervalMap: [String : [Double]]?, _ outputFileName: String, _ completionCallback: @escaping (URL?, Error?) -> ()) {
        mediaServiceClient.mergeAudios(intervalMap, outputFileName) { (url, error) in
            completionCallback(url, error)
        }
    }
    
    func mixAudiTracks(with intervalMap: [String : [Double]], with recordedAudioURL: URL, _ completionCallback: @escaping (URL?, Error?) -> Void) {
        mediaServiceClient.mixAudiTracks(with: intervalMap, with: recordedAudioURL) { (url, error) in
            completionCallback(url, error)
        }
    }
}
