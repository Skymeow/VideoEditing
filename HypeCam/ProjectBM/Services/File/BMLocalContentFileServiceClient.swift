//
//  BMLocalContentFileServiceClient.swift
//  ProjectBM
//
//  Created by Jiahe Kuang on 12/23/17.
//  Copyright © 2017 JHK_Development. All rights reserved.
//

import Foundation



class BMLocalContentFileServiceClient: BMContentFileSericeClient {
    
    func loadContents(_ type: BMContentType, _ source: BMContentSource, at path: URL?, _ completionHanlder: @escaping (Error?, Any?, BMContentSource) -> ()) {
        getLocalContents(type, source, completionHanlder)
    }
    
    func deleteContent(at url: URL, _ completionHandler: @escaping (Error?, Any?) -> ()) {
        let fileManager = FileManager.default
        do {
            try fileManager.removeItem(at: url)
            completionHandler(nil, url)
        } catch {
            completionHandler(error, url)
        }
    }
    
    fileprivate func getLocalContents(_ type: BMContentType, _ source: BMContentSource, _ completionHanlder: @escaping (Error?, Any?, BMContentSource) -> () ){
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        do {
            var fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            // process files
            var contentFilterString = ""
            switch type {
            case .RawVideo:
                contentFilterString = "raw"
            case .ProcessedVideo:
                contentFilterString = "edited"
            default:
                break
            }
            fileURLs = fileURLs.filter{$0.lastPathComponent.range(of: contentFilterString) != nil }
            completionHanlder(nil, fileURLs, source)
        } catch {
            completionHanlder(error, nil, source)
        }
    }
}
