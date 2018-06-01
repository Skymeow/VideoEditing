//
//  UserServiceClient.swift
//  ProjectBM
//
//  Created by Jiahe Kuang on 3/7/18.
//  Copyright © 2018 JHK_Development. All rights reserved.
//

import Foundation
protocol UserServiceClient {
    func loadSoundBoardId() -> String
    func saveSoundBoardId(_ soundBoardId: String)
}
