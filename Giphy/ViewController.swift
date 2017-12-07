//
//  ViewController.swift
//  Giphy
//
//  Created by Den on 12/5/17.
//  Copyright © 2017 Deniss Kaibagarovs. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITextFieldDelegate, UIScrollViewDelegate {

    // MARK: -Constants
    let API_KEY = "kpPeUe6TpJCHlCrgUrR68M9lEaISJPEP"
    let IMG_DOWNLOAD_PER_REQUEST_COUNT = "100"
    
    // MARK: -Variables
    var images = [AnyObject]()
    var timer = Timer()
    
    // MARK: -Outlets
    @IBOutlet weak var iboTextEditInput: UITextField!
    @IBOutlet weak var myCollectionView: UICollectionView?
    @IBOutlet weak var iboTextEditConstraintBottom: NSLayoutConstraint!
    @IBOutlet weak var iboLabelNoGifsFound: UILabel!
    
    // MARK: -Live Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UITextField.appearance().keyboardAppearance = .dark
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(ViewController.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        notificationCenter.addObserver(self, selector: #selector(ViewController.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left:0, bottom:0, right:0)
        layout.itemSize = CGSize(width: 100, height: 100)
        
        self.myCollectionView!.dataSource = self
        self.myCollectionView!.delegate = self
        self.myCollectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "MyCell")
        
        loadListOfImages(input:"", newSearch:true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        notificationCenter.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    // MARK: -Setup
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    // MARK: -Keyboard Actions
    @objc func keyboardWillShow(notification: NSNotification) {
        let userInfo = notification.userInfo!
        let keyboardHeight = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.height
        UIView.animate(withDuration: 0.3) {
            
            self.iboTextEditConstraintBottom.constant = -keyboardHeight
        }
        self.view.layoutIfNeeded()
        print(keyboardHeight)
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.3) {
            self.iboTextEditConstraintBottom.constant = 0
        }
        self.view.layoutIfNeeded()
    }
    
     // MARK: -Collection View Delegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == self.images.count - 10 { 
            // CollectionView is scrolled to the bottom
            loadListOfImages(input: self.iboTextEditInput.text, newSearch:false)
        }
        
        let myCell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyCell", for: indexPath as IndexPath)
        myCell.contentView.backgroundColor = UIColor.black;
        
        let imageUrlString = self.images[indexPath.row] as! String
        let imageUrl:NSURL = NSURL(string: imageUrlString)!
        
        if(imageUrl.absoluteString != "") {
            DispatchQueue.global(qos: .userInitiated).async {
                let imageData:NSData = NSData(contentsOf: imageUrl as URL)!
                DispatchQueue.main.async {
                    let imageView = UIImageView(frame: CGRect(x:0, y:0, width:myCell.frame.size.width, height:myCell.frame.size.height))
                    let image = UIImage.gifImageWithData(imageData as Data)
                    imageView.image = image
                    imageView.backgroundColor = UIColor.black
                    imageView.contentMode = UIViewContentMode.scaleAspectFit
                    
                    myCell.addSubview(imageView)
                }
            }
        }
        
        return myCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        
    }
    
    // MARK: -Text Field Delegates
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        startSearchTimer();
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true;
    }
    
    
    // MARK: -Timer Actions
    func startSearchTimer() {
        // invalidate the old timer
        timer.invalidate()
        
        // start the timer
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(timerAction), userInfo: nil, repeats: false)
    }
    
    @objc func timerAction() {
        loadListOfImages(input: self.iboTextEditInput.text, newSearch:true)
    }
    
    // MARK: -Networking
    func loadListOfImages(input:String!, newSearch:Bool)
    {
        if(newSearch) {
            self.images.removeAll()
        }
        
        // Define server side script URL
        let excapedInput = input.addingPercentEncoding(
            withAllowedCharacters: CharacterSet.urlQueryAllowed)
        
        let scriptUrl = "https://api.giphy.com/v1/gifs/search?q=" + excapedInput!
        
        let urlWithParams = scriptUrl + "&api_key=kpPeUe6TpJCHlCrgUrR68M9lEaISJPEP&limit=" + IMG_DOWNLOAD_PER_REQUEST_COUNT + "&offset=" + String(self.images.count)
        
        // Create NSURL Ibject
        let myUrl = URL(string: urlWithParams);
        
        // Creaste URL Request
        var request = URLRequest(url:myUrl!)
        
        // Set request HTTP method to GET.
        request.httpMethod = "GET"
        
        // Excute HTTP Request
        let task = URLSession.shared.dataTask(with: request) {
            data, response, error in
            
            var newItemsCount = 0
            // Check for error
            if error != nil
            {
                print("error=\(error as Optional)")
                return
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as? [String:Any] {
                    if let data = json["data"] as? [AnyObject] {
                        newItemsCount = data.count
                        for item in data  {
                            if let images = item["images"] as? [String:Any] {
                                if let fixed_height_downsampled = images["fixed_height_downsampled"] as? [String:AnyObject] {
                                    if let url = fixed_height_downsampled["url"] {
                                        self.images.append(url);
                                    }
                                }
                            }
                        }
                    }
                }
            } catch let err{
                print(err.localizedDescription)
            }
            
            DispatchQueue.main.async {
                self.iboLabelNoGifsFound.isHidden = self.images.count > 0
                
                if(newSearch) {
                    self.myCollectionView!.reloadData()
                } else {
                    if newItemsCount > 0 {
                        var indexPaths = [Any]()
                        var i = 0
                        while i < newItemsCount {
                            indexPaths.append(IndexPath(row:self.images.count - newItemsCount + i, section: 0))
                            i += 1
                        }
                        
                        self.myCollectionView?.performBatchUpdates({() -> Void in
                            self.myCollectionView?.insertItems(at: indexPaths as? [IndexPath] ?? [IndexPath]())
                        }) { _ in }
                    }
                }
            }
        }
        
        task.resume()
    }
}

