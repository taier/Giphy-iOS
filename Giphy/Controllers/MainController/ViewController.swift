//
//  ViewController.swift
//  Giphy
//
//  Created by Den on 12/5/17.
//  Copyright © 2017 Deniss Kaibagarovs. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIScrollViewDelegate {

    // MARK: - Constants
    let IMG_DOWNLOAD_PER_REQUEST_COUNT = 100
    let CELL_IDENTIFIER = "GIFImgCell"
    
    // MARK: - Variables
    var imagesURLS = [DataItem]()
    var timer = Timer()
    var selectedGIfUrlToShare = ""
    var networkingAdapter:NetworkingCallsProtocol = GiphyAdapter()
    
    // MARK: - Outlets
    @IBOutlet weak var iboTextEditInput: UITextField!
    @IBOutlet weak var iboCollectionView: UICollectionView?
    @IBOutlet weak var iboTextEditConstraintBottom: NSLayoutConstraint!
    @IBOutlet weak var iboLabelNoGifsFound: UILabel!
    @IBOutlet weak var iboImageViewNoGifFound: UIImageView!
    
    // MARK: - Live Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupAppearance()
        self.setupCollectionView()
        self.setupData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         self.setupKeyboardNotifications()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.removeKeyboardNotifications();
    }
    
    // MARK: - Keyboard Actions
    @objc func keyboardWillShow(notification: NSNotification) {
        // Obtain keyboard height
        let userInfo = notification.userInfo!
        let keyboardHeight = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
        
        // Move bottom text edit up with animation
        UIView.animate(withDuration: 0.3) {
            self.iboTextEditConstraintBottom.constant = -keyboardHeight
        }
        self.view.layoutIfNeeded()
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        // Move bottom text edit down with animation
        UIView.animate(withDuration: 0.3) {
            self.iboTextEditConstraintBottom.constant = 0
        }
        self.view.layoutIfNeeded()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: nil)
        
        // Check for destination controller before casting
        guard let popupViewController = segue.destination as? PopupViewController else { return }
        
        // ** Configure new screen **
        // UI
        popupViewController.customBlurEffectStyle = .dark
        popupViewController.customAnimationDuration = TimeInterval(0.5)
        popupViewController.customInitialScaleAmount = CGFloat(Double(10))
        
        // Data
        popupViewController.gifImage = UIImage.gif(url: self.selectedGIfUrlToShare)
    }
}

