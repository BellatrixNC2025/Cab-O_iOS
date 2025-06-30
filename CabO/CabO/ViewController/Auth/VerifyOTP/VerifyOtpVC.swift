//
//  VerifyOtpVC.swift
//  CabO
//
//  Created by Octos.
//

import UIKit
import Lottie

//MARK: - VerifyOtpVC
class VerifyOtpVC: ParentVC {
    
    /// Outlets
    @IBOutlet weak var topRightVector: UIImageView!
    @IBOutlet weak var viewAnimation: LottieAnimationView!
    @IBOutlet weak var topRightImage: UIImageView!
    @IBOutlet weak var topHeaderView: UIView!
    @IBOutlet weak var imgBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var animationHeight: NSLayoutConstraint!
    @IBOutlet weak var topRightImageHeight: NSLayoutConstraint!
    
    /// Variables
    var tableHeaderHeight:CGFloat = _screenSize.height / 3
    var arrCells: [VerifyOtpCells] = VerifyOtpCells.allCases
    var screenType: OtpVCType = .updateMobile
    var isResendOtp: Bool = false
    var otpStr:String = ""
    var errOtpStr: String = ""
    var otpCounter: Int = Setting.otpTimeSec
    var emailMobile: String!
    
    var resendOtpStr: NSAttributedString {
        let fontSize = 13 * _fontRatio
        let normalAttribute = [NSAttributedString.Key.foregroundColor: AppColor.primaryTextDark, NSAttributedString.Key.font: AppFont.fontWithName(.mediumFont, size: fontSize)]
        let tagAtributes: [NSAttributedString.Key : Any] = [ NSAttributedString.Key.foregroundColor: AppColor.primaryTextDark, NSAttributedString.Key.attachment : "resend", NSAttributedString.Key.font: AppFont.fontWithName(.bold, size: fontSize)]
        let para = NSMutableParagraphStyle()
        para.minimumLineHeight = 20
        para.maximumLineHeight = 20
        para.alignment = .center
        let mutableStr = NSMutableAttributedString(attributedString: NSAttributedString.attributedText(texts: ["Didn’t receive verification code yet? ", "Resend"], attributes: [normalAttribute, tagAtributes]))
        let range = NSMakeRange(0, mutableStr.string.count)
        mutableStr.addAttribute(NSAttributedString.Key.paragraphStyle, value: para, range: range)
        
        return mutableStr
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareU()
        addKeyboardObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        loadAnimation(named: screenType.animationType)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        stopAnimation()
    }
}

//MARK: - UI Methods
extension VerifyOtpVC {
    
    func prepareU() {
//        tableView.contentInset = UIEdgeInsets(top: _screenSize.height / 3, left: 0, bottom: 0, right: 0)
//        imgBottomConstraint.constant = (DeviceType.iPad ? 24 : 0) * _widthRatio
//        animationHeight.constant = 164 * _widthRatio
//        topRightImageHeight.constant = 164 * _widthRatio
        
        registerCells()
        
        if screenType == .registerEmail {
            emailMobile = _user!.emailAddress
        } else if screenType == .registerMobile {
            emailMobile = _user!.mobileNumber
        }
        
        if screenType != .registerEmail && screenType != .registerMobile {
            resendOtp()
        }
        
        if isResendOtp {
            resendOtp()
        }
        
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//            let headerRect = CGRect(x: 0, y: -self.tableHeaderHeight, width: self.tableView.bounds.width, height: self.tableHeaderHeight + _statusBarHeight)
//            self.topHeaderView!.frame = headerRect
//        }
//        prepareTblHeader()
//        topRightImage.isHidden = false
//        viewAnimation.isHidden = true
//        topRightImage.loadGif(name: screenType.gif)
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
    
    func registerCells() {
        TitleTVC.prepareToRegisterCells(tableView)
        OtpCell.prepareToRegisterCells(tableView)
        ButtonTableCell.prepareToRegisterCells(tableView)
    }
    
    func prepareTblHeader() {
        tableView.tableHeaderView = nil
        topHeaderView.clipsToBounds = false
//        topHeaderView.layer.zPosition = -1
//        tableView.addSubview(topHeaderView!)
//        tableView.contentInset = UIEdgeInsets(top: (tableHeaderHeight - _statusBarHeight), left: 0, bottom: 0, right: 0)
//        tableView.contentOffset = CGPoint(x: 0, y: -(tableHeaderHeight + _statusBarHeight))
    }
}

// MARK: - Actions
extension VerifyOtpVC {
    
    func btnResenrOtpTap() {
        otpStr = ""
        otpCounter = Setting.otpTimeSec
        tableView.reloadData()
        
        resendOtp()
    }
    
    func openEditPopUp() {
        let isEmail: Bool = EnumHelper.checkCases(screenType, cases: [.updateEmail, .registerEmail, .forgotEmail])
        let editPopup = InputPopView.initWith(title: isEmail ? "Edit" : "Edit Mobile",
                                              subTitle: "",
                                              tfTitle: isEmail ? "Email address" : "Mobile Number",
                                              tfPlace: isEmail ? "Enter email address" : "Enter Mobile Number",
                                              imgLeft: isEmail ? UIImage(named: "ic_mail")! : UIImage(named: "ic_mobile")!,
                                              keyboardType: isEmail ? .emailAddress : .phonePad,
                                              maxLength : isEmail ? 32 : 10,
                                              isEmail: isEmail)
        editPopup.btnSubmitTap = { [weak self] (str) in
            guard let `self` = self else { return }
            self.updateMobileEmail(str)
        }
    }
    
    @IBAction func button_backTap(_ sender: UIButton) {
        if screenType == .registerEmail || screenType == .registerMobile {
            self.showCentralSpinner()
            if _appDelegator.isUserLoggedIn() {
                _appDelegator.prepareForLogout { [weak self] (success, json) in
                    guard let `self` = self else { return }
                    self.hideCentralSpinner()
                }
            } else {
                self.navigationController?.popToRootViewController(animated: true)
            }
        } else if screenType == .updateEmail || screenType == .updateMobile {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
}

//MARK: - TableView Methods
extension VerifyOtpVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrCells.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellType = arrCells[indexPath.row]
        if cellType == .title {
            return TitleTVC.height(for: screenType.title, width: _screenSize.width - (32 * _widthRatio), font: AppFont.fontWithName(.bold, size: 30 * _fontRatio))
        }
        if cellType == .subtitle {
            return TitleTVC.height(for: screenType.subTitle, width: _screenSize.width - (32 * _widthRatio), font: AppFont.fontWithName(.mediumFont, size: 16 * _fontRatio))
        }
        if cellType == .otp && !errOtpStr.isEmpty{
            return OtpCell.errorHeight
        }
        return arrCells[indexPath.row].cellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: arrCells[indexPath.row].cellId, for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cellType = arrCells[indexPath.row]
        if let cell = cell as? TitleTVC {
            if cellType == .title {
                cell.prepareUI(screenType.title, AppFont.fontWithName(.bold, size: 30 * _fontRatio), clr: AppColor.primaryTextDark)
                applyRoundedBackground(to: cell, at: indexPath, in: tableView, isTopRadius: true)
            }
            else if cellType == .subtitle {
                cell.prepareUI(screenType.subTitle, AppFont.fontWithName(.mediumFont, size: 16 * _fontRatio), clr: AppColor.primaryTextDark)
                applyRoundedBackground(to: cell, at: indexPath, in: tableView)
            }
            
        }
        
        else if let cell = cell as? ChangeOtpInfoCell {
            if screenType == .registerEmail || screenType == .registerMobile {
                cell.lblInfo.text = screenType == .registerEmail ? emailMobile : emailMobile.formatPhoneNumber()
                cell.buttonEdit.isHidden = false
            } else if screenType == .forgotEmail || screenType == .forgotMobile {
                cell.lblInfo.text = emailMobile
                cell.buttonEdit.isHidden = true
            } else {
                if EnumHelper.checkCases(screenType, cases: [.forgotMobile, .updateMobile, .registerMobile]) {
                    cell.lblInfo.text = emailMobile.formatPhoneNumber()
                } else {
                    cell.lblInfo.text = emailMobile
                }
                cell.buttonEdit.isHidden = true
            }
            applyRoundedBackground(to: cell, at: indexPath, in: tableView)
            cell.btnChangeAction = {
                self.openEditPopUp()
            }
        }
        else if let cell = cell as? OtpCell {
            cell.parentVC = self
            cell.txtF.textContentType = .oneTimeCode
            applyRoundedBackground(to: cell, at: indexPath, in: tableView)
        }
        else if let cell = cell as? OTPTimerCell {
            cell.tag = indexPath.row
            cell.delegate = self
            cell.lblResend.setTagText(attriText: resendOtpStr, linebreak: .byTruncatingTail)
            cell.lblResend.delegate = self
            applyRoundedBackground(to: cell, at: indexPath, in: tableView, isBottomRadius: true)
        }
        else if let cell = cell as? ButtonTableCell {
            cell.btn.setTitle("Verify OTP", for: .normal)
            cell.btnTapAction = { [weak self] (_) in
                guard let `self` = self else { return }
                if self.screenType == .forgotEmail || self.screenType == .forgotMobile {
                    self.verifyForgotOtp()
                } else if self.screenType == .updateEmail || self.screenType == .updateMobile {
                    self.verifyUpdateProfileOtp()
                } else {
                    self.verifyOtp()
                }
            }
        }
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
//        var headerRect = CGRect(x: 0, y: -tableHeaderHeight, width: tableView.bounds.width, height: tableHeaderHeight + _statusBarHeight)
//        if tableView.contentOffset.y < -tableHeaderHeight {
//            headerRect.origin.y = tableView.contentOffset.y
//            headerRect.size.height = -tableView.contentOffset.y + _statusBarHeight
//        }
//        topHeaderView!.frame = headerRect
    }
}

// MARK: - NLinkLabelDelagete
extension VerifyOtpVC: NLinkLabelDelagete {
    
    func tapOnEmpty(index: IndexPath?) {}
    
    func tapOnTag(tagName: String, type: ActiveType, tappableLabel: NLinkLabel) {
        nprint(items: tagName)
        if tagName == "resend" {
            btnResenrOtpTap()
        }
    }
}

// MARK: - UIKeyboard Observer
extension VerifyOtpVC {
    
    func addKeyboardObserver() {
//        _defaultCenter.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
//        _defaultCenter.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
//    
//    @objc func keyboardWillShow(_ notification: NSNotification){
//        if let userInfo = notification.userInfo {
//            if let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
//                guard let _ = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {return}
//                tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height + 10, right: 0)
//            }
//        }
//    }
//    
//    @objc func keyboardWillHide(_ notification: NSNotification){
//        guard let _ = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {return}
//        tableView.contentInset = UIEdgeInsets(top: (tableHeaderHeight - _statusBarHeight), left: 0, bottom: 0, right: 0)
//    }
}

// MARK: - API Call
extension VerifyOtpVC {
    
    func resendOtp() {
        showCentralSpinner()
        var param: [String: Any] = [:]
        param["source"] = screenType.resendSource
        param["sourceid"] = emailMobile
        
        WebCall.call.resendOtp(param: param) { [weak self] (json, status) in
            guard let `self` = self else { return }
            self.hideCentralSpinner()
            if status == 200 {
                self.showSuccessMsg(data: json, yCord: _statusBarHeight)
                self.otpStr = ""
                self.tableView.reloadData()
            }
        }
    }
    
    func updateMobileEmail(_ str: String) {
        showCentralSpinner()
        var param: [String: Any] = [:]
        param["sourcefrom"] = screenType.sourceFrom
        param["source"] = screenType.sourceType
        param["sourceid"] = str
        WebCall.call.updateEmailMobile(param: param) { [weak self] (json, status) in
            guard let `self` = self else { return }
            self.hideCentralSpinner()
            if status == 200 {
                self.showSuccessMsg(data: json)
                self.emailMobile = str
                self.otpStr = ""
                self.resendOtp()
                self.tableView.reloadData()
            } else {
                self.showError(data: json)
            }
        }
    }
    
    func verifyOtp() {
        if otpStr.count < 4 {
            ValidationToast.showStatusMessage(message: "Please enter valid verification code")
        } else {
            let cell = tableViewCell(index: arrCells.firstIndex(of: .btn)!) as! ButtonTableCell
            self.showSpinnerIn(container: cell.bgView, control: cell.btn, isCenter: true)
            
            var param: [String: Any] = [:]
            param["otp_number"] = otpStr
            param["source"] = screenType.sourceType
            param["sourceid"] = emailMobile
            
            WebCall.call.verifyOtp(param: param.merged(with: Setting.deviceInfo)) { [weak self] (json, status) in
                guard let `self` = self else { return }
                self.hideSpinnerIn(container: cell.bgView, control: cell.btn)
                if status == 200, let dict = json as? NSDictionary, let data = dict["data"] as? NSDictionary{
                    let token = data.getStringValue(key: "token")
                    if !token.isEmpty {
                        _appDelegator.storeAuthorizationToken(token)
                        _appDelegator.saveContext()
                    }
                    
                    if self.screenType == .registerMobile {
                        _userDefault.set(true, forKey: "mobileVerify")
                        _userDefault.synchronize()
                    } else if self.screenType == .registerEmail {
                        _userDefault.set(true, forKey: "emailVerify")
                        _userDefault.synchronize()
                    }
                    
                    let user = LoginResponse(data)
                    if self.screenType == .registerMobile && !(_userDefault.value(forKey: "emailVerify") as! Bool) {
                        let vc = VerifyOtpVC.instantiate(from: .Auth)
                        vc.screenType = .registerEmail
                        self.navigationController?.pushViewController(vc, animated: true)
                    }else if user.role == .driver {
                        let vc = SubscriptionVC.instantiate(from: .Profile)
                        vc.isFromSideMenu = false
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
//                    else if !user.personalInfoAdded {
//                        let vc = SignUpVC.instantiate(from: .Auth)
//                        vc.screenType = .personal
//                        vc.loginResponse = LoginResponse(data)
//                        self.navigationController?.pushViewController(vc, animated: true)
//                    }
//                    else if !user.emergencyContactAdded {
//                        let vc = SignUpVC.instantiate(from: .Auth)
//                        vc.screenType = .emergency
//                        vc.loginResponse = LoginResponse(data)
//                        self.navigationController?.pushViewController(vc, animated: true)
//                    }
                    else {
                        _appDelegator.navigateUserToHome()
                    }
                } else {
                    self.showError(data: json)
                }
            }
        }
    }
    
    func verifyForgotOtp() {
        if otpStr.count < 4 {
            ValidationToast.showStatusMessage(message: "Please enter valid verification code")
        } else {
            let cell = tableViewCell(index: arrCells.firstIndex(of: .btn)!) as! ButtonTableCell
            self.showSpinnerIn(container: cell.bgView, control: cell.btn, isCenter: true)
            
            var param: [String: Any] = [:]
            param["forgot_otp_number"] = otpStr
            param["source"] = emailMobile.isNumeric ? "mobile" : "email"
            param["sourceid"] = emailMobile
            
            WebCall.call.verifyForgotOtp(param: param) { [weak self] (json, status) in
                guard let `self` = self else { return }
                self.hideSpinnerIn(container: cell.bgView, control: cell.btn)
                if status == 200, let dict = json as? NSDictionary, let data = dict["data"] as? NSDictionary{
                    let userId = data.getStringValue(key: "user_id")
                    
                    let vc = ResetPasswordVC.instantiate(from: .Auth)
                    vc.userId = userId
                    self.navigationController?.pushViewController(vc, animated: true)
                } else {
                    self.showError(data: json)
                }
            }
        }
    }
    
    func verifyUpdateProfileOtp() {
        if otpStr.count < 4 {
            ValidationToast.showStatusMessage(message: "Please enter valid verification code")
        } else {
            let cell = tableViewCell(index: arrCells.firstIndex(of: .btn)!) as! ButtonTableCell
            self.showSpinnerIn(container: cell.bgView, control: cell.btn, isCenter: true)
            
            var param: [String: Any] = [:]
            param["otp_number"] = otpStr
            param["source"] = emailMobile.isNumeric ? "mobile" : "email"
            param["sourceid"] = emailMobile
            param["is_social"] = _user!.isSocialUser ? 1 : 0
            
            WebCall.call.verifyUpdateProfileOtp(param: param.merged(with: Setting.deviceInfo)) { [weak self] (json, status) in
                guard let `self` = self else { return }
                self.hideSpinnerIn(container: cell.bgView, control: cell.btn)
                if status == 200{//}, let dict = json as? NSDictionary, let data = dict["data"] as? NSDictionary{
                    self.showSuccessMsg(data: json)
                    if _user!.isSocialUser {
                        self.showCentralSpinner()
                        _appDelegator.prepareForLogout { [weak self] (success, json) in
                            guard let weakSelf = self else { return }
                            weakSelf.hideCentralSpinner()
                        }
                    }
                    else {
                        _defaultCenter.post(name: Notification.Name.userProfileUpdate, object: nil)
                        self.navigationController?.popViewController(animated: true)
                    }
                } else {
                    self.showError(data: json)
                }
            }
        }
    }
}
