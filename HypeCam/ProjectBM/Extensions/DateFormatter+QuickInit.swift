//
//  DateFormatter+QuickInit.swift
//  ProjectBM
//
//  Created by Jiahe Kuang on 12/24/17.
//  Copyright © 2017 JHK_Development. All rights reserved.
//

import Foundation
extension DateFormatter{
    static let BMDefaultDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd yyyy - h:mm a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        return formatter
    }()
}
