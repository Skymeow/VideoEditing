//
//  BMLocalFileServiceManager.swift
//  ProjectBM
//
//  Created by Jiahe Kuang on 12/6/17.
//  Copyright © 2017 JHK_Development. All rights reserved.
//

import Foundation

enum BMContentSource {
    case LocalDocsDirectory
    case LocalPhotoLibrary
    case LocalSharedAppContainer
    case RemoteDataSource
}

enum BMContentType {
    case RawVideo
    case RawSound
    case ProcessedVideo
    case ProcessedSound
}

protocol BMContentFileServiceManager {
    func removeContent(at url: URL, _ completionHandler: @escaping (Error?, Any?) -> ())
    func loadContents(_ type: BMContentType, _ source: BMContentSource, at path: URL?, _ completionHanlder: @escaping (Error?, Any?, BMContentSource)->())
}
