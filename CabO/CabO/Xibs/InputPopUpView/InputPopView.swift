//
//  LoginVC.swift
//  CabO
//
//  Created by Octos.
//

import UIKit

class InputPopView: ConstrainedView {
    
    /// Outlets
    @IBOutlet weak var viewBg: UIView!
    @IBOutlet weak var popupView: NRoundView!
    @IBOutlet weak var bottomConst: NSLayoutConstraint!
    @IBOutlet weak var tfContainer: NRoundView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblSubTitle: UILabel!
    @IBOutlet weak var lblInputTitle: UILabel!
    @IBOutlet weak var tfInput: UITextField!
    @IBOutlet weak var imgTfLeft: UIImageView!
    @IBOutlet weak var vwTfLeft: UIView!
    @IBOutlet weak var btnYes: UIButton!
    @IBOutlet weak var btnNo: NRoundButton!
    
    @IBOutlet weak var lblInfoText: UILabel!
    @IBOutlet weak var viewInfo: UIView!
    
    /// Variables
    private let placeholderFont: UIFont = AppFont.fontWithName(.regular, size: 14 * _fontRatio)
    var btnCancelTap: (() -> ())?
    var btnSubmitTap: ((String) -> ())?
    
    var txt: String = ""
    var maxLength: Int?
    var isEmail: Bool = true
    
    lazy var inputAccView: NInputAccessoryView = {
        let view = NInputAccessoryView.initView(leftTitle: nil, rightTitle: "Done")
        view.rightBtn.target = self
        view.rightBtn.action = #selector(self.btnToolNextTap)
        return view
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addThemeObserver()
        lblInputTitle?.font = placeholderFont
        tfInput?.font = placeholderFont
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if _appTheme != .system {
            self.overrideUserInterfaceStyle = appTheme
        }
//        tfContainer?.borderColor = AppColor.primaryText
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if touches.first?.view == viewBg {
            animateOut(comp: nil)
        }
    }
    
    /// Initializer
    class func initWith(title: String, subTitle: String, tfTitle: String, tfPlace: String, imgLeft: UIImage, keyboardType: UIKeyboardType, maxLength: Int? = nil, isEmail: Bool = true, showInfo: Bool = false) -> InputPopView {
        let obj = Bundle.main.loadNibNamed("InputPopView", owner: nil, options: nil)?.first as! InputPopView
        _appDelegator.window?.addSubview(obj)
        obj.addConstraintToSuperView(lead: 0, trail: 0, top: 0, bottom: 0)
        obj.addKeyboardObserver()
        obj.prepareUI(title: title, subTitle: subTitle, tfTitle: tfTitle, tfPlace: tfPlace, imgLeft: imgLeft, keyboardType: keyboardType, maxLength: maxLength, isEmail: isEmail, showInfo: showInfo)
        obj.animateIn()
        return obj
    }
    
    /// In Out Animation
    func animateIn() {
        self.isHidden = false
        viewBg.alpha = 0
        popupView.alpha = 0
//        centerConst.constant = 600
        self.layoutIfNeeded()
//        centerConst.constant = 0
        UIView.animate(withDuration: 0.25, animations: {
            self.viewBg.alpha = 1
            self.popupView.alpha = 1
            self.layoutIfNeeded()
        }) { (success) in
            
        }
    }
    
    func animateOut(comp: (() -> ())?) {
//        centerConst.constant = 600
        UIView.animate(withDuration: 0.25, animations: {
            self.viewBg.alpha = 0
            self.popupView.alpha = 0
            self.layoutIfNeeded()
        }) { (success) in
            self.removeFromSuperview()
            comp?()
        }
    }
    
    @objc func btnToolNextTap() {
        tfInput?.resignFirstResponder()
    }
}

// MARK: - UI Methods
extension InputPopView {
    
    func prepareUI(title: String, subTitle: String, tfTitle: String, tfPlace: String, imgLeft: UIImage, keyboardType: UIKeyboardType, btnYesTitle: String = "Cancel", btnNoTitle: String = "Submit", maxLength: Int? = nil, isEmail: Bool = true, showInfo: Bool = false) {
        lblTitle.text = title
        lblSubTitle.isHidden = subTitle.isEmpty
        lblSubTitle.text = subTitle
        lblInputTitle.text = tfTitle
        self.maxLength = maxLength
        tfInput.setAttributedPlaceHolder(text: tfPlace, font: AppFont.fontWithName(.bold, size: 14 * _fontRatio), color: AppColor.placeholderText, spacing: 0)
        tfInput.keyboardType = keyboardType
        tfInput.returnKeyType = .done
        tfInput.autocorrectionType = .no
        tfInput?.inputAccessoryView = keyboardType == .phonePad ? inputAccView : nil
        self.isEmail = isEmail
        imgTfLeft.image = imgLeft.withTintColor(AppColor.primaryText)
//        tfContainer?.borderColor = AppColor.textfieldBorder
        self.lblInfoText.text = "If you change your email from social login to normal login, you cannot log in with social login anymore. "
        self.viewInfo.isHidden = !showInfo
        
        btnYes.setTitle(btnYesTitle, for: .normal)
        btnNo.setTitle(btnNoTitle, for: .normal)
    }
}

//MARK: - TextField Delegte
extension InputPopView: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        tfInput.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let maxLength {
            let fullText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            if textField.keyboardType == .phonePad {
                return string.isNumeric && fullText.trimmedString().removeSpace().count <= maxLength
            }
            return fullText.count <= maxLength
        }
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
        self.tfContainer.backgroundColor = .white
        self.tfContainer.borderColor = AppColor.themePrimary

    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.tfContainer.borderColor = AppColor.textfieldBorder
        self.tfContainer?.backgroundColor = AppColor.textfieldBgDark
    }
    
    @IBAction func textChanged(_ sender: UITextField) {
        txt = sender.text!.trimmedString()
        if !isEmail {
            sender.text = txt.formatPhoneNumber()
        }
    }
}

//MARK: - Actions
extension InputPopView {
    
    @IBAction func btnYesTap(_ sender :UIButton) {
        animateOut {
            self.btnCancelTap?()
        }
    }
    
    @IBAction func btnNoTap(_ sender: UIButton) {
        if self.txt.isEmpty {
            ValidationToast.showStatusMessage(message: "Please enter valid \(isEmail ? "email address" : "Mobile Number")")
        } else if isEmail && !self.txt.isValidEmailAddress() {
            ValidationToast.showStatusMessage(message: "Please enter valid \(isEmail ? "email address" : "Mobile Number")")
        } else if !isEmail && !self.txt.removeSpace().isValidContact() {
            ValidationToast.showStatusMessage(message: "Please enter valid \(isEmail ? "email address" : "Mobile Number")")
        }
        else {
            animateOut {
                self.btnSubmitTap?(self.isEmail ? self.txt : self.txt.removeSpace())
            }
        }
    }
}

// MARK: - UIKeyboard Observer
extension InputPopView {
    
    func addKeyboardObserver() {
        _defaultCenter.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        _defaultCenter.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    @objc func keyboardWillShow(_ notification: NSNotification){
        if let userInfo = notification.userInfo {
            if let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                guard let _ = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {return}
                bottomConst.constant = keyboardSize.height - 15
            }
        }
    }
//    @objc func keyboardWillShow(_ notification: NSNotification){
//        if let userInfo = notification.userInfo {
//            if userInfo[UIResponder.keyboardFrameEndUserInfoKey] is CGRect {
//                guard let _ = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {return}
//                bottomConst.constant = keyboardSize.height - 110
//                UIView.animate(withDuration: 0.25, animations: {
//                    self.viewBg.alpha = 1
//                    self.layoutIfNeeded()
//                })
//            }
//        }
//    }
    
    @objc func keyboardWillHide(_ notification: NSNotification){
        guard let _ = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {return}
        bottomConst.constant = 0
        UIView.animate(withDuration: 0.25, animations: {
            self.viewBg.alpha = 1
            self.layoutIfNeeded()
        })
    }
}
