//
//  UserDefaultServiceClient.swift
//  ProjectBM
//
//  Created by Jiahe Kuang on 3/7/18.
//  Copyright © 2018 JHK_Development. All rights reserved.
//

import Foundation

class UserDefaultServiceClient: UserServiceClient {
    
    fileprivate let defaults:UserDefaults = UserDefaults.standard

    func loadSoundBoardId() -> String {
        guard let lastUsedSoundBoardId = defaults.object(forKey: Constants.Last_Used_SoundBoard_Id) as? String else {
            return Constants.Default_SoundBoard_Id
        }
        return lastUsedSoundBoardId
    }
    
    func saveSoundBoardId(_ soundBoardId: String) {
        defaults.set(soundBoardId, forKey: Constants.Last_Used_SoundBoard_Id)
    }
}
