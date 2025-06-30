//
//  LoginCells.swift
//  CabO
//
//  Created by Octos.
//

import Foundation
import UIKit

//MARK: - ForgotPasBtnCell
class CenterButtonTableCell: ConstrainedTableViewCell {
    
    /// Outlets
    @IBOutlet weak var btn: UIButton!
    
    /// Variables
    var btnTapAction: (() -> ())?
    var btnInfoTapAction: ((AnyObject) -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    /// Actions
    @IBAction func btnTapAction(sender: UIButton) {
        btnTapAction?()
    }
    
    @IBAction func btn_info_tap(_ sender: UIButton) {
        btnInfoTapAction?(sender)
    }
}

// MARK: - LoginCell
class LoginCell: ConstrainedTableViewCell {
    
    /// Outlets
    @IBOutlet weak var imgGoogle : UIImageView!
    @IBOutlet weak var btnGoogle : UIButton!
    @IBOutlet weak var imgFacebook : UIImageView!
    @IBOutlet weak var btnFacebook : UIButton!
    @IBOutlet weak var imgApple : UIImageView!
    @IBOutlet weak var btnApple : UIButton!
    
    /// Variables
    var action_social_login: ((Int) -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    /// Prepare Cell UI
    func prepareUI() {
        let config = _appDelegator.config
        imgApple.isHidden = !config.isAppleOn
        btnApple.isHidden = !config.isAppleOn
        
        imgGoogle.isHidden = !config.isGoogleOn
        btnGoogle.isHidden = !config.isGoogleOn
        
//        imgFacebook.isHidden = !config.isFacebookOn
//        btnFacebook.isHidden = !config.isFacebookOn
    }
    
    /// Social Login Tap Action
    @IBAction func btn_social_tap(_ sender: UIButton) {
        action_social_login?(sender.tag)
    }
}
