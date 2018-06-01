//
//  BMSoundBoard.swift
//  ProjectBM
//
//  Created by Jiahe Kuang on 12/4/17.
//  Copyright © 2017 JHK_Development. All rights reserved.
//

import Foundation
protocol BMSoundBoard {
    var id: String {get set}
    var title: String {get set}
    var description: String {get set}
    var isInUse: Bool {get set}
    var isCustomizable: Bool {get}
}
