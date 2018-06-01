//
//  VideoObject.swift
//  ProjectBM
//
//  Created by Sky Xu on 3/7/18.
//  Copyright © 2018 JHK_Development. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class VideoObject: Object {
    @objc dynamic var thumbnil: String? = nil
    @objc dynamic var localUrl: String? = nil
    @objc dynamic var deviceId: String? = nil
    @objc dynamic var timestamp: Date = Date()
    @objc dynamic var objectId = UUID().uuidString
    
    override static func primaryKey() -> String? {
        return "objectId"
    }
}
