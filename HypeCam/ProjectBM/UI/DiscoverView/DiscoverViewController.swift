//
//  DiscoverViewController.swift
//  ProjectBM
//
//  Created by Sky Xu on 4/6/18.
//  Copyright © 2018 JHK_Development. All rights reserved.
//

import UIKit
import Kingfisher

protocol DiscoverProtocol: class {
    func passPlayingResourceObject(gifObject: Gif)
}

class DiscoverViewController: UIViewController, UITextFieldDelegate {

    var offset = 0
    var searchOffset = 0
    var searchKeyWord: String?
    @IBOutlet weak var collectionView: UICollectionView!
    weak var delegate: DiscoverProtocol?
    var gifObejcts = [Gif](){
        didSet {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    var isSearched = false
    var contentInsets: UIEdgeInsets {
        return collectionView.contentInset
    }
    let loadingQueue = OperationQueue()
 
    override func viewDidLoad() {
        super.viewDidLoad()
//        collectionView.isPagingEnabled = true
//        let layout = UICollectionViewFlowLayout()
//        layout.scrollDirection = .horizontal
//        layout.minimumInteritemSpacing = 0
//        layout.minimumLineSpacing = 0
        collectionView.contentInset = UIEdgeInsetsMake(0, 20, 0, 20)
        collectionView.decelerationRate = UIScrollViewDecelerationRateFast
//        collectionView.collectionViewLayout = layout
        
        //  call searchgifs method in recording VC
        
        self.reloadTrendyGifs()
//        self.isSearched = true
//        self.searchKeyWord = "Trump"
//        searchGiphy(searchWord: "Trump")
    }
  
    // MARK: collection view relaid out
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
//        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    func reloadTrendyGifs() {
        //        show 9 trending gifs
        let callbackQueue = DispatchQueue(label: "trendyGifsCallback", attributes: .concurrent)
        DefaultGifyServiceManager.shared.getTrendingGify(offset: self.offset, callbackQueue: callbackQueue) { (gifs, err) in
            if let gifResults = gifs {
                self.gifObejcts += gifResults
            } else {
                AlertView.instance.presentAlertView("Gifs Reload Error", self)
            }
        }
    }
    
    public func searchGiphy(searchWord: String) {
        let callbackQueue = DispatchQueue(label: "searchGifsCallback", attributes: .concurrent)
        DefaultGifyServiceManager.shared.searchGify(offset: self.searchOffset, keyWord: searchWord, callbackQueue: callbackQueue){ [unowned self] (gifs, err) in
            if var gifResults = gifs {
                if self.gifObejcts.count == 0 {

//                    if searchWord.lowercased() == "trump" {
//                        gifResults.shuffle()
//                    }
    
                    if let firstGif = gifResults.first {
                        self.delegate?.passPlayingResourceObject(gifObject: firstGif)
                    }
                }
                self.gifObejcts += gifResults
            } else {
                AlertView.instance.presentAlertView("No gif found, try another search word", self)
            }
        }
    }
    
    public func reStartView() {
        self.collectionView.reloadData()
    }
}

extension DiscoverViewController: UICollectionViewDelegate, UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {

        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if self.gifObejcts.count != 0 {
            return self.gifObejcts.count
        } else {
            return 0
        }
    }
    
    //    get current playing gif
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {

        let visibleItems = collectionView.indexPathsForVisibleItems.sorted(by: { $0.item < $1.item })
        if visibleItems.count == 1 {
            let gifObject = self.gifObejcts[Int(visibleItems[0] .item)]
            self.delegate?.passPlayingResourceObject(gifObject: gifObject)
        }
        else if visibleItems.count == 2 {
            let leftIndexPath = visibleItems[0]
            if leftIndexPath.item == 0 {
                if let gifObject = self.gifObejcts.first {
                    self.delegate?.passPlayingResourceObject(gifObject: gifObject)
                }
            }
            else {
                if let gifObject = self.gifObejcts.last {
                    self.delegate?.passPlayingResourceObject(gifObject: gifObject)
                }
            }
        }
        else if visibleItems.count == 3 {
            let gifObject = self.gifObejcts[Int(visibleItems[1].item)]
            self.delegate?.passPlayingResourceObject(gifObject: gifObject)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! DiscoverCollectionCell
        let gifPreviewStr = self.gifObejcts[indexPath.row].gifPreviewUrl
        let gifPreviewUrl = URL(string: gifPreviewStr)
        cell.imgView.contentMode = .scaleAspectFill
        cell.imgView.kf.indicatorType = .activity
        cell.imgView.kf.setImage(with: gifPreviewUrl,options: [.cacheSerializer(FormatIndicatedCacheSerializer.gif)])
        cell.imgView.attachShadow(UIColor.init(red: 150.0/255, green: 155.0/255, blue: 163.0/255, alpha: 0.2), .dropDown)
        
        if isSearched == false {
            if indexPath.row == 0 {
                self.delegate?.passPlayingResourceObject(gifObject: self.gifObejcts[0])
            }
            
            if indexPath.row == self.gifObejcts.count - 1 {
                self.offset += 15
                self.reloadTrendyGifs()
            }
        } else {
            if indexPath.row == self.gifObejcts.count - 1 {
                if let searchWord = self.searchKeyWord {
                    self.searchOffset += 15
                    self.searchGiphy(searchWord: searchWord)
                }
            }
        }
        return cell
    }
}

extension DiscoverViewController:  UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var cellSize: CGSize = collectionView.bounds.size
        cellSize.width -= collectionView.contentInset.left
        cellSize.width -= collectionView.contentInset.right
        cellSize.height = collectionView.bounds.size.height
        
        return cellSize
    }
}

//extension MutableCollection {
//    /// Shuffles the contents of this collection.
//    mutating func shuffle() {
//        let c = count
//        guard c > 1 else { return }
//
//        for (firstUnshuffled, unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
//            // Change `Int` in the next line to `IndexDistance` in < Swift 4.1
//            let d: Int = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
//            let i = index(firstUnshuffled, offsetBy: d)
//            swapAt(firstUnshuffled, i)
//        }
//    }
//}
//
//extension Sequence {
//    /// Returns an array with the contents of this sequence, shuffled.
//    func shuffled() -> [Element] {
//        var result = Array(self)
//        result.shuffle()
//        return result
//    }
//}
//
