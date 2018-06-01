//
//  BMSoundBoardDetailViewController.swift
//  ProjectBM
//
//  Created by Jiahe Kuang on 12/7/17.
//  Copyright © 2017 JHK_Development. All rights reserved.
//

import UIKit
protocol BMSoundBoardDetailViewControllerDelegate: class {
    func useBoard(_ soundBoard: BMSoundBoard, _ completionHanlder: @escaping ()->())
}

class BMSoundBoardDetailViewController: UIViewController {

    @IBOutlet weak var soundBoardDescriptionTextView: UITextView!
    @IBOutlet weak var soundBoardTitleLabel: UILabel!
    @IBOutlet weak var soundBoardViewContainer: UIView!
    
    @IBOutlet weak var buttonVerticalStackViewContainer: UIStackView!
    @IBOutlet weak var buttonTopStackView: UIStackView!
    @IBOutlet weak var buttonBottomStackView: UIStackView!
    
    // MARK: Constraints
    
    @IBOutlet weak var soundboardContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet var buttonSpacingConstraints: [NSLayoutConstraint]!

    weak var delegate: BMSoundBoardDetailViewControllerDelegate?
    var viewModel = BMSoundBoardDetailViewModel()
    

    let neonColorMap = [0:0xE6FB04,
                        1:0xFF0000,
                        2:0xFF6600,
                        3:0x00FF33,
                        4:0x00FFFF,
                        5:0x099FFF,
                        6:0xFF0099,
                        7:0x9D00FF]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureView()
        adjustConstraints()
        configureSoundBoard()
        injectViewData(with: viewModel.soundBoard)

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func adjustConstraints(){
        let buttonWidth = (self.view.frame.width - 80) / 4
        let buttonSpacing = CGFloat(16.0)
        buttonVerticalStackViewContainer.spacing = buttonSpacing
        buttonTopStackView.spacing = buttonSpacing
        buttonBottomStackView.spacing = buttonSpacing
        soundboardContainerHeightConstraint.constant = buttonWidth*2 + 2 * buttonSpacing
        for constraint in buttonSpacingConstraints{
            constraint.constant = buttonSpacing
        }
        self.view.layoutIfNeeded()
    }
    
    func configureView(){
        view.backgroundColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.8)
        view.isOpaque = false
    }
    
    func configureSoundBoard(){
        //FIX ME: need to have a custom soundboard view class
        for subview in buttonVerticalStackViewContainer.subviews{
            for button in subview.subviews{
                let tag = button.tag
                print(button.frame)
                button.backgroundColor = UIColor.clear
                (button as! UIButton).imageView?.clipsToBounds = true
                (button as! UIButton).imageView?.contentMode = .scaleAspectFit
                switch tag{
                case 0, 4:
                    (button as! UIButton).setImage(#imageLiteral(resourceName: "button0_normal"), for: .normal)
                    (button as! UIButton).setImage(#imageLiteral(resourceName: "button0_pressed"), for: .selected)
                    (button as! UIButton).setImage(#imageLiteral(resourceName: "button0_pressed"), for: .highlighted)
                case 1, 5:
                    (button as! UIButton).setImage(#imageLiteral(resourceName: "button1_normal"), for: .normal)
                    (button as! UIButton).setImage(#imageLiteral(resourceName: "button1_pressed"), for: .selected)
                    (button as! UIButton).setImage(#imageLiteral(resourceName: "button1_pressed"), for: .highlighted)
                    
                case 2, 6:
                    (button as! UIButton).setImage(#imageLiteral(resourceName: "button2_normal"), for: .normal)
                    (button as! UIButton).setImage(#imageLiteral(resourceName: "button2_pressed"), for: .selected)
                    (button as! UIButton).setImage(#imageLiteral(resourceName: "button2_pressed"), for: .highlighted)
                    
                case 3, 7:
                    (button as! UIButton).setImage(#imageLiteral(resourceName: "button3_normal"), for: .normal)
                    (button as! UIButton).setImage(#imageLiteral(resourceName: "button3_pressed"), for: .selected)
                    (button as! UIButton).setImage(#imageLiteral(resourceName: "button3_pressed"), for: .highlighted)
                    
                default:
                    fatalError("Button tag reached out of range")
                }
            }
        }
    }
    
    func injectViewData(with soundBoard: BMSoundBoard?){
        if let board = soundBoard{
            soundBoardTitleLabel.text = board.title
            soundBoardDescriptionTextView.text = board.description
        }
    }
    @IBAction func useBoard(_ sender: Any) {
        if let board = viewModel.soundBoard{
            delegate?.useBoard(board, {
                self.dismiss(animated: true, completion: {
                    //Do something
                })
            })
        }
    }
    
    @IBAction func pressedSoundButton(_ sender: UIButton) {
        _ = viewModel.playTrack(at: sender.tag)
    }
    
    func triggerButtonEffects(_ button:UIButton,_ duration: TimeInterval){
        let tag = button.tag
        let neonColor = UIColor.init(rgb: neonColorMap[tag]!)
        button.fading(from: neonColor, to: UIColor.white, in: duration)

    }
    
    @IBAction func dismiss(_ sender: Any) {
        self.dismiss(animated: true) {
            //Do something
        }
    }
    
    deinit {
        print("deinit soundboard detail vc")
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
