//
//  BMVideoPlayerViewController.swift
//  ProjectBM
//
//  Created by Jiahe Kuang on 11/23/17.
//  Copyright © 2017 JHK_Development. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

protocol BMVideoPlayerViewControllerContentDelegate: class {
    func handleRecordedContent(_ url: URL?)->()
}

class BMVideoPlayerViewController:  AVPlayerViewController{

    var fileURL: URL? = nil
    weak var contentDelegate: BMVideoPlayerViewControllerContentDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let url = fileURL{
            self.player = AVPlayer(url: url)
            self.player?.play()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        contentDelegate?.handleRecordedContent(fileURL)
    }
    
    
    deinit {
        print("removed video player")
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
