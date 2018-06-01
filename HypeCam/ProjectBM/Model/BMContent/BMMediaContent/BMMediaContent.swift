//
//  BMMediaContent.swift
//  ProjectBM
//
//  Created by Jiahe Kuang on 12/24/17.
//  Copyright © 2017 JHK_Development. All rights reserved.
//

import Foundation
class BMMediaContent: BMContent {
    
    var id: String?
    
    var path: URL?
    
    var name: String
    
    var type: BMContentType
    
    var source: BMContentSource
    
    var creationDate: Date
    
    var description: String?

    init(id contentId: String?, description contentDescription: String?, path contentPath: URL?, name contentName:String, type contentType: BMContentType, source contentSource: BMContentSource, creationDate contentCreationDate: Date) {
        id = contentId
        path = contentPath
        name = contentName
        type = contentType
        source = contentSource
        creationDate = contentCreationDate
        description = contentDescription
    }
    
    convenience init(from url: URL, forType type: BMContentType, in source: BMContentSource, withDescription description: String?) {
        let name = url.lastPathComponent
        var date: Date
        do {
            date = try url.creationDate()
        } catch {
            date = Date()
        }
        self.init(id: nil, description: description , path: url, name: name, type: type, source: source, creationDate: date)
    }
}
