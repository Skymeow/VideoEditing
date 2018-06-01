//
//  Gif.swift
//  ProjectBM
//
//  Created by Sky Xu on 4/6/18.
//  Copyright © 2018 JHK_Development. All rights reserved.
//

import Foundation
//call MediaItem: url?, previewUrl?
struct Gif {
    let gifUrl: String
    let gifPreviewUrl: String
    
    init(gifUrl: String, gifPreviewUrl: String) {
        self.gifUrl = gifUrl
        self.gifPreviewUrl = gifPreviewUrl
    }
}
