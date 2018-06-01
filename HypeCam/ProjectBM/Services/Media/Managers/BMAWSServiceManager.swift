//
//  BMRemoteMediaServiceManager.swift
//  ProjectBM
//
//  Created by Sky Xu on 3/7/18.
//  Copyright © 2018 JHK_Development. All rights reserved.
//
import Foundation
import UIKit
import AWSCore
import AWSS3

//change this into aws service manager calss
class BMAWSServiceManager {
    
    public static let shared = BMAWSServiceManager()
    private let awsQueue = DispatchQueue( label: "awsQueue",
                                          attributes: .concurrent)
    let transferManager = AWSS3TransferManager.default()
    
    //    get back url from uplodaing thumbnil to cloud
    func uploadVideoThumbnil(from url: URL, callbackQueue: DispatchQueue, completion: @escaping (String?, Error?) -> ()) {
        var s3URL: String!
        let key = UUID().uuidString
        let thumbnil = UIImage.getVideoPreview(atPath: url)
        let thumbnilData = UIImagePNGRepresentation(thumbnil!)
        let tempUrl = URL(fileURLWithPath: NSTemporaryDirectory())
        let thumbnilUrl = tempUrl.appendingPathComponent("temp")
        do {
            try thumbnilData?.write(to: thumbnilUrl)
        } catch {
            print("save thumbnildata to temp failed")
        }
        
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        
        uploadRequest!.bucket = "please create a bucket on aws"
        uploadRequest!.key = key
        uploadRequest!.body = thumbnilUrl
        uploadRequest!.contentType = "image/png"
        uploadRequest!.acl = .publicRead
        
        self.awsQueue.async {
            self.transferManager.upload(uploadRequest!).continueWith { (task) -> Any? in
                if let error = task.error {
                    print("upload failed \(error)")
                }
                if task.result != nil {
                    s3URL = "https://s3.amazonaws.com/please create a bucket on aws/\(key)"
                    completion(s3URL, task.error)
                }
                else {
                    print("Unexpected empty result.")
                }
                
                return s3URL
            }
        }
        
    }
    
    func uploadVideo(from url: URL,callbackQueue: DispatchQueue,  completion: @escaping (String?, Error?) -> ()) {
        var s3URL: String!
        let key = UUID().uuidString
        let uploadRequest = AWSS3TransferManagerUploadRequest()
        
        uploadRequest!.bucket = "please create a bucket on aws"
        uploadRequest!.key = key
        uploadRequest!.body = url
        uploadRequest!.contentType = "video/mp4"
        uploadRequest!.acl = .publicRead
        self.awsQueue.async {
            self.transferManager.upload(uploadRequest!).continueWith { (task) -> Any? in
                if let error = task.error {
                    print("upload failed \(error)")
                }
                if task.result != nil {
                    s3URL = "https://s3.amazonaws.com/please create a bucket on aws/\(key)"
                    completion(s3URL, task.error)
                }
                else {
                    print("Unexpected empty result.")
                }
                return s3URL
            }
        }
        
    }
}
