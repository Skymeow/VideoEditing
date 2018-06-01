//
//  BMUserVideosViewModel.swift
//  ProjectBM
//
//  Created by Jiahe Kuang on 12/22/17.
//  Copyright © 2017 JHK_Development. All rights reserved.
//

import Foundation
import UIKit


class BMUserVideosViewModel {
    
    fileprivate let sharedFileContentManager: BMContentFileServiceManager = BMDefaultContentFileServiceManager.shared
    fileprivate var contentArray = [BMContent]()
    fileprivate var contentPreviewImageCache = [URL: UIImage]()
    
    var contentCount: Int {
        return contentArray.count
    }

    fileprivate func generateContentPreviews(for urls: [URL]){
        for url in urls{
            if contentPreviewImageCache[url] == nil{
                if let image = UIImage.getVideoPreview(atPath: url){
                    contentPreviewImageCache[url] = image
                }
            }
        }
    }
    
    fileprivate func processContents(sources urls: [URL], forType type:BMContentType){
        contentArray.removeAll()
        for url in urls{
            let content = BMMediaContent(from: url, forType: type, in: .LocalDocsDirectory, withDescription: nil)
            contentArray.append(content)
        }
        _ = contentArray.sort(by: {$0.creationDate > $1.creationDate})
    }
    
    public func removeContent(at indexPath: IndexPath) -> BMContent{
        guard let content = content(at: indexPath) else{
            fatalError("removing nil content at indexPath \(indexPath)")
        }
        if let url = content.path{
            sharedFileContentManager.removeContent(at: url, { (error, deleteFileURL) in
                // Show message incase of failed operation
            })
        }
        contentArray.remove(at: indexPath.item)
        return content
    }
    
    public func getPreviewImage(atPath url: URL) -> UIImage?{
        return contentPreviewImageCache[url]
    }
    
    public func loadContents(forType type: BMContentType, from source: BMContentSource, _ completionHandler: @escaping (Error?, Any?, BMContentSource) -> ()){

        sharedFileContentManager.loadContents(type, source, at: nil) { (error, contents, source) in
            
            if let urls = contents as? [URL]{
                self.generateContentPreviews(for: urls)
                self.processContents(sources: urls, forType: type)
            }
            completionHandler(error, contents, source)
        }
    }

    public func content(at indexPath: IndexPath) -> BMContent?{
        if contentCount <= indexPath.item{
            return nil
        }
        return contentArray[indexPath.item]
    }
}
