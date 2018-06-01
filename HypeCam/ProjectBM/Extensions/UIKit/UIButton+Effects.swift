//
//  BMButton+Effects.swift
//  ProjectBM
//
//  Created by Jiahe Kuang on 12/9/17.
//  Copyright © 2017 JHK_Development. All rights reserved.
//

import Foundation
import UIKit

typealias UIButtonAnimationCompletionBlock = (Int?) -> Void

extension UIButton{
    
    func fading(from newColor: UIColor, to originalColor: UIColor, in duration:Double){
        self.backgroundColor = newColor
        self.layer.shadowColor = newColor.cgColor;
        self.layer.shadowOffset = CGSize(width: 0, height: 0);
        self.layer.shadowRadius = 10.0;
        self.layer.shadowOpacity = 0.3;
        self.layer.masksToBounds = false;
        UIView.animateKeyframes(withDuration: duration*1.3, delay: 0, options: .allowUserInteraction, animations: {
            self.backgroundColor = originalColor
            self.attachShadow(nil, nil)
        }) { (isComplete) in
            //Do something when fading is done
        }
    }
    
    func applyPressedArcadeEffects(withColor color: UIColor, durationTime duration: Double, completionHandler completionBlock: UIButtonAnimationCompletionBlock?){
        self.attachShadow(color, nil)
        self.layer.shadowColor = color.cgColor;
        self.layer.shadowOffset = CGSize(width: 0, height: 0);
        self.layer.shadowRadius = 10.0;
        self.layer.shadowOpacity = 0.3;
        self.layer.masksToBounds = false;
        UIView.animateKeyframes(withDuration: duration*1.3, delay: 0, options: .allowUserInteraction, animations: {
            self.attachShadow(nil, nil)
        }) { (isComplete) in
            if let completionHandler = completionBlock{
                completionHandler(self.tag)
            }
        }
    }
}
