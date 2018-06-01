//
//  BMSoundBoardTableViewCell.swift
//  ProjectBM
//
//  Created by Jiahe Kuang on 12/5/17.
//  Copyright © 2017 JHK_Development. All rights reserved.
//

import UIKit
protocol BMSoundBoardTableViewCellDelegate: class {
    func selectBoard(at index:Int)
    func testSoundBoard(at index:Int)
}

class BMSoundBoardTableViewCell: UITableViewCell {

    weak var delegate: BMSoundBoardTableViewCellDelegate?
    var indexPath: IndexPath? = nil
    
    @IBOutlet weak var soundBoardContainerView: UIView!
    @IBOutlet weak var soundBoardTitleLabel: UILabel!
    @IBOutlet weak var addSoundBoardButton: UIButton!
    @IBOutlet weak var soundBoardDescriptionTextView: UITextView!
    @IBOutlet weak var testSoundBoardButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        soundBoardContainerView.layer.cornerRadius = 10
        soundBoardContainerView.layer.borderWidth = 1
        soundBoardContainerView.layer.borderColor = UIColor.clear.cgColor
        soundBoardContainerView.attachShadow(UIColor.init(red: 150.0/255, green: 155.0/255, blue: 163.0/255, alpha: 0.2), nil)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureFor(_ soundBoard: BMSoundBoard){
        soundBoardTitleLabel.text = soundBoard.title
        soundBoardDescriptionTextView.text = soundBoard.description
        configureAddButtonForIsInUse(soundBoard.isInUse)
    }
    
    func configureAddButtonForIsInUse(_ isInUse:Bool){
        var addButtonImage = UIImage.init(named: "soundBoardAdd")
        if isInUse{
            addButtonImage = UIImage.init(named: "soundBoardAdded")
            addSoundBoardButton.attachShadow(UIColor.init(rgb: 0x7FF685), BMUIViewShadowType.filled)
        }
        else{
            addSoundBoardButton.attachShadow(UIColor.init(rgb: 0x47D3FF), BMUIViewShadowType.filled)
        }
        addSoundBoardButton.setImage(addButtonImage, for: .normal)
    }
    
    
    
    @IBAction func addSoundBoard(_ sender: Any) {
        delegate?.selectBoard(at: indexPath!.item)
    }
    @IBAction func testSoundBoard(_ sender: Any) {
        delegate?.testSoundBoard(at: indexPath!.item)
    }
    
}
