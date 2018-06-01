//
//  VideoObjectProvider.swift
//  ProjectBM
//
//  Created by Sky Xu on 3/7/18.
//  Copyright © 2018 JHK_Development. All rights reserved.
//
import Foundation
import UIKit
import RealmSwift

class VideoObjectProvider {
    
    static let sharedProvider = VideoObjectProvider()
    fileprivate let remoteServiceManager: BMRemoteServiceManager
    private init(){
        remoteServiceManager = BMRealmRemoteServiceManager.shared
    }
    let deviceId = (UIApplication.shared.delegate as! AppDelegate).identifierForVendor
    
    //    FIXME: fetching from remote(realm), change into Result<>
    public func fetchFromRemote(_ route: Route, _ callbackQueue: DispatchQueue, _ completion: @escaping(Results<VideoObject>?, Error?) -> Void) {
        
        remoteServiceManager.download(route: route, queue: callbackQueue) { (videoFeeds, err) in
            if err == nil {
                callbackQueue.async {
                    completion(videoFeeds as! Results<VideoObject>, nil)
                }
            }
        }
    }
    
    private func createVideoObject(localVideoUrl: URL, _ callbackQueue: DispatchQueue, _ completion: @escaping(String, String, Error?) -> ()) {
        callbackQueue.async {
            //
            let ServiceManagerQueue = DispatchQueue(label: "createVideoObject", attributes: .concurrent)
            BMAWSServiceManager.shared.uploadVideo(from: localVideoUrl, callbackQueue: ServiceManagerQueue) { (videoRemoteUrl, error) in
                if error == nil {
                    //        get video thumbnil from s3
                    BMAWSServiceManager.shared.uploadVideoThumbnil(from: localVideoUrl, callbackQueue: ServiceManagerQueue) {(thumbnilRemoteUrl, error) in
                        if error == nil {
                            ServiceManagerQueue.async {
                                completion(videoRemoteUrl!, thumbnilRemoteUrl!, error)
                            }
                        }
                    }
                }
            }
        }
    }
    
    public func uploadToCloud(localVideoUrl: URL, _ callbackQueue: DispatchQueue, _ completion: @escaping ([String:String]?, Error?) -> Void) {
        let uploadQueue = DispatchQueue(
            label: "uploadRealmQueue",
            attributes: .concurrent)
        self.createVideoObject(localVideoUrl: localVideoUrl, callbackQueue) { (videoString, thumbnilString, err)  in
            //      upload the video object to realm cloud
            let a = VideoObject()
            a.deviceId = self.deviceId
            a.localUrl = videoString
            a.thumbnil = thumbnilString
            a.timestamp = Date()
            
            //            cal realm remote service manager to upload video object to realm cloud
            self.remoteServiceManager.upload(a, queue: uploadQueue, completion: { (realmObjc, err) in
                if err == nil {
                    //                    FIXME: rename it into callback queue
                    uploadQueue.async {
                        completion(["url": videoString,
                                    "thumbnail": thumbnilString], nil)
                    }
                    
                } else {
                    uploadQueue.async {
                        completion(nil, err)
                    }
                }
            })
            
        }
    }
    
}
