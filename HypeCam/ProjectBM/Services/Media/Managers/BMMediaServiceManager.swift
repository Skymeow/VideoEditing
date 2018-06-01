//
//  BMMediaManager.swift
//  ProjectBM
//
//  Created by Jiahe Kuang on 11/24/17.
//  Copyright © 2017 JHK_Development. All rights reserved.
//

import Foundation
protocol BMMediaServiceManager {
    func mergeContents(_ audioURL:URL?, _ videoURL:URL, _ fileTitle:String,  _ completionCallBack: @escaping (URL?,Error?)->())
    
    func mergeAudioFiles(_ audioFileNames: [String], _ outputFileName: String, _ completionCallback: @escaping (URL?, Error?)->())
    
    func mergeAudioFiles(_ intervalMap:[String:[Double]]?, _ outputFileName: String, _ completionCallback: @escaping (URL?, Error?)->())
    
    func mixAudiTracks(with intervalMap:[String:[Double]], with recordedAudioURL: URL, _ completionCallback: @escaping (URL?, Error?)-> Void)
}
