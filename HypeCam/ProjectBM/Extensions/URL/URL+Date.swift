//
//  URL+Date.swift
//  ProjectBM
//
//  Created by Jiahe Kuang on 12/24/17.
//  Copyright © 2017 JHK_Development. All rights reserved.
//

import Foundation
extension URL{
    func creationDate() throws -> Date{
        do {
            let attrs = try FileManager.default.attributesOfItem(atPath: self.path)
            return attrs[FileAttributeKey.creationDate] as! Date
        } catch {
            throw error
        }
    }
}
