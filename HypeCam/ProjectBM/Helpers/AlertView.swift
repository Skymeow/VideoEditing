//
//  AlertView.swift
//  ProjectBM
//
//  Created by Sky Xu on 4/23/18.
//  Copyright © 2018 JHK_Development. All rights reserved.
//

import Foundation
import UIKit

class AlertView {
     static let instance = AlertView()
    
    func presentAlertView(_ message: String, _ superview: UIViewController) {
        let alert = UIAlertController(title: "Search Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        superview.present(alert, animated: true)
    }
    
}
