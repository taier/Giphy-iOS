//
//  ViewControllerDataSource.swift
//  Giphy
//
//  Created by Den on 9/16/18.
//  Copyright © 2018 Deniss Kaibagarovs. All rights reserved.
//

import UIKit

extension ViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.imagesURLS.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == self.imagesURLS.count - 10 {
            // CollectionView is scrolled to the bottom
            loadListOfImages(input: self.iboTextEditInput.text, newSearch:false)
        }
        
        // Prepare cell
        let myCell = collectionView.dequeueReusableCell(withReuseIdentifier:CELL_IDENTIFIER, for: indexPath as IndexPath)
        myCell.contentView.backgroundColor = UIColor.black;
        
        // Clean up old img views
        for view in myCell.contentView.subviews {
            view.removeFromSuperview()
            if view is UIImageView {
                let imgView = view as? UIImageView
                imgView?.image = nil;
            }
        }
        
        // Create Image View for img
        let imageView = UIImageView(frame: CGRect(x:0, y:0, width:myCell.frame.size.width, height:myCell.frame.size.height))
        imageView.backgroundColor = UIColor.black
        imageView.contentMode = UIViewContentMode.scaleAspectFit
        myCell.contentView.addSubview(imageView)
        
        // If have img in cache, use it
        DispatchQueue.global(qos: .userInitiated).async {
            if let img:UIImage = self.getImageFromCache(key:indexPath.item) {
                DispatchQueue.main.async {
                    imageView.image = img;
                }
            } else if(self.imagesURLS.count > indexPath.item) {
                // No img in cache, download it
                let dataItem:DataItem = self.imagesURLS[indexPath.item]
                let imageUrlString = (dataItem.images!.first!.value.url!)
                let imageUrl:NSURL = NSURL(string: imageUrlString)!
                if(imageUrl.absoluteString != "") {
                    let imageData:NSData = NSData(contentsOf: imageUrl as URL)!
                    DispatchQueue.main.async {
                        // Img downloaded, show and add to cache
                        let image = UIImage.gif(data: imageData as Data)!
                        imageView.image = image;
                        self.addImageToCahce(imageData:imageData as Data, key:indexPath.item)
                    }
                }
            }
        }
        return myCell
    }
}
