//
//  GifServiceManager.swift
//  ProjectBM
//
//  Created by Sky Xu on 4/6/18.
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
    
    func getTrendingGify(callbackQueue: DispatchQueue, completion: @escaping ([Gif]?, Error?) -> ()) {
        let baseUrl = "https://api.giphy.com/v1/gifs/trending"
        let params = [
            "api_key":"I2KENcVhowMf11pBaABXlHTNVQwmIWjS",
            "limit":"9",
            ]

        gifySearchQueue.async {
            Alamofire.request(baseUrl, method: .get, parameters: params)
                .validate(statusCode: 200..<300)
                .responseJSON{ (response) in
                if response.result.error == nil {
                    guard let json = response.result.value as? [String: Any] else { return }
                    let data = json["data"] as AnyObject
                    let mp4s = data.value(forKeyPath: "images.original_mp4.mp4") as! [Any]
                    let gifs = data.value(forKeyPath: "images.preview_gif.url") as! [Any]
                    var gifObjects = [Gif]()
                    for i in 0 ..< 9 {
                        let gifObject = Gif(gifUrl: mp4s[i] as! String, gifPreviewUrl: gifs[i] as! String)
                        gifObjects.append(gifObject)
                    }
                    callbackQueue.async {
                        completion(gifObjects, nil)
                    }
                }
            }
        }
    }
    
    func searchGify(keyWord: String, callbackQueue: DispatchQueue, completion: @escaping ([Gif]?, Error?) -> ()) {
        let baseUrl = "https://api.giphy.com/v1/gifs/search"
        let params = [
            "api_key":"I2KENcVhowMf11pBaABXlHTNVQwmIWjS",
            "limit":"15",
            "q": keyWord
            ]
        
        gifyQueue.async {
            Alamofire.request(baseUrl, method: .get, parameters: params)
                .validate(statusCode: 200..<300)
                .responseJSON{ (response) in
                    if response.result.error == nil {
                        guard let json = response.result.value as? [String: Any] else { return }
                        let data = json["data"] as AnyObject
                        let mp4s = data.value(forKeyPath: "images.original_mp4.mp4") as! [Any]
                        let gifs = data.value(forKeyPath: "images.preview_gif.url") as! [Any]
                        var gifObjects = [Gif]()
                        for i in 0 ..< 15 {
                            let gifObject = Gif(gifUrl: mp4s[i] as! String, gifPreviewUrl: gifs[i] as! String)
                            gifObjects.append(gifObject)
                        }
                        callbackQueue.async {
                            completion(gifObjects, nil)
                        }
                    }
            }
        }
    }
}
