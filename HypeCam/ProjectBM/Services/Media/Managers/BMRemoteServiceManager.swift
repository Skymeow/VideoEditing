//
//  BMServiceManager.swift
//  ProjectBM
//
//  Created by Sky Xu on 3/7/18.
//  Copyright © 2018 JHK_Development. All rights reserved.
//
import Foundation
import RealmSwift

protocol BMRemoteServiceManager {
    func upload(_ videoObject: VideoObject, queue: DispatchQueue, completion: @escaping(Any?, Error?) -> Void)
    
    func download(route: Route, queue: DispatchQueue, completion: @escaping(Any?, Error?) -> Void)
}

protocol BMGifyServiceManager {
    func getTrendingGify(offset: Int, callbackQueue: DispatchQueue, completion: @escaping ([Gif]?, Error?) -> ())
    
    func searchGify(offset: Int, keyWord: String, callbackQueue: DispatchQueue, completion: @escaping ([Gif]?, Error?) -> ())
}
