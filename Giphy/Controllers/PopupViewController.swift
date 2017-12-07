
import UIKit

class PopupViewController: UIViewController {

    // MARK: - Variables
    var customBlurEffectStyle: UIBlurEffectStyle!
    var customInitialScaleAmmount: CGFloat!
    var customAnimationDuration: TimeInterval!
    var gifImage:UIImage!
    
    // MARK: - IBOutlets
    @IBOutlet weak var iboImageViewGif: UIImageView!
    @IBOutlet weak var iboButtonShare: UIButton!
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupData()
        self.setupAppearance()
    }
    
    // MARK: - Setup
    func setupAppearance() {
        self.iboButtonShare.setTitleColor(UIColor.random, for: UIControlState.normal)
        modalPresentationCapturesStatusBarAppearance = true
    }
    
    func setupData() {
         self.iboImageViewGif.image = self.gifImage
    }
    
    // MARK: - IBActions
    @IBAction func dismissButtonTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func shareButtonTapped(_ sender: Any) {
       self.shareImg(imgToShare: self.gifImage)
    }
    
    func shareImg(imgToShare:UIImage) {
        let shareItems:Array = [imgToShare]
        let activityViewController:UIActivityViewController = UIActivityViewController(activityItems:shareItems, applicationActivities: nil)
        activityViewController.excludedActivityTypes = [UIActivityType.print, UIActivityType.postToWeibo, UIActivityType.copyToPasteboard, UIActivityType.addToReadingList, UIActivityType.postToVimeo,UIActivityType.saveToCameraRoll]
        self.present(activityViewController, animated: true, completion: nil)
    }
}

// MARK: - MIBlurPopupDelegate
extension PopupViewController: MIBlurPopupDelegate {
    
    var popupView: UIView {
        return UIView();
    }
    
    var blurEffectStyle: UIBlurEffectStyle {
        return customBlurEffectStyle
    }
    
    var initialScaleAmmount: CGFloat {
        return customInitialScaleAmmount
    }
    
    var animationDuration: TimeInterval {
        return customAnimationDuration
    }
}

// MARK: - Helpers
extension CGFloat {
    static var random: CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}

extension UIColor {
    static var random: UIColor {
        return UIColor(red: .random, green: .random, blue: .random, alpha: 1.0)
    }
}
