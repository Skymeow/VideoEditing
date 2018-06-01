//
//  BMColor+QuickConvert.swift
//  ProjectBM
//
//  Created by Jiahe Kuang on 12/9/17.
//  Copyright © 2017 JHK_Development. All rights reserved.
//

import Foundation
import UIKit

let neonColorMap = [0:0xE6FB04,
                    1:0xFF0000,
                    2:0xFF6600,
                    3:0x00FF33,
                    4:0x00FFFF,
                    5:0x099FFF,
                    6:0xFF0099,
                    7:0x9D00FF]

extension UIColor{
    
    class func neonColor(atIndex index: Int) -> UIColor{
        if index < 0 || index > 7{
            return UIColor.white
        }
        else{
            return UIColor.init(rgb: neonColorMap[index]!)
        }
    }
    
    convenience init(red: Int, green: Int, blue: Int, a: CGFloat = 1.0) {
        self.init(
            red: CGFloat(red) / 255.0,
            green: CGFloat(green) / 255.0,
            blue: CGFloat(blue) / 255.0,
            alpha: a
        )
    }

    convenience init(rgb rgbColor: Int, a: CGFloat = 1.0) {
        self.init(
            red: (rgbColor >> 16) & 0xFF,
            green: (rgbColor >> 8) & 0xFF,
            blue: rgbColor & 0xFF,
            a: a
        )
    }
}
