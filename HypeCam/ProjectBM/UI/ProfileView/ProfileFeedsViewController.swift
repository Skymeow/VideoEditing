////
////  ProfileFeedsViewController.swift
////  ProjectBM
////
////  Created by Sky Xu on 4/6/18.
////  Copyright © 2018 JHK_Development. All rights reserved.
////
//
//import UIKit
//import RealmSwift
//import Kingfisher
//
//class ProfileFeedsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
//
//    @IBOutlet weak var tableView: UITableView!
//
//    var videoFeeds: Results<VideoObject>? {
//        didSet {
//            DispatchQueue.main.async {
//                self.tableView.reloadData()
//            }
//        }
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.tableView.isPagingEnabled = true
//        self.tableView.delegate = self
//        self.tableView.dataSource = self
//
//        let fetchQueue = DispatchQueue(
//            label: "downloadPersonalFromRemoteQueue",
//            attributes: .concurrent)
//        VideoObjectProvider.sharedProvider.fetchFromRemote(.fetchPersonal, fetchQueue) { (videos, err) in
//            if err == nil {
//                self.videoFeeds = videos
//            }
//        }
//    }
//
//    @IBAction func backtapped(_ sender: UIButton) {
//         self.performSegue(withIdentifier: "unwindToAllFeeds", sender: self)
//    }
//
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        if let objectCount = self.videoFeeds {
//            return objectCount.count
//        } else {
//            return 0
//        }
//    }
//
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        let height = tableView.frame.height
//
//        return height
//    }
//
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: "feedcell") as? VideoFeedCell else{
//            fatalError()
//        }
//
//        cell.viewModel.playVideo()
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: "feedcell") as? VideoFeedCell else{
//            fatalError()
//        }
//        if self.videoFeeds?.count != 0 {
//            let videoUrl = URL(string: self.videoFeeds![indexPath.row].localUrl!)
//            cell.viewModel.configureAVPlayer(url: videoUrl)
//            cell.playerLayer?.player = cell.viewModel.player
//        }
//
//        return cell
//    }
//}
//
