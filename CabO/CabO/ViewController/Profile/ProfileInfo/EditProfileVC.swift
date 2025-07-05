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
            if _user!.role == .rider {
                arrCells = [.fname, .lname, .mobile, .mobileVerified, .email, .emailVerified,.dob, .gender, .bio, .btn]
            }else{
                arrCells = [.fname, .lname, .mobile, .mobileVerified, .email,.emailVerified,.dob, .gender,.homeAddress, .bio, .btn]
            }
        }
//        else if editType == .personal {
//            arrCells = [, .fb, .twit, .insta, .btn]
//        }
        else if editType == .emergency {
            arrCells = [.eContact, .addMore, .btn]
            self.setHeaderView()
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
    func setHeaderView() {
        // Dequeue an instance of your cell
      guard let headerCell = tableView.dequeueReusableCell(withIdentifier: "emergencyInfoCell") as? UITableViewCell else {
                   fatalError("Could not dequeue MyTableHeaderCell")
               }
        tableView.tableHeaderView = headerCell.contentView
        // Set the frame, only the height matters for tableHeaderView
        headerCell.contentView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 130 * _widthRatio)

                // Very important: Tell the header view to lay out its subviews
                headerCell.contentView.layoutIfNeeded()
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
    func openLocationPickerFor(_ tag: Int) {
        let vc = SearchVC.instantiate(from: .Home)
        vc.selectionBlock = { [weak self] (address) in
            guard let self = self else { return }
            self.data.homeAddress = address
            self.tableView.reloadData()
        }
        self.present(vc, animated: true)
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
        let cellType = arrCells[indexPath.row]
        if cellType == .mobileVerified || cellType == .emailVerified {
            return UITableView.automaticDimension
        }
        return arrCells[indexPath.row].cellHeight
    }
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        if editType == .emergency {
//            // Dequeue as if it's a cell
//            guard let headerCell = tableView.dequeueReusableCell(withIdentifier: "emergencyInfoCell") else {
//                return nil
//            }
//
//            // Configure cell content based on section
//    //        headerCell.titleLabel.text = "Section \(section + 1) Header"
//            // ... configure other properties
//
//            // Important: Set the frame of the cell's contentView.
//            // This is crucial for Auto Layout and sizing.
//            // You might need to calculate the height based on content.
//            let headerWidth = tableView.bounds.width
//            let desiredHeaderHeight: CGFloat = 130 * _widthRatio // Your desired section header height
//            headerCell.contentView.frame = CGRect(x: 0, y: 0, width: headerWidth, height: desiredHeaderHeight)
//            headerCell.contentView.layoutIfNeeded() // Force layout for Auto Layout subviews
//
//            return headerCell.contentView // Return the cell's content view
//        }
//        return nil
//        
//    }
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//            // Return the height you set in viewForHeaderInSection.
//            // If dynamic, calculate it here or use UITableView.automaticDimension
//            // along with proper Auto Layout constraints in your cell.
//        if editType == .emergency {
//            return 130 * _widthRatio // Or your calculated height
//        }else{
//            return 0
//        }
//    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellType = arrCells[indexPath.row]
        if cellType == .emailVerified || cellType == .mobileVerified {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "dataVerifiedCell", for: indexPath) as! DataVerifiedCell
            cell.prepareUI(cellType)
            cell.btnChangeTap = {
                if cellType == .emailVerified && _user?.emailVerify == false{
                    let vc = VerifyOtpVC.instantiate(from: .Auth)
                    vc.screenType = .updateMobile
                    vc.emailMobile = _user?.emailAddress
                    self.navigationController?.pushViewController(vc, animated: true)
                }else if cellType == .mobileVerified && _user?.mobileVerify == false{
                    let vc = VerifyOtpVC.instantiate(from: .Auth)
                    vc.screenType = .updateMobile
                    vc.emailMobile = _user?.mobileNumber
                    self.navigationController?.pushViewController(vc, animated: true)
                }else{
                    self.openEditPopUp(cellType == .emailVerified ? true : false)
                }
            }
            applyRoundedBackground(to: cell, at: indexPath, in: tableView)
            return cell
        }
        return tableView.dequeueReusableCell(withIdentifier: arrCells[indexPath.row].identifier, for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cellType = arrCells[indexPath.row]
        if let cell = cell as? InputCell {
            cell.tag = indexPath.row
            cell.delegate = self
            applyRoundedBackground(to: cell, at: indexPath, in: tableView, isBottomRadius: cellType == .bio ? true : false)
        }
        else if let cell = cell as? AddEmergencyContactCell {
            cell.tag = indexPath.row 
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
            applyRoundedBackground(to: cell, at: indexPath, in: self.tableView )
        }
        else if let cell = cell as? CenterButtonTableCell {
//            cell.btn.setAttributedText(texts: ["Add More"], attributes: [[NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue],[NSAttributedString.Key.foregroundColor: AppColor.primaryTextDark]], state: .normal)
            var img = UIImage(systemName: "plus.circle.fill")!.withTintColor(AppColor.themeGreen)
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
            applyRoundedBackground(to: cell, at: indexPath, in: self.tableView, isBottomRadius: true)
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
            self.arrCells = [.addMore, .btn]
            self.arrEmergencyContacts = []
            
            if status == 200, let dict = json as? NSDictionary, let dData = dict["data"] as? NSDictionary, let data = dData["emergency_contacts"] as? [NSDictionary] {
                if !data.isEmpty {
                    data.forEach { contactDict in
                        let contact = EmergencyContactData(contactDict)
                        self.arrEmergencyContacts.append(contact)
                        self.arrCells.insert(.eContact, at: 0)
                    }
                } else {
                    self.arrEmergencyContacts.append(EmergencyContactData())
                    self.arrCells.insert(.eContact, at: 0)
                }
                self.tableView.reloadData()
            } else {
                self.arrEmergencyContacts.append(EmergencyContactData())
                self.arrCells.insert(.eContact, at: 0)
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
//        if data.isDataChanged {
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
//        } else {
//            self.navigationController?.popViewController(animated: true)
//        }
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
