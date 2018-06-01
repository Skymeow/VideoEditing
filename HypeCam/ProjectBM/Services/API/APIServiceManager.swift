//
//  APIServiceManager.swift
//  ProjectBM
//
//  Created by Jiahe Kuang on 5/2/18.
//  Copyright © 2018 JHK_Development. All rights reserved.
//

import Foundation
import Alamofire
final class APIServiceManager {
    static let sharedInstance = APIServiceManager()
    private init() {}
    
    func postToHypeCam(with params: [String:String], queue: DispatchQueue, completionCallback: @escaping (String?, Error?) -> Void) {

        DispatchQueue.global().async {
            Alamofire.request("http://www.hypecam.io/hype/video",  method: .post, parameters: params, encoding: JSONEncoding.default).responseJSON(completionHandler: { (response) in
                queue.async {
                    if let json = response.result.value {
                        if let res = json as? [String:String] {
                            print("URL: \(res["webUrl"] ?? "Error")")
                            if let url = res["webUrl"]  {
                                completionCallback(url, nil)
                            }
                        }
                        else {
                            completionCallback(nil, nil)
                        }
                    }
                }
            })

        }
    }
}
