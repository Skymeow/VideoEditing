//
//  BMRealmRemoteServiceManager.swift
//  ProjectBM
//
//  Created by Sky Xu on 3/21/18.
//  Copyright © 2018 JHK_Development. All rights reserved.
//

import Foundation
import RealmSwift
enum Route {
    case fetchAll
    case fetchPersonal
    
    func queryRealmObjects(realm: Realm) -> Results<VideoObject>? {
        switch self {
        case .fetchAll:
            let videoFeeds = realm.objects(VideoObject.self).sorted(byKeyPath: "timestamp", ascending: false)
            return videoFeeds
        case .fetchPersonal:
            let deviceId = (UIApplication.shared.delegate as! AppDelegate).identifierForVendor!
            let videoFeeds = realm.objects(VideoObject.self).filter(NSPredicate(format: "deviceId == %@",deviceId))
            return videoFeeds
        }
    }
}

class BMRealmRemoteServiceManager: BMRemoteServiceManager {
    
    public static let shared = BMRealmRemoteServiceManager()
    
    
    public func download(route: Route, queue: DispatchQueue, completion: @escaping (Any?, Error?) -> Void) {
        //                need to use background queue here caz the query is sync
        DispatchQueue.global(qos: .background).async {
            BMServiceRealmManager.instance.configureRealm { (realm) in
                let videoFeeds = route.queryRealmObjects(realm: realm)
                // completion backqueue been called
                queue.async {
                    completion(videoFeeds, nil)
                }
            }
        }
    }
    
    func upload(_ videoObject: VideoObject, queue: DispatchQueue, completion: @escaping (Any?, Error?) -> Void) {
        queue.async {
            BMServiceRealmManager.instance.configureRealm(completion: { (realm) in
                do {
                    try realm.write {
                        //  add realm to cloud
                        realm.add(videoObject)
                        completion(videoObject, nil)
                    }
                } catch let error {
                    print("uploading to realm occurs an err \(error)")
                }
            })
        }
    }
}
