//
//  ViewControllerActions.swift
//  Giphy
//
//  Created by Den on 9/16/18.
//  Copyright © 2018 Deniss Kaibagarovs. All rights reserved.
//

import UIKit

extension ViewController {
    
    // MARK: - Networking
    func loadListOfImages(input:String!, newSearch:Bool)
    {
        // If new search, we don't need old items
        if(newSearch) {
            self.imagesURLS.removeAll()
            self.removeAllImagesFromCache();
        }
        
        // ** Try to get new items **
        self.networkingAdapter.getImagesURLsForQuery(query: input, limit: IMG_DOWNLOAD_PER_REQUEST_COUNT, offset: self.imagesURLS.count) { (downloadedImages) in
            DispatchQueue.main.async {
                
                // Assign new items
                let newItemsCount = downloadedImages.count
                self.imagesURLS.append(contentsOf:downloadedImages)
                
                // If no GIF to show
                self.showNoGifPlaceholder(show:self.imagesURLS.count == 0)
                
                // If was a new search - just reload collection view
                if(newSearch) {
                    self.iboCollectionView!.reloadData()
                } else {
                    // If scroll to bottom, insert new items into collection view
                    if newItemsCount > 0 {
                        // Prepare new index paths
                        var indexPaths = [Any]()
                        var i = 0
                        while i < newItemsCount {
                            indexPaths.append(IndexPath(row:self.imagesURLS.count - newItemsCount + i, section: 0))
                            i += 1
                        }
                        
                        // Insertion
                        self.iboCollectionView?.performBatchUpdates({() -> Void in
                            self.iboCollectionView?.insertItems(at: indexPaths as? [IndexPath] ?? [IndexPath]())
                        }) { _ in }
                    }
                }
            }
        }
    }
    
    // MARK: - Timer Actions
    func startSearchTimer() {
        // invalidate the old timer
        timer.invalidate()
        
        // start the timer
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(timerAction), userInfo: nil, repeats: false)
    }
    
    @objc func timerAction() {
        loadListOfImages(input: self.iboTextEditInput.text, newSearch:true)
    }
    
    // MARL: - Dispose
    func removeKeyboardNotifications() {
        // ** Unsubscribe from keyboard notifications **
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        notificationCenter.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    // MARK: - UI Actions
    func showNoGifPlaceholder(show:Bool) {
        self.iboLabelNoGifsFound.isHidden = !show
        self.iboImageViewNoGifFound.isHidden = !show
    }
    
    // MARK: - Image Caching
    func addImageToCahce(imageData:Data, key:Int) {
        ImageCacheManager.saveGifToCacheDirectory(imageData:imageData, name: String(key))
    }
    
    func getImageFromCache(key:Int) -> UIImage? {
        return ImageCacheManager.getImageFromCache(name: String(key))
    }
    
    func removeAllImagesFromCache() {
        ImageCacheManager.clearCacheDirectory()
    }
}
