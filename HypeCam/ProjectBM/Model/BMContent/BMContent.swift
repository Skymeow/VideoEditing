//
//  BMMediaContent.swift
//  ProjectBM
//
//  Created by Jiahe Kuang on 12/24/17.
//  Copyright © 2017 JHK_Development. All rights reserved.
//

import Foundation

protocol BMContent {
    var id: String? {set get}
    var description: String? {set get}
    var path: URL? {set get}
    var name: String {set  get}
    var type: BMContentType {set get}
    var source: BMContentSource {set get}
    var creationDate: Date {set get}
}
