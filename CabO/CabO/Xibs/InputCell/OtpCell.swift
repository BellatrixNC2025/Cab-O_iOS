//
//  LoginVC.swift
//  CabO
//
//  Created by Octos.
//

import Foundation
import UIKit

class OtpCell: UITableViewCell {
    
    /// Statis Constants
    static let otpIdentifier: String = "otpCell"
    static let normalHeight: CGFloat = 82 * _widthRatio
    static let errorHeight: CGFloat = 82 * _widthRatio
    static let removeErrorHeight: Int = Int(errorHeight - normalHeight)
    
    /// Outlet(s)
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet var lblOtp: [UILabel]!
    @IBOutlet weak var txtF: UITextField!
    @IBOutlet var bgView: [NRoundView]!
    @IBOutlet weak var lblError: UILabel!
    
    weak var parentVC: ParentVC! {
        didSet {
            prepareUI()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

//MARK: - UI Methods
extension OtpCell {
    
    func prepareUI() {
        prepareOtpUI()
        prepareValidationUI()
        
        if let parent = parentVC as? StartBookingVC {
            lblTitle.isHidden = true
            txtF.text = parent.otpStr
            prepareOtpUI()
        } else if let parent = parentVC as? VerifyOtpVC {
            txtF.text = parent.otpStr
            prepareOtpUI()
        }
    }
    
    func prepareOtpUI() {
        for lbl in lblOtp {
            lbl.text = "X"
            lbl.textColor = AppColor.placeholderText
            
            if let vwBg = lbl.superview as? NRoundView {
                vwBg.borderColor = AppColor.textfieldBorder
                vwBg.backgroundColor = AppColor.textfieldBgDark
            }
        }
        for (idx,str) in txtF.text!.enumerated() {
            lblOtp[idx].text = String("\(str)")
            lblOtp[idx].textColor = AppColor.primaryTextDark
            
            if let vwBg = lblOtp[idx].superview as? NRoundView {
                vwBg.borderColor = AppColor.themePrimary | AppColor.themePrimary
                vwBg.backgroundColor = .white
            }
        }
        
        if let _ = parentVC as? VerifyOtpVC {
//            parent.prepareSendBtn()
        }
    }
    
    func prepareValidationUI() {
        if let parent = parentVC as? VerifyOtpVC {
            lblError.isHidden = true
            if !parent.errOtpStr.isEmpty {
                lblError.isHidden = false
                lblError.text = parent.errOtpStr
            }
        } else if let parent = parentVC as? StartBookingVC {
            lblError.isHidden = true
            if !parent.errOtpStr.isEmpty {
                lblError.isHidden = false
                lblError.text = parent.errOtpStr
            }
        }
    }
}

// MARK: - UITextFieldDelegate
extension OtpCell: UITextFieldDelegate {
    
    @IBAction func textChanged(_ sender: UITextField) {
        if let parent = parentVC as? VerifyOtpVC {
            parent.otpStr = sender.text!.trimmedString()

            if !parent.errOtpStr.isEmpty {
                tableView?.beginUpdates()
                parent.errOtpStr = ""
                lblError.isHidden = true
                tableView?.endUpdates()
            }
        }
        else if let parent = parentVC as? StartBookingVC {
            parent.otpStr = sender.text!.trimmedString()

            if !parent.errOtpStr.isEmpty {
                tableView?.beginUpdates()
                parent.errOtpStr = ""
                lblError.isHidden = true
                tableView?.endUpdates()
            }
        }
        prepareOtpUI()
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let vwBg = textField.superview as? NRoundView {
            vwBg.borderColor = AppColor.themePrimary | AppColor.themePrimary
            vwBg.backgroundColor = .white
        }
//        bgView.forEach { vw in
//            vw.isSelected = btn.tag == currentPage ? true : false
            
//        }
        
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let vwBg = textField.superview as? NRoundView {
            vwBg.borderColor = AppColor.textfieldBorder
            vwBg.backgroundColor = AppColor.textfieldBgDark
        }
    }
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let char = string.cString(using: String.Encoding.utf8)!
        let isBackSpace = strcmp(char, "\\b")
        if isBackSpace != -92 {
            return string != " " && textField.text?.count ?? 0 <= 3
        }
        return true
    }
}

//MARK: - Register Cell
extension OtpCell {
    
    class func prepareToRegisterCells(_ sender: UITableView) {
        sender.register(UINib(nibName: "OtpCell", bundle: nil), forCellReuseIdentifier: otpIdentifier)
    }
}
