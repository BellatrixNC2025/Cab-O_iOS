//
//  SuccessPopUpView.swift
//
//  Created by Octos.
//

import Foundation
import UIKit
import Lottie

//MARK: - LottieAnimation
enum LottieAnimationName: String {
    case requestSent = "lt_send_message_success"
    case checkSuccess = "lt_check_success"
    case addCar = "car_add" // "lt_car_detail_add"
    case carLoading = "lt_car_loading"
    case otpEmail = "lt_otp_sent_email"
    case otpMobile = "lt_otp_sent_mobile"
    case loader = "loader"
    case sos = "lt_sos"
}

class SuccessPopUpView: ConstrainedView {
    
    /// Outlets
    @IBOutlet var imgSuccess: UIImageView!
    @IBOutlet weak var viewBg: UIView!
    @IBOutlet weak var viewPopup: UIView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblMessage: UILabel!
    @IBOutlet weak var viewImage: NRoundImageView!
    @IBOutlet weak var imgVerify: UIImageView!
    @IBOutlet weak var viewAnimation: LottieAnimationView!
    @IBOutlet var btnSubmit: UIButton!
    
    /// Variables
    var callBack: (() -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.first?.view == viewBg {
            animateOut {
                self.callBack?()
            }
        }
    }
    
    /// It will initialise and return `SuccessPopUpView`
    /// - Returns: `SuccessPopUpView`
    class func initWithWindow(_ title: String, _ desc: String, img: (String, UIImage?)? = nil, isVerifyPopUp: Bool = false, isGIF: Bool = false, anim: LottieAnimationName? = nil, showSuccess: Bool = false) -> SuccessPopUpView {
        let obj = Bundle.main.loadNibNamed("SuccessPopUpView", owner: nil, options: nil)?.first as! SuccessPopUpView
        _appDelegator.window?.addSubview(obj)
        obj.addConstraintToSuperView(lead: 0, trail: 0, top: 0, bottom: 0)
        obj.isHidden = true
        obj.animateIn()
        obj.viewImage.isHidden = img == nil
        obj.viewAnimation.isHidden = anim == nil
        obj.imgSuccess.isHidden = !showSuccess
        obj.prepareUI(title, desc, img, isVerifyPopUp: isVerifyPopUp, isGIF: isGIF, anim, showSuccess: showSuccess)
        return obj
    }
    
    /// In Out Animation
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
            self.stopAnimation()
            self.removeFromSuperview()
        }
    }
}

// MARK: - UI & Animations
extension SuccessPopUpView {
    
    func prepareUI(_ title: String, _ desc: String,_ img: (String, UIImage?)? = nil, isVerifyPopUp: Bool = false, isGIF: Bool = false, _ anim: LottieAnimationName?, showSuccess: Bool = false) {
        lblTitle.text = title
        lblMessage.text = desc
        imgVerify.isHidden = !isVerifyPopUp
        viewImage.borderWidth = isVerifyPopUp ? 1 : 0
        imgSuccess.isHidden = !showSuccess
        
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
}

// MARK: - Button Actions
extension SuccessPopUpView {
    
    @IBAction func btnCloseTap(_ sender: UIButton) {
        animateOut {
            self.callBack?()
        }
    }
    @IBAction func btnSubmitTap(_ sender: UIButton) {
        animateOut {
            self.callBack?()
        }
    }
}
