//
//  AudioService.swift
//  ProjectBM
//
//  Created by Jiahe Kuang on 4/14/18.
//  Copyright © 2018 JHK_Development. All rights reserved.
//

import Foundation
protocol AudioService {
    // target is the identifier of the intended editing media item
    func startRecording(for target: String?,
                        callBackQueue queue: DispatchQueue,
                        completionCallBack callBack: @escaping (AudioRecordingResult)->Void)
    
    func stopRecording(callBackQueue queue: DispatchQueue,
                       completionCallBack callBack: @escaping (AudioRecordingResult)->Void)
}
