//
//  Date+StringConvert.swift
//  ProjectBM
//
//  Created by Jiahe Kuang on 12/24/17.
//  Copyright © 2017 JHK_Development. All rights reserved.
//

import Foundation
extension Date{
    func fullDateString() -> String{
        return DateFormatter.BMDefaultDateFormatter.string(from: self)
    }
}
