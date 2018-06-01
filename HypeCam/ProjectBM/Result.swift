//
//  File.swift
//  ProjectBM
//
//  Created by Jiahe Kuang on 4/15/18.
//  Copyright © 2018 JHK_Development. All rights reserved.
//

import Foundation
enum Result<Value, E: Error> {
    case success(Value)
    case failure(E)
    
    init(value: Value) {
        self = .success(value)
    }
    
    init(error: E) {
        self = .failure(error)
    }
}
