//
//  BMLoadingIndicatorView.swift
//  ProjectBM
//
//  Created by Jiahe Kuang on 12/12/17.
//  Copyright © 2017 JHK_Development. All rights reserved.
//

import UIKit

class BMLoadingIndicatorView: UIView {
    
    @IBOutlet private weak var indicatorView: UIActivityIndicatorView!
    
    var title: String = ""
    
    func configView(with title:String?, at location: CGPoint) {
        self.attachShadow(nil, nil)
        self.layer.cornerRadius = 16
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.clear.cgColor
        self.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.8)
        self.isOpaque = false
        self.center = location
        indicatorView.startAnimating()
    }
    
    func dismiss(){
        indicatorView.stopAnimating()
        self.removeFromSuperview()
    }
    
    deinit {
        print("deinit indicator view")
    }
    
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

