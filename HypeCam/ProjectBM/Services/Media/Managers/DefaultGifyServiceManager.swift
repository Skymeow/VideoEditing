//
//  DefaultGifyServiceManager.swift
//  ProjectBM
//
//  Created by Sky Xu on 4/11/18.
//  Copyright © 2018 JHK_Development. All rights reserved.
//

import Foundation
import Alamofire

class DefaultGifyServiceManager: BMGifyServiceManager {
    public static let shared = DefaultGifyServiceManager()
    private let gifyQueue = DispatchQueue( label: "gifyQueue",
                                           attributes: .concurrent)
    private let gifySearchQueue = DispatchQueue( label: "gifySearchQueue",
                                                 attributes: .concurrent)
    
    func getTrendingGify(offset: Int, callbackQueue: DispatchQueue, completion: @escaping ([Gif]?, Error?) -> ()) {
        let baseUrl = "https://api.giphy.com/v1/gifs/trending"
        let params = [
            "api_key":"I2KENcVhowMf11pBaABXlHTNVQwmIWjS",
            "limit":"15",
            "offset": "\(offset)"
            ]
        gifyQueue.async {
            Alamofire.request(baseUrl, method: .get, parameters: params)
                .validate(statusCode: 200..<300)
                .responseJSON{ (response) in
                    if response.result.error == nil {
                        guard let json = response.result.value as? [String: Any] else { return }
                        let data = json["data"] as AnyObject
                        let mp4s = data.value(forKeyPath: "images.original.mp4") as! [Any]
                        let gifs = data.value(forKeyPath: "images.original.url") as! [Any]
                        var gifObjects = [Gif]()
                        if mp4s.count != 0 {
                            for i in 0 ..< 14 {
                                guard let mp4 = mp4s[i] as? String, let gifPreviewUrl = gifs[i] as? String else { let gifPreviewUrl = "https://media3.giphy.com/media/9xrvtG9ihZjoEcEX8z/giphy.gif"; return }
                                let gifObject = Gif(gifUrl: mp4, gifPreviewUrl: gifPreviewUrl)
                                gifObjects.append(gifObject)
                            }
                            callbackQueue.async {
                                completion(gifObjects, nil)
                            }
                       } else {
                            callbackQueue.async {
                                completion(nil, nil)
                            }
                       }
                    }
            }
        }
    }
    
    func searchGify(offset: Int, keyWord: String, callbackQueue: DispatchQueue, completion: @escaping ([Gif]?, Error?) -> ()) {
        let baseUrl = "https://api.giphy.com/v1/gifs/search"
        let params = [
            "api_key":"I2KENcVhowMf11pBaABXlHTNVQwmIWjS",
            "limit":"15",
            "q": keyWord,
            "offset": "\(offset)"
        ]
        
        gifySearchQueue.async {
            Alamofire.request(baseUrl, method: .get, parameters: params)
                .validate(statusCode: 200..<300)
                .responseJSON{ (response) in
                    if response.result.error == nil {
                        guard let json = response.result.value as? [String: Any] else { return }
                        let data = json["data"] as AnyObject
                        let mp4s = data.value(forKeyPath: "images.original.mp4") as! [Any]
                        let gifs = data.value(forKeyPath: "images.original.url") as! [Any]
                        var gifObjects = [Gif]()
                        if mp4s.count != 0 {
                            for i in 0 ..< 14 {
                                guard let mp4 = mp4s[i] as? String, let gifPreviewUrl = gifs[i] as? String else { return }
                                let gifObject = Gif(gifUrl: mp4, gifPreviewUrl: gifPreviewUrl)
                                gifObjects.append(gifObject)
                                
                            }
                            callbackQueue.async {
                                completion(gifObjects, nil)
                            }
                        } else {
                            completion(nil, nil)
                        }
                    }
            }
        }
    }
}
