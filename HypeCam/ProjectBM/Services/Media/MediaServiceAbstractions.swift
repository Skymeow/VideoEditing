//
//  Audio.swift
//  ProjectBM
//
//  Created by Jiahe Kuang on 4/15/18.
//  Copyright © 2018 JHK_Development. All rights reserved.
//

import Foundation
enum AudioServiceError: Error {
    case RecordingFailure
    case URLError
    case ExportFailure
    case BadSession
    case Unknown
}

typealias RecordingTimeKey = Int64
typealias AudioRecordingResult = Result<URL?, AudioServiceError>
