//
//  EditProfileVC.swift
//  CabO
//
//  Created by Octos.
//

import UIKit

// MARK: - EditProfileVC
class EditProfileVC: ParentVC {
    
    /// Variables
    var editType: EditProfileScreenType!
    var arrCells: [EditProfileCellType] = []
    var data = EditProfileData()
    
    var arrEmergencyContacts: [EmergencyContactData] = [EmergencyContactData()]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        addObservers()
        
        if editType == .profile {
            getPersonalInfo()
        } else if editType == .emergency {
            getEmergencyContacts()
        }
    }
}

//MARK: - UI Methods
extension EditProfileVC {
    
    func prepareUI() {
        
        if editType == .profile {
            arrCells = [.fname, .lname, .mobile, .email,.dob, .gender, .bio, .btn]
        }
//        else if editType == .personal {
//            arrCells = [, .fb, .twit, .insta, .btn]
//        }
        else {
            arrCells = [.eInfo, .eContact, .addMore, .btn]
        }
        tableView.reloadData()
        
        lblTitle?.text = editType.title
        
        registerCells()
    }
    
    func registerCells() {
        InputCell.prepareToRegisterCells(tableView)
        AddEmergencyContactCell.prepareToRegisterCells(tableView)
        ButtonTableCell.prepareToRegisterCells(tableView)
    }
    
    func openEditPopUp(_ isEmail: Bool) {
        let editPopup = InputPopView.initWith(
                                        title: "Edit",
                                        subTitle: "",
                                        tfTitle: isEmail ? "Email address" : "Mobile Number",
                                        tfPlace: isEmail ? "Enter email address" : "Enter Mobile Number",
                                        imgLeft: isEmail ? UIImage(named: "ic_mail")! : UIImage(named: "ic_mobile")!,
                                        keyboardType: isEmail ? .emailAddress : .phonePad,
                                        maxLength : isEmail ? 32 : 10,
                                        isEmail: isEmail,
                                        showInfo: (_user!.isSocialUser && isEmail))
        editPopup.btnSubmitTap = { [weak self] (str) in
            guard let `self` = self else { return }
            self.updateMobileEmail(str, isEmail)
        }
    }
}

// MARK: - Button Actins
extension EditProfileVC {
    
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
    
    func btnContinueTap() {
        if editType == .profile {
            let valid = data.isValidData(editType)
            if valid.0 {
                if editType == .profile {
                    self.editUserProfileInfo()
                } else {
                    self.updatePersonalInfoApi()
                }
            } else {
                ValidationToast.showStatusMessage(message: valid.1, yCord: _navigationHeight)
            }
        } else if editType == .emergency {
            var valid: Bool = true
            var msg: String = ""
            for contact in arrEmergencyContacts {
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
                ValidationToast.showStatusMessage(message: msg, yCord: _navigationHeight)
            }
        }
    }
}

//MARK: - TableView Methods
extension EditProfileVC : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrCells.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return arrCells[indexPath.row].cellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: arrCells[indexPath.row].identifier, for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? InputCell {
            cell.tag = indexPath.row
            cell.delegate = self
        }
        else if let cell = cell as? AddEmergencyContactCell {
            cell.tag = indexPath.row - 1
            cell.delegate = self
            
            cell.btnRemoveCallBack = { [weak self] (indx) in
                guard let `self` = self else { return }
                if self.arrEmergencyContacts.count == 1 {
                    ValidationToast.showStatusMessage(message: "Atleast one emergency contact needs to be there")
                } else {
                    showConfirmationPopUpView("Confirmation!", "Are you sure to remove this contact?", btns: [.cancel, .yes]) { btn in
                        if btn == .yes {
                            self.arrEmergencyContacts.remove(at: indx)
                            self.arrCells.remove(at: 1)
                            self.tableView.reloadData()
                        }
                    }
                }
            }
        }
        else if let cell = cell as? CenterButtonTableCell {
            cell.btn.setAttributedText(texts: ["Add more contact"], attributes: [[NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue]], state: .normal)
            var img = UIImage(named: "add_emergency_contact")!.withTintColor(AppColor.primaryText)
            img = img.scaleImage(toSize: img.size * _widthRatio)!
            cell.btn.setImage(img, for: .normal)
            
            cell.btn.layoutIfNeeded()
            cell.btnTapAction = { [weak self] in
                guard let `self` = self else { return }
                if self.arrEmergencyContacts.count < 3 {
                    self.arrEmergencyContacts.append(EmergencyContactData())
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
            cell.btn.setTitle("Update", for: .normal)
            cell.prepareStateUI(enable: true)
            cell.btnTapAction = {[weak self] (_) in
                guard let weakSelf = self else { return }
                weakSelf.btnContinueTap()
            }
        }
    }
}


//MARK: - Notification Observers
extension EditProfileVC {
    
    func addObservers() {
        _defaultCenter.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        _defaultCenter.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        _defaultCenter.addObserver(self, selector: #selector(userProfileEdited(_:)), name: Notification.Name.userProfileUpdate, object: nil)
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
        tableView.contentInset = UIEdgeInsets.zero
    }
    
    @objc func userProfileEdited(_ notification: NSNotification){
        _appDelegator.getUserProfile { [weak self] (succ, json) in
            guard let weakSelf = self else { return }
            if succ {
                DispatchQueue.main.async {
                    weakSelf.data.mobile = _user!.mobileNumber
                    weakSelf.data.email = _user!.emailAddress
                    weakSelf.tableView.reloadData()
                }
            }
        }
    }
    
}

// MARK: - API Call
extension EditProfileVC {
    
    func getEmergencyContacts() {
        showCentralSpinner()
        WebCall.call.getUserProfile { [weak self] (json, status) in
            guard let `self` = self else { return }
            self.hideCentralSpinner()
            self.arrCells = [.eInfo, .addMore, .btn]
            self.arrEmergencyContacts = []
            
            if status == 200, let dict = json as? NSDictionary, let dData = dict["data"] as? NSDictionary, let data = dData["emergency_contacts"] as? [NSDictionary] {
                if !data.isEmpty {
                    data.forEach { contactDict in
                        let contact = EmergencyContactData(contactDict)
                        self.arrEmergencyContacts.append(contact)
                        self.arrCells.insert(.eContact, at: 1)
                    }
                } else {
                    self.arrEmergencyContacts.append(EmergencyContactData())
                    self.arrCells.insert(.eContact, at: 1)
                }
                self.tableView.reloadData()
            } else {
                self.arrEmergencyContacts.append(EmergencyContactData())
                self.arrCells.insert(.eContact, at: 1)
                self.tableView.reloadData()
//                showError(data: json)
            }
        }
    }
    
    func getPersonalInfo() {
        showCentralSpinner()
        WebCall.call.getUserProfile { [weak self] (json, status) in
            guard let `self` = self else { return }
            self.hideCentralSpinner()
            if status == 200, let dict = json as? NSDictionary, let dData = dict["data"] as? NSDictionary, let data = dData["personal_information"] as? NSDictionary {
                self.data = EditProfileData(data)
                self.tableView.reloadData()
            } else {
                self.tableView.reloadData()
//                showError(data: json)
            }
        }
    }
    
    func editUserProfileInfo() {
        if data.isDataChanged {
            let cell = tableViewCell(index: arrCells.firstIndex(of: .btn)!) as! ButtonTableCell
            self.showSpinnerIn(container: cell.bgView, control: cell.btn, isCenter: true)
            
            WebCall.call.updateUserProfile(param: data.editProfileInfoParam) { [weak self] (json, status) in
                guard let self = self else { return }
                self.hideSpinnerIn(container: cell.bgView, control: cell.btn)
                if status == 200{ //}, let dict = json as? NSDictionary, let data = dict["data"] as? NSDictionary  {
                    self.showSuccessMsg(data: json, yCord: _statusBarHeight)
                    _defaultCenter.post(name: Notification.Name.userProfileUpdate, object: nil)
                    self.navigationController?.popViewController(animated: true)
                } else {
                    self.showError(data: json)
                }
            }
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func updateMobileEmail(_ str: String, _ isEmail: Bool) {
        showCentralSpinner()
        var param: [String: Any] = [:]
        param["sourcefrom"] = "profile"
        param["source"] = isEmail ? "email" : "mobile"
        param["sourceid"] = isEmail ? str : str.removeSpace()
        WebCall.call.updateEmailMobile(param: param) { [weak self] (json, status) in
            guard let `self` = self else { return }
            self.hideCentralSpinner()
            if status == 200 {
                if !isEmail {
                    let vc = VerifyOtpVC.instantiate(from: .Auth)
                    vc.screenType = .updateMobile
                    vc.emailMobile = str
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                else {
                    if !_appDelegator.config.isEmailOn {
                        ValidationToast.showStatusMessage(message: "Please try again later")
                    } else {
                        let vc = VerifyOtpVC.instantiate(from: .Auth)
                        vc.screenType = .updateEmail
                        vc.emailMobile = str
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            } else {
                self.showError(data: json)
            }
        }
    }
    
    func updatePersonalInfoApi() {
        showCentralSpinner()
        WebCall.call.updateUserProfile(param: data.personalInfoParam) { [weak self] (json, status) in
            guard let `self` = self else { return }
            self.hideCentralSpinner()
            if status == 200{
                self.showSuccessMsg(data: json)
                self.navigationController?.popViewController(animated: true)
            } else {
                self.showError(data: json)
            }
        }
    }
    
    func updateEmergencyContacts() {
        var param: [String: Any] = [:]
        param["type"] = "emergency_contact"
        param["contacts"] = arrEmergencyContacts.compactMap({$0.param})
        
        showCentralSpinner()
        WebCall.call.updateUserProfile(param: param) { [weak self] (json, status) in
            guard let self = self else { return }
            self.hideCentralSpinner()
            if status == 200{//}, let dict = json as? NSDictionary, let data = dict["data"] as? NSDictionary  {
                self.showSuccessMsg(data: json)
                self.navigationController?.popViewController(animated: true)
            } else {
                self.showError(data: json)
            }
        }
    }
}
