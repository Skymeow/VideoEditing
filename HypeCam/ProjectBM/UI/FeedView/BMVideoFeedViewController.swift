//
//  BMVideoFeedViewController.swift
//  ProjectBM
//
//  Created by Sky Xu on 3/9/18.
//  Copyright © 2018 JHK_Development. All rights reserved.
//

import UIKit
import RealmSwift
import Kingfisher
import AVFoundation

class BMVideoFeedViewController: UIViewController , UITableViewDelegate, UITableViewDataSource {
    
    var lastContentOffset: CGFloat = 0
    var currentCell:  VideoFeedCell?
    weak open var prefetchDataSource: UITableViewDataSourcePrefetching?
    @IBOutlet weak var tableView: UITableView!
    var videoFeeds: Results<VideoObject>? {
        didSet {
            self.tableView.reloadData()
        }
    }
    var currentPlayingCell: VideoFeedCell?
    
    var currentPlayer: AVPlayer? = nil
    
    private let refreshControl = UIRefreshControl()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.isPagingEnabled = false
        // Add Refresh Control to Table View
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(refreshData(_:)), for: .valueChanged)
        getVideos()
    }
    
    @objc private func refreshData(_ sender: Any) {
        getVideos()
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        currentPlayer?.play()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        currentPlayer?.pause()
//        currentPlayer?.replaceCurrentItem(with: nil)
    }
    
    func getVideos() {
        VideoObjectProvider.sharedProvider.fetchFromRemote(.fetchAll, DispatchQueue.main) {[weak self] (videos, err) in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                if err == nil {
                    if videos?.count == 0 {
                        strongSelf.getVideos()
                    }
                    else {
                        strongSelf.videoFeeds = videos
                        strongSelf.tableView.reloadData()
                    }
                }
                strongSelf.refreshControl.endRefreshing()
            }
        }

    }
    
    func addLoadingIndicator(){
        
        guard let loadingIndicator = Bundle.main.loadNibNamed("BMLoadingIndicator",
                                                              owner:self, options:nil)![0] as? BMLoadingIndicatorView else{
                                                                return
        }
        loadingIndicator.configView(with: "Loading Video", at: view.center)
        view.addSubview(loadingIndicator)
    }
    
    func removeLoadingIndcator(){
        for view in view.subviews{
            if view is BMLoadingIndicatorView{
                view.removeFromSuperview()
                break
            }
        }
    }
    
    //    for personal feed VC to unwind back to current VC
    @IBAction func unwindToAllFeeds(_ segue: UIStoryboardSegue) {
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let objects = self.videoFeeds {
            return objects.count
        } else {
            return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        let height = self.tableView.frame.height - CGFloat(90)
        let height = (self.tableView.frame.height - CGFloat(80)) * 0.7 + CGFloat(30)
        
        return height
    }
    
    @objc func backToRecord(_ sender: UIButton) {
        let indexPath = IndexPath(row: sender.tag, section: 0)
        let cell = tableView.cellForRow(at: indexPath) as! VideoFeedCell
        cell.viewModel.player.pause()
        self.performSegue(withIdentifier: "toRecordVC", sender: self)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "feedcell") as? VideoFeedCell else{
            fatalError()
        }
        cell.tag = indexPath.row
        let gifThumbnailStr = self.videoFeeds![indexPath.row].thumbnil
        let gifThumbnailUrl = URL(string: gifThumbnailStr!)
        cell.videoThumbnail.kf.indicatorType = .activity
        cell.videoThumbnail.kf.cancelDownloadTask()
        cell.videoThumbnail.image = nil
        cell.videoThumbnail.isHidden = true
        cell.videoPlayerView.isHidden = true
        cell.videoThumbnail.kf.setImage(with: gifThumbnailUrl) { (image, error, cachedType, url) in
            DispatchQueue.main.async {
                cell.videoThumbnail.isHidden = false
            }
        }
        if indexPath.row == 0 {
            self.currentPlayingCell = cell
            self.prepareVideoLoading(cell: cell, forItemAtIndex: indexPath.row)
            currentPlayer?.play()
            cell.contentView.bringSubview(toFront: cell.videoPlayerView)
            cell.videoPlayerView.isHidden = false
        }
        return cell
    }
    
//
//    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
//        let pageWidth = self.tableView.frame.size.width + 10
//        var newPage = currentPage
//
//        // slow dragging not lifting finger
//        if (velocity.x == 0) {
//            newPage = Int(floor((targetContentOffset.pointee.x - pageWidth / 2) / pageWidth)) + 1
//        }
//        else {
//            newPage = velocity.x > 0 ? currentPage + 1 : currentPage - 1
//
//            if (newPage < 0){
//                newPage = 0
//            }
//            if (newPage > Int(self.tableView.contentSize.width / pageWidth)) {
//                newPage = Int(ceil(self.tableView.contentSize.width / pageWidth)) - 1
//            }
//        }
//        targetContentOffset.pointee = CGPoint(x: CGFloat(newPage) * pageWidth, y: targetContentOffset.pointee.y)
//    }
    
//    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
//
//        guard let firstVisibleIndexPath = tableView.indexPathsForVisibleRows?.first else { return }
//        guard let lastVisibleIndexPath = tableView.indexPathsForVisibleRows?.last else { return }
//        if (self.lastContentOffset > scrollView.contentOffset.y) {
//            // move up
//            if firstVisibleIndexPath.row != 0 {
//                let indexPath = IndexPath(row: lastVisibleIndexPath.row - 1, section: 0)
//                tableView.scrollToRow(at: indexPath, at: .top, animated: true)
//            }
//        }
//        else if (self.lastContentOffset < scrollView.contentOffset.y) {
//            // move down
//            let indexPath = IndexPath(row: firstVisibleIndexPath.row + 1, section: 0)
//            tableView.scrollToRow(at: indexPath, at: .top, animated: true)
//        }
//        lastContentOffset = scrollView.contentOffset.y
//    }


    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let cells = tableView.visibleCells as! [VideoFeedCell]
        //        based on the height, the least num of visible cell is 2
        if let visibleRowIndex = tableView.indexPathsForVisibleRows?.count {
            if  visibleRowIndex > 1 {
                let lastIndexPath = tableView.indexPathsForVisibleRows!.last!
                let lastVisibleIndex = lastIndexPath.row
//                print("last visible index *****", lastVisibleIndex)
                var topRightRect = self.tableView.rectForRow(at: lastIndexPath)
                topRightRect = topRightRect.offsetBy(dx: -tableView.contentOffset.x, dy:  -tableView.contentOffset.y)
                let tableViewMid = tableView.frame.midY
                let check = topRightRect.minY - tableViewMid
                // when the top right y of last visible cell bigger than half of tableview, play lastcell
                //  when check is negative, the last visible cell is above tableview midY (play last visible cell)
                if check < 0 {
                    // pause 2rd last visible cell
                    let prevIndexPath = IndexPath(row: lastVisibleIndex-1, section: 0)
                    if let _ = self.tableView.cellForRow(at: prevIndexPath) as? VideoFeedCell {
                        currentPlayer?.pause()
                        currentPlayer = nil
                    }
                    // play last visible cell
                    if let last = self.tableView.cellForRow(at: lastIndexPath) as? VideoFeedCell {
                        self.prepareVideoLoading(cell: last, forItemAtIndex: (lastVisibleIndex))
                        tableView.scrollToRow(at: lastIndexPath, at: .top, animated: true)
                        currentPlayer?.play()
                        last.contentView.bringSubview(toFront: last.videoPlayerView)
                        last.videoPlayerView.isHidden = false

                    }
                    
                } else if check > 0 {
                    
                    if let _ = self.tableView.cellForRow(at: lastIndexPath) as? VideoFeedCell {
                        currentPlayer?.pause()
                        currentPlayer = nil
                    }
                    
                    let prevIndexPath = IndexPath(row: lastVisibleIndex-1, section: 0)
                    if let prev = self.tableView.cellForRow(at: prevIndexPath) as? VideoFeedCell {
                        self.prepareVideoLoading(cell: prev, forItemAtIndex: (lastVisibleIndex-1))
                        tableView.scrollToRow(at: prevIndexPath, at: .top, animated: true)
                        currentPlayer?.play()
                        prev.contentView.bringSubview(toFront: prev.videoPlayerView)
                        prev.videoPlayerView.isHidden = false

                    }
                }
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let frame = CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 70)
        let customizedHeaderView = Bundle.main.loadNibNamed("HeaderViewForFeeds", owner: self, options: nil)![0] as? HeaderViewForFeeds
        customizedHeaderView?.frame = frame
        customizedHeaderView?.customedHeaderDelegate = self
        
        return customizedHeaderView
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: view.frame.width, height: view.frame.height)
        return size
    }

   
    //    load stuffs for avplayer in prefetch
    func prepareVideoLoading(cell: VideoFeedCell, forItemAtIndex index: Int) {
        // Clean up player
        self.currentPlayer?.pause()
        self.currentPlayer = nil
        cell.videoPlayerView.player?.pause()
        cell.videoPlayerView.player?.replaceCurrentItem(with: nil)

        
        //        self.addLoadingIndicator()
        let indexPath = IndexPath(row: index, section: 0)
        //        everytime a new cell enters, clear the url
        if let videoUrl = URL(string: self.videoFeeds![indexPath.row].localUrl!) {
            //        only play video when enter the cell (cell become visible)
            if self.tableView.indexPathsForVisibleRows?.contains(indexPath) ?? false {
                cell.viewModel.configureAVPlayer(url: videoUrl)
                cell.playerLayer?.player = cell.viewModel.player
                currentPlayer = cell.playerLayer?.player
            }
        }
    }
    
    deinit {
        NSLog("Removing FeedView")
    }
}


extension BMVideoFeedViewController: CustomedHeaderDelegate {
    
    func toRecord() {
        self.currentPlayingCell?.playerLayer?.player?.pause()
        self.performSegue(withIdentifier: "toRecordVC", sender: self)
    }
}

