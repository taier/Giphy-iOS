//
//  ViewController.swift
//  Giphy
//
//  Created by Den on 12/5/17.
//  Copyright © 2017 Deniss Kaibagarovs. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate, UIScrollViewDelegate {

    // MARK: - Constants
    let IMG_DOWNLOAD_PER_REQUEST_COUNT = 100
    let IMG_CACHE_SIZE = 200
    let CELL_IDENTIFIER = "GIFImgCell"
    
    // MARK: - Variables
    var imagesURLS = [AnyObject]()
    var cachedImages = [Int: UIImage]()
    var timer = Timer()
    var selectedGIfUrlToShare = ""
    var networkingAdapter:NetworkingCallsProtocol = GiphyAdapter()
    
    // MARK: - Outlets
    @IBOutlet weak var iboTextEditInput: UITextField!
    @IBOutlet weak var myCollectionView: UICollectionView?
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
        self.cachedImages.removeAll()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         self.setupKeyboardNotifications()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.removeKeyboardNotifications();
    }
    
    // MARK: - Setup
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
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
        self.myCollectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier:CELL_IDENTIFIER)
    }
    
    func setupData() {
        loadListOfImages(input:"", newSearch:true)
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
    
     // MARK: - Collection View Delegate
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
        if let img = self.cachedImages[indexPath.item] {
            imageView.image = img;
        } else if(self.imagesURLS.count > indexPath.item) {
            // No img in cache, download it
            DispatchQueue.global(qos: .userInitiated).async {
                let imageUrlString = self.imagesURLS[indexPath.item] as! String
                let imageUrl:NSURL = NSURL(string: imageUrlString)!
                let imageData:NSData = NSData(contentsOf: imageUrl as URL)!
                DispatchQueue.main.async {
                    // Img downloaded, show and add to cache
                    let image = UIImage.gif(data: imageData as Data)!
                    imageView.image = image;
                    self.addImageToCahce(image: image, key: indexPath.item)
                }
            }
        }
        return myCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        self.selectedGIfUrlToShare = (self.imagesURLS[indexPath.item] as? String)!;
        self.performSegue(withIdentifier: "SHOW_GIF_SHARE", sender: nil)
    }
    
    // MARK: - Text Field Delegates
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        startSearchTimer();
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true;
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
    
    // MARK: - Networking
    func loadListOfImages(input:String!, newSearch:Bool)
    {
        // If new search, we don't need old items
        if(newSearch) {
            self.imagesURLS.removeAll()
            self.cachedImages.removeAll();
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
                    self.myCollectionView!.reloadData()
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
                        self.myCollectionView?.performBatchUpdates({() -> Void in
                            self.myCollectionView?.insertItems(at: indexPaths as? [IndexPath] ?? [IndexPath]())
                        }) { _ in }
                    }
                }
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: nil)
        
        // Check for destination controller before casting
        guard let popupViewController = segue.destination as? PopupViewController else { return }
        
        // ** Configure new screen **
        // UI
        popupViewController.customBlurEffectStyle = .dark
        popupViewController.customAnimationDuration = TimeInterval(0.5)
        popupViewController.customInitialScaleAmmount = CGFloat(Double(10))
        
        // Data
        popupViewController.gifImage = UIImage.gif(url: self.selectedGIfUrlToShare)
    }
    
    // MARK: - Image Caching
    func addImageToCahce(image:UIImage, key:Int) {
        if(self.cachedImages.count > IMG_CACHE_SIZE) {
            self.cachedImages.removeAll()
        }
        self.cachedImages[key] = image
    }
}

