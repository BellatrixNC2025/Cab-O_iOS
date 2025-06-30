//  Created by Tom Swindell on 07/12/2015.
//  Copyright © 2015 The App Developers. All rights reserved.
//

import UIKit

class StatusBarHidingViewController: UIViewController {
    
    var isStatusbarShow: Bool = false {
        didSet {
            self.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return !isStatusbarShow
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

// MARK: - KPValidationToast
class KPValidationToast {
    
    static var shared = KPValidationToast()
    
    let alertWindow: UIWindow!
    init() {
        alertWindow = UIWindow()
        alertWindow.isUserInteractionEnabled = false
        alertWindow.rootViewController = StatusBarHidingViewController()
        alertWindow.backgroundColor = UIColor.clear
        if #available(iOS 13.0, *) {
            alertWindow.windowScene = _appDelegator.window?.windowScene
        } else {
            // Fallback on earlier versions
        }
        alertWindow.windowLevel = UIWindow.Level.alert//statusBar + 1
//        alertWindow.makeKeyAndVisible()
        alertWindow.isHidden = true
    }
    
    /// It will diaplay toast on status bar
    /// - Parameters:
    ///   - message: Message for toast
    ///   - color: toast background color
    /// - Returns: ValidationToast View
    func showToastOnStatusBar(message: String, color: UIColor = AppColor.errorToastColor) -> ValidationToast {
        let toast: ValidationToast
        var height: CGFloat = 0
        if _statusBarHeight > 20 {
            toast = UINib(nibName: "ValidationToast", bundle: Bundle.main).instantiate(withOwner: nil, options: nil)[1] as! ValidationToast
            toast.setToastMessage(message: message)
            toast.animatingView.backgroundColor = color
            height = message.heightWithConstrainedWidth(width: _screenSize.width - (20 * _widthRatio), font: AppFont.fontWithName(.regular, size: 14 * _fontRatio)) + (45 * _widthRatio)
            updateStatusBarUI(isShow: true)
        } else {
            toast = UINib(nibName: "ValidationToast", bundle: Bundle.main).instantiate(withOwner: nil, options: nil)[0] as! ValidationToast
            toast.setToastMessage(message: message)
            toast.animatingView.backgroundColor = color
            height = message.heightWithConstrainedWidth(width: _screenSize.width - (20 * _widthRatio), font: AppFont.fontWithName(.regular, size: 14 * _fontRatio)) + (8 * _widthRatio)
            updateStatusBarUI(isShow: false)
        }
        
        toast.layoutIfNeeded()
        toast.animatingViewBottomConstraint.constant = height
        toast.setToastMessage(message: message)
        toast.animatingView.backgroundColor = color
        alertWindow.isHidden = false
        alertWindow.addSubview(toast)
        toast.animatingViewBottomConstraint.constant = height
        var f = CGRect.zero
        f = UIScreen.main.bounds
        f.size.height = height
        f.origin = CGPoint(x: 0, y: 0)
        toast.frame = f
        
        toast.layoutIfNeeded()
        toast.animateIn(duration: 0.2, delay: 0.2, completion: { () -> () in
            toast.animateOutWith(height: height,duration: 0.2, delay: 1.5, completion: { () -> () in
                toast.removeFromSuperview()
                self.updateStatusBarUI(isShow: true)
                self.alertWindow.isHidden = true
            })
        })
        return toast
    }
    
    /// It will update statusbar UI
    /// - Parameter isShow: boolean value true to display statusbar
    func updateStatusBarUI(isShow: Bool) {
        if let vc = alertWindow.rootViewController as? StatusBarHidingViewController {
            vc.isStatusbarShow = isShow
        }
    }
    
    /// It will display sticky toast view in case of unavailablity of internet
    /// - Parameters:
    ///   - message: Message to display
    ///   - color: background color
    /// - Returns: ValidationToast View
    func showStatusMessageForInterNet(message: String, withColor color: UIColor = AppColor.errorToastColor) -> ValidationToast {
        let toast: ValidationToast
        var height: CGFloat = 0
        if _statusBarHeight > 20 {
            toast = UINib(nibName: "ValidationToast", bundle: Bundle.main).instantiate(withOwner: nil, options: nil)[1] as! ValidationToast
            toast.setToastMessage(message: message)
            toast.animatingView.backgroundColor = color
            height = (20 * _widthRatio) + _statusBarHeight
            updateStatusBarUI(isShow: true)
        } else {
            toast = UINib(nibName: "ValidationToast", bundle: Bundle.main).instantiate(withOwner: nil, options: nil)[0] as! ValidationToast
            toast.setToastMessage(message: message)
            toast.animatingView.backgroundColor = color
            height = _statusBarHeight
            updateStatusBarUI(isShow: false)
        }
        alertWindow.isHidden = false
        alertWindow.addSubview(toast)
        toast.animatingViewBottomConstraint.constant = height
        var f = CGRect.zero
        f = UIScreen.main.bounds
        f.size.height = height
        f.origin = CGPoint(x: 0, y: 0)
        toast.frame = f
        toast.layoutIfNeeded()
        toast.animateIn(duration: 0.2, delay: 0.2, completion: { () -> () in
        })
        return toast
    }
    
    func hideStatusMessageForInterNet() {
        alertWindow.isHidden = true
    }
}

class ValidationToast: UIView {

    // MARK: - Button Action
    @IBAction func btnTap (sender: UIButton){
        self.tapCompletions?(self)
    }
    
    // MARK: - Outlets
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var animatingViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var animatingView: UIView!
    
    // MARK: - Variables
    var tapCompletions: ((ValidationToast)->())?
    
    // MARK: - Initialisers
    
    @discardableResult
    /// It will return neglatable ValidationToast View with configured message and color and with image
    /// - Parameters:
    ///   - message: message for toast
    ///   - msgColor: color for message string
    ///   - img: img to show on toast
    ///   - yCord: from where to start displaying
    ///   - view: optional view incase to to show in perticular view
    ///   - color: toast background color
    /// - Returns: Discardable validation toast view
    class func showStatusMessage(message: String, yCord: CGFloat = _statusBarHeight, inView view: UIView? = nil, isSucess: Bool = false, msgColor: UIColor? = nil, withColor color: UIColor? = nil) -> ValidationToast {
        
        let toast = UINib(nibName: "ValidationToast", bundle: Bundle.main).instantiate(withOwner: nil, options: nil)[3] as! ValidationToast
        let strHeight = message.heightWithConstrainedWidth(width: _screenSize.width - (66 * _widthRatio), font: AppFont.fontWithName(.regular, size: 14 * _fontRatio)) + (16 * _widthRatio)
             
        toast.layoutIfNeeded()
        toast.animatingViewBottomConstraint.constant = strHeight//28 * _widthRatio
        
        let msgClr = msgColor != nil ? msgColor! : isSucess ? AppColor.successToastColor : .white
        let clr = color != nil ? color! : isSucess ? AppColor.successToastColor : AppColor.errorToastColor
        
        toast.setToastMessage(message: message, msgColor: msgClr)
        toast.animatingView.backgroundColor = clr
        
        var f = CGRect.zero
        if let vw = view {
            vw.addSubview(toast)
            f = vw.frame
        } else {
            _appDelegator.window?.addSubview(toast)
            f = UIScreen.main.bounds
        }
        f.size.height = strHeight
        f.origin = CGPoint(x: 0, y: yCord + (4 * _heightRatio))
        toast.frame = f
        toast.animateIn(duration: 0.2, delay: 0.2, completion: { () -> () in
            toast.animateOutWith(height: strHeight,duration: 0.2, delay: 1.5, completion: { () -> () in
                toast.removeFromSuperview()
            })
        })
        return toast
    }
    
    // MARK: - Toast Functions
    /// It will set given string as message in toast
    /// - Parameter message: message for toast
    /// - Parameter msgColor: color for the toast message
    func setToastMessage(message: String, msgColor: UIColor = .white) {
        let font = AppFont.fontWithName(.regular, size: 14 * _fontRatio)
        let color = msgColor
        let mutableString = NSMutableAttributedString(string: message)
        let range = NSMakeRange(0, message.length)
        mutableString.addAttribute(NSAttributedString.Key.font, value: font, range: range)
        mutableString.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
        messageLabel.attributedText = mutableString
    }
    
    /// It will set given string as message in toast
    /// - Parameter message: message for toast
    /// - Parameter msgColor: color for the toast message
    func setToastCurrencyMessage(message: String, msgColor: UIColor = .white) {
        messageLabel.text = message
        messageLabel.textColor = msgColor
        messageLabel.font = AppFont.fontWithName(.regular, size: 14 * _fontRatio)
    }
    
    /// It will animate the toast view for Animating in
    /// - Parameters:
    ///   - duration: animation duration
    ///   - delay: delay for animation
    ///   - completion: completion closure
    func animateIn(duration: TimeInterval, delay: TimeInterval, completion: (() -> ())?) {
        animatingViewBottomConstraint.constant = 0
        UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions.curveEaseOut, animations: { () -> Void in
            self.layoutIfNeeded()
            }) { (completed) -> Void in
                completion?()
        }
    }
    
    /// It will animate the toast view for Animating Out
    /// - Parameters:
    ///   - duration: animation duration
    ///   - delay: delay for animation
    ///   - completion: completion closure
    func animateOut(duration: TimeInterval, delay: TimeInterval, completion: (() -> ())?) {
        animatingViewBottomConstraint.constant = 44 * _widthRatio
        UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions.curveEaseOut, animations: { () -> Void in
            self.layoutIfNeeded()
            }) { (completed) -> Void in
                completion?()
        }
    }
    
    /// It will set the height of the animation view to a given height and afterward it will animate out
    /// - Parameters:
    ///   - height: expected height of animating view
    ///   - duration: animation duration
    ///   - delay: delay for animation
    ///   - completion: completion closure
    func animateOutWith(height: CGFloat, duration: TimeInterval, delay: TimeInterval, completion: (() -> ())?) {
        animatingViewBottomConstraint.constant = height
        UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions.curveEaseOut, animations: { () -> Void in
            self.layoutIfNeeded()
        }) { (completed) -> Void in
            completion?()
        }
    }
}
