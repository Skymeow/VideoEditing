//
//  BMUserContentViewController.swift
//  ProjectBM
//
//  Created by Jiahe Kuang on 12/21/17.
//  Copyright © 2017 JHK_Development. All rights reserved.
//

import UIKit

enum BMUserContentViewState {
    case Recorded
    case Edited
}

class BMUserContentViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    // Outlets
    @IBOutlet weak var contentTableView: UITableView!
    
    // Data Drivers
    let viewModel: BMUserVideosViewModel = BMUserVideosViewModel()
    
    var viewState: BMUserContentViewState = .Recorded {
        didSet{
            var displayContentType: BMContentType
            switch viewState {
            case .Edited:
                displayContentType = .ProcessedVideo
            default:
                displayContentType = .RawVideo
            }
            viewModel.loadContents(forType: displayContentType, from: .LocalDocsDirectory) { (error,contents,source) in
                DispatchQueue.main.async {
                    self.contentTableView.reloadData()
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        contentTableView.tableFooterView = UIView(frame: .zero)
        viewModel.loadContents(forType: .RawVideo, from: .LocalDocsDirectory) { (error,contents,source) in
            DispatchQueue.main.async {
                self.contentTableView.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = UIColor.init(rgb: 0xF5F7FA)
        if let selectedIndexPath = contentTableView.indexPathForSelectedRow{
            contentTableView.deselectRow(at: selectedIndexPath, animated: true)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismiss(_ sender: Any) {
        self.dismiss(animated: true) {
            //Do something
        }
    }
    
    // MARK: - Outlets Actions
    @IBAction func contentViewStateChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            self.viewState = .Recorded
        case 1:
            self.viewState = .Edited
        default:
            break
        }
    }
    
    // MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "contentCell", for: indexPath) as? BMContentTableViewCell else{
            fatalError("content cell load failed")
        }
        guard let content = viewModel.content(at: indexPath) else{
            fatalError("no media content")
        }
        if let path = content.path{
            cell.contentPreviewImageView.image = viewModel.getPreviewImage(atPath: path)
        }
        cell.contentCreationDateLabel.text = content.creationDate.fullDateString()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "fromVideosToEditing", sender: self)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]?
    {
        let update = UITableViewRowAction(style: .normal, title: "Share") { action, index in
            if let content = self.viewModel.content(at: index){
                if let url = content.path{
                    url.shareContentFromURL(in: self, message: nil)
                }
            }
        }
        
        let delete = UITableViewRowAction(style: .default, title: "Delete") { action, index in
            _ = self.viewModel.removeContent(at: index)
            tableView.deleteRows(at: [index], with: .fade)
        }
        
        return [delete, update]
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {

    }
    
    // MARK: - TableView DataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.contentCount
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0
    }

    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "fromVideosToEditing"{
            guard let destinationVC = segue.destination as? BMVideoEditingViewController else{
                fatalError("Failed to load BMVideoEditingViewController")
            }
            guard let selectedIndexPath = contentTableView.indexPathForSelectedRow else{
                fatalError("segue happened without a selected row")
            }
            guard let selectedContent = viewModel.content(at: selectedIndexPath) else{
                fatalError("content doesn't exist for selected row")
            }
            destinationVC.viewModel.contentURL = selectedContent.path
        }
        
        if segue.identifier == "fromVideosToPlayer" {
            let destinationVC: BMVideoPlayerViewController = segue.destination as! BMVideoPlayerViewController
            guard let selectedIndexPath = contentTableView.indexPathForSelectedRow else{
                fatalError("segue happened without a selected row")
            }
            guard let selectedContent = viewModel.content(at: selectedIndexPath) else{
                fatalError("content doesn't exist for selected row")
            }
            destinationVC.fileURL = selectedContent.path
        }
    }
    

}
