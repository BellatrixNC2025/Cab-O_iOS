//
//  LoginVC.swift
//  CabO
//
//  Created by Octos.
//

import UIKit

class AppThemePopupView: ConstrainedView {
    
    /// Outlets
    @IBOutlet weak var viewBg: UIView!
    @IBOutlet weak var popupView: NRoundView!
    @IBOutlet weak var centerConst: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addThemeObserver()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if _appTheme != .system {
            self.overrideUserInterfaceStyle = appTheme
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.first?.view == viewBg {
            animateOut(comp: nil)
        }
    }
    
    /// Initialiser
    class func initWith() -> AppThemePopupView {
        let obj = Bundle.main.loadNibNamed("AppThemePopupView", owner: nil, options: nil)?.first as! AppThemePopupView
        _appDelegator.window?.addSubview(obj)
        obj.addConstraintToSuperView(lead: 0, trail: 0, top: 0, bottom: 0)
        obj.animateIn()
        return obj
    }

    /// In Out Animation
    func animateIn() {
        self.isHidden = false
        viewBg.alpha = 0
        popupView.alpha = 0
        centerConst.constant = 600
        self.layoutIfNeeded()
        centerConst.constant = 0
        UIView.animate(withDuration: 0.25, animations: {
            self.viewBg.alpha = 1
            self.popupView.alpha = 1
            self.layoutIfNeeded()
        }) { (success) in
            
        }
    }
    
    func animateOut(comp: (() -> ())?) {
        centerConst.constant = 600
        UIView.animate(withDuration: 0.25, animations: {
            self.viewBg.alpha = 0
            self.popupView.alpha = 0
            self.layoutIfNeeded()
        }) { (success) in
            self.removeFromSuperview()
            NotificationCenter.default.post(name: Notification.Name.themeUpdateNotification, object: nil)
            comp?()
        }
    }
}

//MARK: - Actions
extension AppThemePopupView {
    
    @IBAction func btnThemeSeleced(_ sender: UIButton) {
        DispatchQueue.main.async {
            let theme = AppThemeType(rawValue: sender.tag)!
            _userDefault.set(theme.rawValue, forKey: _CabOAppTheme)
            _userDefault.synchronize()
            _appTheme = theme
            
            nprint(items: [sender.tag ,theme.rawValue, appTheme.rawValue])
            
            if _appTheme != .system {
                self.overrideUserInterfaceStyle = appTheme
            }
            self.animateOut(comp: nil)
        }
    }
}

