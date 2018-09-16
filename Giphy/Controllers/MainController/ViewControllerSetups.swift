//
//  ViewControllerSetups.swift
//  Giphy
//
//  Created by Den on 9/16/18.
//  Copyright © 2018 Deniss Kaibagarovs. All rights reserved.
//

import UIKit

extension ViewController {
    
    func setupAppearance() {
        UITextField.appearance().keyboardAppearance = .dark
        self.iboImageViewNoGifFound.loadGif(name: "no_gif_placeholder")
    }
    
    func setupKeyboardNotifications() {
        //** Subscribe to notifications **
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(ViewController.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        notificationCenter.addObserver(self, selector: #selector(ViewController.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func setupCollectionView() {
        // Register cell (required)
        self.iboCollectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier:CELL_IDENTIFIER)
    }
    
    func setupData() {
        loadListOfImages(input:"", newSearch:true)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
