//
//  BMLocalContentFileServiceManager.swift
//  ProjectBM
//
//  Created by Jiahe Kuang on 12/23/17.
//  Copyright © 2017 JHK_Development. All rights reserved.
//

import Foundation
class BMDefaultContentFileServiceManager: BMContentFileServiceManager {

    static public let shared = BMDefaultContentFileServiceManager()
    private let contentFileServiceClient: BMContentFileSericeClient
    
    private init(){
        contentFileServiceClient = BMLocalContentFileServiceClient()
    }
    
    func loadContents(_ type: BMContentType, _ source: BMContentSource, at path: URL?, _ completionHanlder: @escaping (Error?, Any?, BMContentSource) -> ()) {
        contentFileServiceClient.loadContents(type, source, at: path, completionHanlder)
    }
    
    func removeContent(at url: URL, _ completionHandler: @escaping (Error?, Any?) -> ()) {
        contentFileServiceClient.deleteContent(at: url) { (error, deletedContent) in
            completionHandler(error, deletedContent)
        }
    }

}
