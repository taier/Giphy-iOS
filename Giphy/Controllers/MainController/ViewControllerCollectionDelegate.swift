//
//  ViewControllerCollectionDelegate.swift
//  Giphy
//
//  Created by Den on 9/16/18.
//  Copyright © 2018 Deniss Kaibagarovs. All rights reserved.
//

import UIKit

extension ViewController : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        let dataItem:DataItem = self.imagesURLS[indexPath.item]
        self.selectedGIfUrlToShare = (dataItem.images!.first!.value.url!)
        self.performSegue(withIdentifier: "SHOW_GIF_SHARE", sender: nil)
    }
}
