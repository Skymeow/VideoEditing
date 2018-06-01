//
//  BMContentTableViewCell.swift
//  ProjectBM
//
//  Created by Jiahe Kuang on 12/24/17.
//  Copyright © 2017 JHK_Development. All rights reserved.
//

import UIKit

class BMContentTableViewCell: UITableViewCell {

    @IBOutlet weak var contentPreviewImageView: UIImageView!
    @IBOutlet weak var contentCreationDateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
