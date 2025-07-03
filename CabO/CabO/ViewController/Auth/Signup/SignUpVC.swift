//
//  SignupVC.swift
//  CabO
//
//  Created by Octos.
//

import UIKit

var arrGenders: [Gender] = Gender.allCases

//MARK: - SignUpVC
class SignUpVC: ParentVC {
   
    
    
    /// Outlets
    @IBOutlet var vwProgress: [UIView]!
    
    /// Variables
    var arrCells: [SignUpCells] = []
    var data = SignUpData()
    var loginResponse: LoginResponse!
    var screenType : SignScreenSection! {
        didSet {
            arrCells = screenType.arrCells()
        }
    }
    var passVisible: Bool = false
    var confirmPassVisible: Bool = false
    var isEmailEditable: Bool!
    fileprivate var fontSize: CGFloat = 14 * _fontRatio
    var signinSrting: NSAttributedString {
        let normalAttribute = [NSAttributedString.Key.foregroundColor: AppColor.primaryText, NSAttributedString.Key.font: AppFont.fontWithName(.mediumFont, size: fontSize)]
        let termsColorAttributed: [NSAttributedString.Key : Any] = [ NSAttributedString.Key.foregroundColor: AppColor.themePrimary,  NSAttributedString.Key.attachment : "signin", NSAttributedString.Key.font: AppFont.fontWithName(.bold, size: 14 * _fontRatio)]
        
        let para = NSMutableParagraphStyle()
        para.alignment = .center
        
        let mutableStr = NSMutableAttributedString(attributedString: NSAttributedString.attributedText(texts: ["Already have an Account? ","Sign In"], attributes: [normalAttribute, termsColorAttributed]))
        let range = NSMakeRange(0, mutableStr.string.count)
        mutableStr.addAttribute(NSAttributedString.Key.paragraphStyle, value: para, range: range)
        
        return mutableStr
    }
    
    var termPolicy: NSMutableAttributedString {
        let normalAttribute: [NSAttributedString.Key : Any] = [NSAttributedString.Key.foregroundColor: AppColor.primaryTextDark, NSAttributedString.Key.font: AppFont.fontWithName(.mediumFont, size: fontSize)]
        let termsTag: [NSAttributedString.Key : Any] = [ NSAttributedString.Key.foregroundColor: AppColor.themePrimary,  NSAttributedString.Key.attachment : "terms", NSAttributedString.Key.font: AppFont.fontWithName(.bold, size: fontSize)]
        let privacyTag: [NSAttributedString.Key : Any] = [ NSAttributedString.Key.foregroundColor: AppColor.themePrimary,  NSAttributedString.Key.attachment : "privacy", NSAttributedString.Key.font: AppFont.fontWithName(.bold, size: fontSize)]
        
        let para = NSMutableParagraphStyle()
        para.alignment = .left
        let mutableStr = NSMutableAttributedString(attributedString: NSAttributedString.attributedText(texts: ["I agree ", "Terms & Conditions", " and ", "Privacy Policy"], attributes: [normalAttribute, termsTag, normalAttribute, privacyTag]))
        let range = NSMakeRange(0, mutableStr.string.count)
        mutableStr.addAttribute(NSAttributedString.Key.paragraphStyle, value: para, range: range)
        return mutableStr
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        isEmailEditable = self.data.login_with == nil || self.data.email.isEmpty
        prepareU()
        addKeyboardObserver()
    }
    
    func isEditable(_ cellType: SignUpCells) -> Bool {
        if cellType == .email {
            return isEmailEditable
        }
        return true
    }
}


//MARK: - UI Methods
extension SignUpVC {
    
    func prepareU() {
        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 10, right: 0)
        tableView.reloadData()
        if screenType == nil {
            screenType = .profile
        }
        if data.login_with != nil {
            self.arrCells.remove(.pass)
            self.arrCells.remove(.conPass)
        }
        updateProgressView()
        registerCells()
    }
    
    func registerCells() {
        TitleTVC.prepareToRegisterCells(tableView)
        InputCell.prepareToRegisterCells(tableView)
        AddEmergencyContactCell.prepareToRegisterCells(tableView)
        ButtonTableCell.prepareToRegisterCells(tableView)
        
        if screenType == .emergency {
            self.setHeaderView()
        }
    }
    func setHeaderView() {
        // 2. Dequeue an instance of your cell
               guard let headerCell = tableView.dequeueReusableCell(withIdentifier: "emergencyInfoCell") as? UITableViewCell else {
                   fatalError("Could not dequeue MyTableHeaderCell")
               }
        tableView.tableHeaderView = headerCell.contentView
        // Set the frame, only the height matters for tableHeaderView
        headerCell.contentView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 130 * _widthRatio)

                // Very important: Tell the header view to lay out its subviews
                headerCell.contentView.layoutIfNeeded()
    }
    func updateProgressView() {
        vwProgress.forEach { view in
            view.backgroundColor = view.tag < screenType.rawValue ? AppColor.themeGreen : AppColor.placeholderText
        }
    }
}

//MARK: - Button Actions
extension SignUpVC {
    
    @IBAction func back_action(_ sender: UIButton!) {
        if screenType == .profile {
            self.navigationController?.popViewController(animated: true)
        } else {
            _appDelegator.prepareForLogout(block: { succ, json in
                    nprint(items: "Logout")
            })
        }
    }
    
    func openGenderPicker(_ sender: AnyObject) {
        self.view.endEditing(true)
        let alert = UIAlertController.init(title: "Select gender", message: nil, preferredStyle: .actionSheet)
        
        arrGenders.forEach { gender in
            let action = UIAlertAction(title: gender.title, style: .default) { [weak self] (action) in
                guard let self = self else { return }
                self.data.gender = gender
                self.tableView.reloadData()
            }
            alert.addAction(action)
        }
        let cancel = UIAlertAction(title: "Close", style: .cancel, handler: nil)
        alert.addAction(cancel)
        if let popoverController = alert.popoverPresentationController {
            popoverController.sourceView = sender as? UIView
            popoverController.sourceRect = (sender as? UIView)!.bounds
        }
        if _appTheme != .system {
            alert.overrideUserInterfaceStyle = appTheme
        }
        self.present(alert, animated: true, completion: nil)
    }
    func openLocationPickerFor(_ tag: Int) {
        let vc = SearchVC.instantiate(from: .Home)
        vc.selectionBlock = { [weak self] (address) in
            guard let self = self else { return }
            self.data.homeAddress = address
            self.tableView.reloadData()
        }
        self.present(vc, animated: true)
    }
    func continueTap() {
        if screenType == .profile || screenType == .personal {
            let valid = data.isValidData(screenType)
            if valid.0 {
                if screenType == .profile {
                    signUpProfileApi()
                } else if screenType == .personal {
                   
                    signUpPersonalInfoApi()
                }
            } else {
                _ = ValidationToast.showStatusMessage(message: valid.1)
            }
        }
        else if screenType == .emergency {
            var valid: Bool = true
            var msg: String = ""
            for contact in data.arrEmergencyContacts {
                let contactValid = contact.isValid()
                if !contactValid.0 {
                    valid = false
                    msg = contactValid.1
                    break
                }
            }
            if valid {
                self.updateEmergencyContacts()
            } else {
                ValidationToast.showStatusMessage(message: msg)
            }
        }
    }
    
}

//MARK: - TableView Methods
extension SignUpVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrCells.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellType = arrCells[indexPath.row]
        if cellType == .title {
            return TitleTVC.height(for: screenType.title, width: _screenSize.width - (32 * _widthRatio), font: AppFont.fontWithName(.bold, size: 20 * _fontRatio)) + 12
        }
        return arrCells[indexPath.row].cellHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if screenType == .emergency {
            // Dequeue as if it's a cell
            guard let headerCell = tableView.dequeueReusableCell(withIdentifier: "emergencyInfoCell") as? UITableViewCell else {
                return nil
            }

            // Configure cell content based on section
    //        headerCell.titleLabel.text = "Section \(section + 1) Header"
            // ... configure other properties

            // Important: Set the frame of the cell's contentView.
            // This is crucial for Auto Layout and sizing.
            // You might need to calculate the height based on content.
            let headerWidth = tableView.bounds.width
            let desiredHeaderHeight: CGFloat = 130 * _widthRatio // Your desired section header height
            headerCell.contentView.frame = CGRect(x: 0, y: 0, width: headerWidth, height: desiredHeaderHeight)
            headerCell.contentView.layoutIfNeeded() // Force layout for Auto Layout subviews

            return headerCell.contentView // Return the cell's content view
        }
        return nil
        
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
            // Return the height you set in viewForHeaderInSection.
            // If dynamic, calculate it here or use UITableView.automaticDimension
            // along with proper Auto Layout constraints in your cell.
        if screenType == .emergency {
            return 130 * _widthRatio // Or your calculated height
        }else{
            return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellType = arrCells[indexPath.row]
        if cellType == .checkOne  || cellType == .alreadyAccount {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellType.cellId, for: indexPath) as! SignUpCell
            var atString: NSAttributedString {
                return cellType == .alreadyAccount ? signinSrting :  termPolicy
            }
            cell.action_check = { [weak self] () in
                guard let `self` = self else { return }
                cell.btnCheck.isSelected = !cell.btnCheck.isSelected
                if cellType == .checkOne {
                    self.data.isCheckOneSelected = cell.btnCheck.isSelected
                }
            }
            cell.lblTitle.setTagText(attriText: atString, linebreak: .byTruncatingTail)
            cell.lblTitle.delegate = self
            if cellType == .checkOne {
                applyRoundedBackground(to: cell, at: indexPath, in: self.tableView, isBottomRadius:true )
            }
            return cell
        }else if cellType == .role || cellType == .gender {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellType.cellId, for: indexPath) as! SignUpSelectionCell
            if cellType == .role {
                cell.btnCheckTap(self.data.role == .driver ? cell.btnS1 : cell.btnS2)
            }
            cell.prepareUI(type: cellType)
            cell.action_selection = { [weak self] (tag) in
                guard let `self` = self else { return }
                if cellType == .role {
                    self.data.role = tag == 0 ? .driver : .rider
                }else{
                    self.data.gender = arrGenders[tag]
                }
            }
            applyRoundedBackground(to: cell, at: indexPath, in: self.tableView )
            return cell
        } else {
            return tableView.dequeueReusableCell(withIdentifier: arrCells[indexPath.row].cellId, for: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let _ = arrCells[indexPath.row]
        if let cell = cell as? TitleTVC {
            cell.prepareUI(screenType.title, AppFont.fontWithName(.bold, size: 20 * _fontRatio), clr: AppColor.primaryText)
        }
        if let cell = cell as? InputCell {
            cell.tag = indexPath.row
            cell.delegate = self
            applyRoundedBackground(to: cell, at: indexPath, in: self.tableView)
        }
        else if let cell = cell as? AddEmergencyContactCell {
            cell.tag = indexPath.row - 2
            cell.delegate = self
            cell.buttonRemove.isHidden = data.arrEmergencyContacts.count == 1
            cell.btnRemoveCallBack = { [weak self] (indx) in
                guard let `self` = self else { return }
                if self.data.arrEmergencyContacts.count == 1 {
                    ValidationToast.showStatusMessage(message: "Atleast one emergency contact needs to be there")
                } else {
                    showConfirmationPopUpView("Confirmation!", "Are you sure you want to remove this contact?", btns: [.cancel, .yes]) { btn in
                        if btn == .yes {
                            self.data.arrEmergencyContacts.remove(at: indx)
                            self.arrCells.remove(at: 2)
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        }
        else if let cell = cell as? CenterButtonTableCell {
            cell.btn.setAttributedText(texts: ["Add more contact"], attributes: [[NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue]], state: .normal)
            cell.btn.setImage(UIImage(named: "add_emergency_contact")!.withTintColor(AppColor.primaryText), for: .normal)
            cell.btn.layoutIfNeeded()
            cell.btnTapAction = { [weak self] in
                guard let `self` = self else { return }
                if self.data.arrEmergencyContacts.count < 3 {
                    self.data.arrEmergencyContacts.append(EmergencyContactData())
                    if let index = self.arrCells.lastIndex(of: .eContact) {
                        self.arrCells.insert(.eContact, at: index + 1)
                    }
                    self.tableView.reloadData()
                } else {
                    ValidationToast.showStatusMessage(message: "You can add upto max 3 contacts", yCord: _navigationHeight)
                }
            }
        }
        else if let cell = cell as? ButtonTableCell {
            cell.btn.setTitle("Continue", for: .normal)
            cell.btnTapAction = { [weak self] (_) in
                guard let `self` = self else { return }
                self.continueTap()
            }
        }
    }
}

// MARK: - UIKeyboard Observer
extension SignUpVC {
    
    func addKeyboardObserver() {
        _defaultCenter.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        _defaultCenter.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: NSNotification){
        if let userInfo = notification.userInfo {
            if let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                guard let _ = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {return}
                tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height + 10, right: 0)
            }
        }
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification){
        guard let _ = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {return}
        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
    }
}

// MARK: - API Call
extension SignUpVC {
    
    func signUpProfileApi() {
        showCentralSpinner()
        let param = data.getParamDict(screenType)
        WebCall.call.signupUser(param: param.merged(with: Setting.deviceInfo)) { [weak self] (json, status) in
            guard let `self` = self else { return }
            self.hideCentralSpinner()
            if status == 200, let dict = json as? NSDictionary, let data = dict["data"] as? NSDictionary {
                let token = data.getStringValue(key: "token")
                _appDelegator.storeAuthorizationToken(token)
                _appDelegator.saveContext()
                
                _user = User.addUpdateEntity(key: "id", value: data.getStringValue(key: "id"))
                _user?.initWith(data)
                _user?.pushNotify = data.getBooleanValue(key: "push_notify")
                _user?.textNotify = data.getBooleanValue(key: "text_notification")
                _user?.emailVerify = data.getBooleanValue(key: "email_verify")
                _user?.mobileVerify = data.getBooleanValue(key: "mobile_verify")
                
                _userDefault.set(data.getBooleanValue(key: "mobile_verify"), forKey: "mobileVerify")
                _userDefault.set(data.getBooleanValue(key: "email_verify"), forKey: "emailVerify")
                _userDefault.set(data.getBooleanValue(key: "is_personal_information"), forKey: "personalInfoAdded")
                _userDefault.set(data.getBooleanValue(key: "is_emergency_contacts"), forKey: "emergencyInfoAdded")
                _userDefault.synchronize()
                
                _appDelegator.saveContext()
                
                let vc = SignUpVC.instantiate(from: .Auth)
                vc.screenType = .personal
                vc.loginResponse = LoginResponse(data)
                self.navigationController?.pushViewController(vc, animated: true)
                
                
            } else {
                self.showError(data: json, yCord: _statusBarHeight)
            }
        }
    }
    
    func signUpPersonalInfoApi() {
        showCentralSpinner()
        let param = data.getParamDict(screenType)
        WebCall.call.updateUserProfile(param: param) { [weak self] (json, status) in
            guard let `self` = self else { return }
            self.hideCentralSpinner()
            if status == 200{
                _userDefault.set(true, forKey: "personalInfoAdded")
                _userDefault.synchronize()
                
                let vc = VerifyOtpVC.instantiate(from: .Auth)
                vc.screenType = .registerMobile
                self.navigationController?.pushViewController(vc, animated: true)
//                let vc = SignUpVC.instantiate(from: .Auth)
//                vc.screenType = .emergency
//                vc.loginResponse = self.loginResponse
//                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                self.showError(data: json, yCord: _statusBarHeight)
            }
        }
    }
    
    func updateEmergencyContacts() {
        var param: [String: Any] = [:]
        param["type"] = "emergency_contact"
        param["contacts"] = data.arrEmergencyContacts.compactMap({$0.param})
        
        showCentralSpinner()
        WebCall.call.updateUserProfile(param: param) { [weak self] (json, status) in
            guard let self = self else { return }
            self.hideCentralSpinner()
            if status == 200{
                self.showSuccessMsg(data: json, yCord: _statusBarHeight)
                _userDefault.set(true, forKey: "emergencyInfoAdded")
                _userDefault.synchronize()
                
                let vc = CmsVC.instantiate(from: .CMS)
                vc.screenType = .tnc
                vc.isFromSignUp = true
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                self.showError(data: json)
            }
        }
    }
}
// MARK: - KPLinkLabelDelagete
extension SignUpVC: NLinkLabelDelagete {
    
    func tapOnEmpty(index: IndexPath?) {}
    
    func tapOnTag(tagName: String, type: ActiveType, tappableLabel: NLinkLabel) {
        nprint(items: tagName)
        if tagName == "signin" {
            self.navigationController?.popToRootViewController(animated: true)
        }
        else if tagName == "terms" {
            let vc = CmsVC.instantiate(from: .CMS)
            vc.screenType = .tnc
//            vc.isFromSignUp = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if tagName == "privacy" {
            let vc = CmsVC.instantiate(from: .CMS)
            vc.screenType = .privacy
//            vc.isFromSignUp = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
