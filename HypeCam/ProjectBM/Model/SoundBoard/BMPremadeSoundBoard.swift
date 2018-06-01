//
//  File.swift
//  ProjectBM
//
//  Created by Jiahe Kuang on 12/6/17.
//  Copyright © 2017 JHK_Development. All rights reserved.
//

import Foundation
class BMPremadeSoundBoard: BMSoundBoard, Codable {
    
    
    var id: String
    var title: String
    var description: String
    var isInUse: Bool
    let isCustomizable: Bool = false

    
    init(id boardId: String, title boardTitle: String, description boardDescription: String, isInUse isBoardInUse: Bool) {
        id = boardId
        title = boardTitle
        description = boardDescription
        isInUse = isBoardInUse
    }
}
