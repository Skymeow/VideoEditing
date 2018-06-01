//
//  HeaderViewForFeeds.swift
//  ProjectBM
//
//  Created by Sky Xu on 4/5/18.
//  Copyright © 2018 JHK_Development. All rights reserved.
//

import Foundation
import UIKit

protocol CustomedHeaderDelegate: class {
    //    func toProfile()
    func toRecord()
    //    func toDiscover()
}
class HeaderViewForFeeds: UIView {
    
    //    @IBOutlet weak var profileBtn: UIButton!
    @IBOutlet weak var recordBtn: UIButton!
    //    @IBOutlet weak var discoverBtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        recordBtn.attachShadow(nil, nil)
    }
    weak var customedHeaderDelegate: CustomedHeaderDelegate?
    
    //    @IBAction func profileTapped(_ sender: UIButton) {
    //        customedHeaderDelegate?.toProfile()
    //    }
    //
    //    @IBAction func discoverTapped(_ sender: UIButton) {
    //        customedHeaderDelegate?.toDiscover()
    //    }
    
    @IBAction func recordTapped(_ sender: UIButton) {
        customedHeaderDelegate?.toRecord()
    }
    
    
}

