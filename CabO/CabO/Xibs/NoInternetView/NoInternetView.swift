//
//  NoInternetView.swift
//
//  Created by Octos.
//

import Foundation
import UIKit
import Lottie

class NoInternetView: ConstrainedView {
    
    /// Outlets
    @IBOutlet weak var viewBg: UIView!
    @IBOutlet weak var viewPopup: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var viewImage: UIImageView!
    @IBOutlet weak var viewAnimation: LottieAnimationView!
    
    /// Variables
    var callBack: (() -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.first?.view == viewBg {
//            animateOut {
//                self.callBack?()
//            }
        }
    }
    
    /// It will initialise and return `NoInternetView`
    /// - Returns: `NoInternetView`
    class func initWithWindow() -> NoInternetView {
        let obj = Bundle.main.loadNibNamed("NoInternetView", owner: nil, options: nil)?.first as! NoInternetView
        _appDelegator.window?.addSubview(obj)
        obj.addConstraintToSuperView(lead: 0, trail: 0, top: 0, bottom: 0)
        obj.isHidden = true
        obj.animateIn()
        return obj
    }
    
    func animateIn() {
        self.isHidden = false
        viewBg.alpha = 0
        viewPopup.alpha = 0
        self.layoutIfNeeded()
        UIView.animate(withDuration: 0.3, animations: {
            self.viewBg.alpha = 1
            self.viewPopup.alpha = 1
            self.layoutIfNeeded()
        }) { (success) in
            
        }
    }
    
    func animateOut(comp: (() -> ())?) {
        UIView.animate(withDuration: 0.3, animations: {
            self.viewBg.alpha = 0
            self.viewPopup.alpha = 0
            self.layoutIfNeeded()
        }) { (success) in
            comp?()
            self.removeFromSuperview()
        }
    }
    
    func startAnimation(_ named: LottieAnimationName) {
        loadAnimation(named: named)
    }
    
    func loadAnimation(named ani: LottieAnimationName) {
        stopAnimation()
        let animation = LottieAnimation.named(ani.rawValue, bundle: Bundle.main)
        viewAnimation?.contentMode = .scaleAspectFit
        viewAnimation?.animation = animation
        viewAnimation?.play()
        viewAnimation?.loopMode = .loop
    }
    
    func stopAnimation() {
        viewAnimation?.stop()
        viewAnimation?.animation = nil
    }
    
    func prepareUI(_ title: String, _ desc: String,_ img: (String, UIImage?)? = nil, isVerifyPopUp: Bool = false, isGIF: Bool = false, _ anim: LottieAnimationName? = nil) {
        lblTitle.text = title
        lblMessage.text = desc
        
        if let img {
            if isGIF {
                viewImage.loadGif(name: img.0)
            } else {
                viewImage.loadFromUrlString(img.0, placeholder: img.1)
            }
        }
        
        if let anim {
            startAnimation(anim)
        }
    }
}
