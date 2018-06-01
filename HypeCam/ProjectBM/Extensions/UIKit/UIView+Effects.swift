//
//  BMUIView+Effects.swift
//  ProjectBM
//
//  Created by Jiahe Kuang on 12/8/17.
//  Copyright © 2017 JHK_Development. All rights reserved.
//

import Foundation
import UIKit

enum BMUIViewShadowType {
    case filled
    case dropDown
}

extension UIView{
    
    func attachShadow(_ shadowColor: UIColor?, _ shadowType: BMUIViewShadowType?){
        if let color = shadowColor{
            self.layer.shadowColor = color.cgColor
        }else{
            self.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.35).cgColor
        }
        if let type = shadowType{
            if type == .filled{
                self.layer.shadowOffset = CGSize(width: 0, height: 1)
            }
            else{
                self.layer.shadowOffset = CGSize(width: 0, height: 3)
            }
        }
        else{
            self.layer.shadowOffset = CGSize(width: 0, height: 2)
        }
        self.layer.shadowOpacity = 1.0
        self.layer.shadowRadius = 3.0
    }
    
}
