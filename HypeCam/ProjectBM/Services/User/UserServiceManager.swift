//
//  UserServiceManager.swift
//  ProjectBM
//
//  Created by Jiahe Kuang on 3/7/18.
//  Copyright © 2018 JHK_Development. All rights reserved.
//

import Foundation
class UserServiceManger {
    static public let shared  = UserServiceManger()
    fileprivate let userServiceClient: UserServiceClient
    private init() {
        userServiceClient = UserDefaultServiceClient()
    }

    func loadStoredSoundBoardId() -> String {
        return userServiceClient.loadSoundBoardId()
    }

    func saveSoundBoard(_ soundBoardId: String) {
        userServiceClient.saveSoundBoardId(soundBoardId)
    }
}
