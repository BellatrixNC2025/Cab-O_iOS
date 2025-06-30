//
//  LoginVC.swift
//  CabO
//
//  Created by Octos.
//

import Foundation
import UIKit

/// It is used as inputaccessory View in textfields
class NInputAccessoryView: UIToolbar {
    
    /// Outlets
    @IBOutlet weak var rightBtn: UIBarButtonItem!
    @IBOutlet weak var leftBtn: UIBarButtonItem!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    /// Initialiser
    class func initView(leftTitle: String?, rightTitle: String?) -> NInputAccessoryView {
        let obj = Bundle.main.loadNibNamed("NInputAccessoryView", owner: nil, options: nil)?.first as! NInputAccessoryView
        obj.leftBtn.title = leftTitle
        obj.rightBtn.title = rightTitle
        return obj
    }
}
