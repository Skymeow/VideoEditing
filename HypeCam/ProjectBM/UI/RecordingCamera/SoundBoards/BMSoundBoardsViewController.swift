//
//  BMSoundBoardsViewController.swift
//  ProjectBM
//
//  Created by Jiahe Kuang on 12/4/17.
//  Copyright © 2017 JHK_Development. All rights reserved.
//

import UIKit
protocol BMSoundBoardsViewControllerDelegate: class {
    func didSelectSoundBoard(_ soundBoad:BMSoundBoard)
}

class BMSoundBoardsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, BMSoundBoardTableViewCellDelegate, BMSoundBoardDetailViewControllerDelegate {

    @IBOutlet weak var soundBoardTableView: UITableView!
    let viewModel = BMSoundBoardsViewModel()
    var testSoundBoard: BMSoundBoard?
    weak var delegate: BMSoundBoardsViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        soundBoardTableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
        if viewModel.selectedSoundBoardId == nil{
            //Show all boards with no premade selection
            viewModel.showAllBoards()
        }
        else{
            //Show all boards with a preselection
            viewModel.createPremadeBoards()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = UIColor.init(rgb: 0xF5F7FA)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismiss(_ sender: Any) {
        self.dismiss(animated: true) {
            //Do something maybe
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.totalSoundBoardsCount
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let soundBoardCell = tableView.dequeueReusableCell(withIdentifier: "soundBoardCell") as? BMSoundBoardTableViewCell else{
            fatalError()
        }
        soundBoardCell.delegate = self
        soundBoardCell.indexPath = indexPath
        guard let soundBoard = viewModel.soundBoard(at: indexPath.item) else{
            fatalError()
        }
        soundBoardCell.configureFor(soundBoard)
        return soundBoardCell
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0
    }

    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        print("finished editing row at index \(indexPath!.item)")
    }
    
    func useBoard(_ soundBoard: BMSoundBoard, _ completionHanlder: @escaping () -> ()) {
        for i in 0..<viewModel.totalSoundBoardsCount{
            if let board = viewModel.soundBoard(at: i){
                if board.id == soundBoard.id{
                    selectBoard(at: i)
                    completionHanlder()
                    break
                }
            }
        }
    }
    
    func selectBoard(at index: Int) {
        print("selecting board at index \(index)")
        viewModel.selectBoard(at: index)
        swapSelectedBoard(at: index)
        if let soundBoard = viewModel.soundBoard(at: 0){
            delegate?.didSelectSoundBoard(soundBoard)
        }
    }
    
    func testSoundBoard(at index: Int) {
        if let soundBoard = viewModel.soundBoard(at: index){
            print(soundBoard.id)
            testSoundBoard = soundBoard
            self.performSegue(withIdentifier: "fromSoundBoardsToSoundBoardDetail", sender: self)
        }
    }
    
    func swapSelectedBoard(at index:Int){
        let currentSelectedIndexPath = IndexPath(item: 0, section: 0)
        let newSelectedIndexPath = IndexPath(item: index, section: 0)
        
        if let currentSelectedSoundBoardCell = soundBoardTableView.cellForRow(at: currentSelectedIndexPath) as? BMSoundBoardTableViewCell{
            currentSelectedSoundBoardCell.configureAddButtonForIsInUse(false)
            currentSelectedSoundBoardCell.indexPath = newSelectedIndexPath
            
        }
        if let newSelectedSoundBoardCell  = soundBoardTableView.cellForRow(at: newSelectedIndexPath) as? BMSoundBoardTableViewCell{
            newSelectedSoundBoardCell.configureAddButtonForIsInUse(true)
            newSelectedSoundBoardCell.indexPath = currentSelectedIndexPath
        }
        if #available(iOS 11.0, *) {
            soundBoardTableView.performBatchUpdates({
                soundBoardTableView.moveRow(at: currentSelectedIndexPath, to: newSelectedIndexPath)
                soundBoardTableView.moveRow(at: newSelectedIndexPath, to: currentSelectedIndexPath)
            }) { (completed) in
                
            }
        } else {
            // Fallback on earlier versions
            soundBoardTableView.beginUpdates()
            soundBoardTableView.moveRow(at: currentSelectedIndexPath, to: newSelectedIndexPath)
            soundBoardTableView.moveRow(at: newSelectedIndexPath, to: currentSelectedIndexPath)
            soundBoardTableView.endUpdates()
        }
        soundBoardTableView.scrollToRow(at: currentSelectedIndexPath, at: .top, animated: true)
    }
    
    deinit {
        print("deinit soundboards vc")
    }

    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "fromSoundBoardsToSoundBoardDetail"{
            guard  let destinationVC = segue.destination as? BMSoundBoardDetailViewController else{
                fatalError()
            }
            destinationVC.viewModel.soundBoard = testSoundBoard
            destinationVC.delegate = self
        }
    }


}
