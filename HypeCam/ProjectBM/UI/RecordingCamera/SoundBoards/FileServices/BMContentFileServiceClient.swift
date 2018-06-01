//
//  BMContentFileServiceClient.swift
//  ProjectBM
//
//  Created by Jiahe Kuang on 12/23/17.
//  Copyright © 2017 JHK_Development. All rights reserved.
//

import Foundation
protocol BMContentFileSericeClient {
    func deleteContent(at url: URL, _ completionHandler: @escaping (Error?, Any?) -> ())
    func loadContents(_ type: BMContentType, _ source: BMContentSource, at path: URL?, _ completionHanlder: @escaping (Error?, Any?, BMContentSource)->())
}
