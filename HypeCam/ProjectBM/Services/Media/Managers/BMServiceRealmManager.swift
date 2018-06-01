
//  BMServiceRealmManager.swift
//  ProjectBM
//
//  Created by Sky Xu on 3/7/18.
//  Copyright © 2018 JHK_Development. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class BMServiceRealmManager {
    
    static let instance = BMServiceRealmManager()
    
    func configureRealm(completion: @escaping (Realm) -> Void){
        let credentials = SyncCredentials.nickname("yournickname", isAdmin: true)
        SyncUser.logIn(with: credentials,
                       server: Keys.AUTH_URL) { [weak self] (user, error) in
                        if error == nil {
                            let syncConfig = SyncConfiguration(user: user!, realmURL: Keys.REALM_URL)
                            //            link videoobject with realm cloud
                            let realm = try! Realm(configuration: Realm.Configuration(syncConfiguration: syncConfig, objectTypes:[VideoObject.self]))
                            completion(realm)
                        }
        }
    }
    
}
