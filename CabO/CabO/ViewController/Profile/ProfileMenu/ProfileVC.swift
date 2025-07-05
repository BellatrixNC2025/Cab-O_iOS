//
//  ProfileVC.swift
//  CabO
//
//  Created by Octos.
//

import UIKit
import Photos
import LocalAuthentication

//MARK: - ProfileMenuCell
class ProfileMenuCell: ConstrainedTableViewCell {
    
    /// Outlets
    @IBOutlet weak var imgLeft: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgRight: UIImageView!
    @IBOutlet weak var swtch: UISwitch!
    
    /// Variables
    var toggleSwitch: ((Bool) -> ())?
    
    weak var parent: ProfileVC!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imgLeft?.setViewHeight(height: (DeviceType.iPad ? 26 : 20) * _widthRatio)
        swtch?.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func prepareUI(_ cellType: ProfileSettingsCells) {
        imgLeft?.image = cellType.leftImg
        lblTitle?.text = cellType.title
        swtch?.isHidden = !cellType.isSwitch
        imgRight?.isHidden = cellType.isSwitch
        
        if cellType == .pushNotification {
            swtch.isOn = _user?.pushNotify ?? true
        } else if cellType == .textNotification {
            swtch.isOn = _user?.textNotify ?? true
        }
        
        self.layoutIfNeeded()
    }
        
    @IBAction func toggleSwitch(_ sender: UISwitch) {
        toggleSwitch?(sender.isOn)
    }
    
}

//MARK: - Profile VC
class ProfileVC: ParentVC {
    
    /// Outlets
    @IBOutlet weak var btnDeleteAcc: UIButton!
    
    /// Variables
    var arrCells : [ProfileSettingsCells] = ProfileSettingsCells.allCases
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        viewNavigation?.setViewHeight(height: (DeviceType.iPad ? 74 : 60) * _widthRatio)
        prepareUI()
        addObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}

//MARK: - UI Methoods
extension ProfileVC {

    
    func prepareUI() {
        
        btnDeleteAcc.setAttributedText(texts: ["Delete account"], attributes: [[NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue]], state: .normal)
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 50, right: 0)
        registerCells()
    }
    
    func registerCells() {
        TitleTVC.prepareToRegisterCells(tableView)
    }
}

//MARK: - Button Actions
extension ProfileVC {
    
    @IBAction func btnChangeProfilePic(_ sender: UIButton) {
        let vc = AddProfilePicVC.instantiate(from: .Profile)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func confirmLogout() {
        showConfirmationPopUpView("Confirmation!", "Are you sure you want to logout?", btns: [.no, .yes]) { btnType in
            if btnType == .yes {
                self.logOutUser()
            }
        }
    }
    @IBAction func btnDeletTap(_ sender: UIButton) {
        confirmDeleteAccount()
    }
    func confirmDeleteAccount() {
        if !_user!.allowDelete {
            ValidationToast.showStatusMessage(message: "We are unable to delete your account because one of your rides is currently ongoing.")
        } else {
            showConfirmationPopUpView("Confirmation!", "Are you sure you want to delete account?", btns: [.no, .yes]) { btnType in
                nprint(items: btnType.title)
                if btnType == .yes {
                    self.authenticate_user { (succ) in
                        if succ {
                            DispatchQueue.main.async {
                                let vc = DeleteAccountVC.instantiate(from: .Profile)
//                                self.navigationController?.pushViewController(vc, animated: true)
                                vc.modalPresentationStyle = .overCurrentContext
                                self.present(vc, animated: true, completion: nil)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func updateAppTheme(_ theme: AppThemeType) {
        _appTheme = theme
        _userDefault.set(theme.rawValue, forKey: _CabOAppTheme)
        _userDefault.synchronize()
        
        UIView.animate(withDuration: 0.25) {
            if _appTheme != .system {
                self.overrideUserInterfaceStyle = appTheme
            } else {
                self.overrideUserInterfaceStyle = .unspecified
            }
        }
        
        NotificationCenter.default.post(name: Notification.Name.themeUpdateNotification, object: nil)
    }
    
    func toggleSwitchActions(_ cellType: ProfileSettingsCells,_ isOn: Bool) {
        if cellType == .pushNotification || cellType == .textNotification {
            updateNotificationSwitch(cellType, isOn: isOn)
        }
    }
    
    func authenticate_user(completion: @escaping ((Bool) -> ())){
        let authenticationContext = LAContext()
        var error:NSError?
        let isValidSensor : Bool = authenticationContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        if isValidSensor {
            authenticationContext.evaluatePolicy(
                .deviceOwnerAuthentication,
                localizedReason: "Touch / Face ID authentication",
                reply: { (success, error) -> Void in
                    if(success) {
                        completion(true)
                    } else {
                        if let error = error {
                            ValidationToast.showStatusMessage(message: error.localizedDescription)
                        }else{
                            completion(false)
                        }
                    }
            })
        } else {
            ValidationToast.showStatusMessage(message: error?.localizedDescription ?? "Something went wrong")
        }
    }
}

//MARK: - TableView Methods
extension ProfileVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrCells.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellType = arrCells[indexPath.row]
        
        return 50 * _widthRatio
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellType = arrCells[indexPath.row]
       
            let cell = tableView.dequeueReusableCell(withIdentifier: cellType.celld, for: indexPath) as! ProfileMenuCell
            cell.parent = self
            cell.prepareUI(cellType)
            
            cell.toggleSwitch = { [weak self] (isOn) in
                guard let `self` = self else { return }
                self.toggleSwitchActions(cellType, isOn)
            }
        applyRoundedBackground(to: cell, at: indexPath, in: tableView)
            return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellType = arrCells[indexPath.row]
        
        switch cellType {
        case .profileImage :
            let vc = AddProfilePicVC.instantiate(from: .Profile)
            self.navigationController?.pushViewController(vc, animated: true)
        case .profileInfo, .emergencyContact :
            let vc = EditProfileVC.instantiate(from: .Profile)
            vc.editType = EditProfileScreenType(cellType)!
            self.navigationController?.pushViewController(vc, animated: true)
            
        case .changePass:
            let vc = ChangePasswordVC.instantiate(from: .Profile)
            self.navigationController?.pushViewController(vc, animated: true)
//        case .faq:
//            let vc = FaqVC.instantiate(from: .CMS)
//            self.navigationController?.pushViewController(vc, animated: true)
            
        case .aboutUS, .tnc, .privacyPolicy, .cancellationPolicy, .faq:
            let vc = CmsVC.instantiate(from: .CMS)
            vc.screenType = CmsScreenType(cellType)!
            self.navigationController?.pushViewController(vc, animated: true)

        default:
            break
        }
    }
}

//MARK: - Notification Observers
extension ProfileVC {
    
    func addObservers() {
        _defaultCenter.addObserver(self, selector: #selector(userProfileEdited(_:)), name: Notification.Name.userProfileUpdate, object: nil)
    }
    
    @objc func userProfileEdited(_ notification: NSNotification){
//        _appDelegator.getUserProfile { [weak self] (succ, json) in
//            guard let weakSelf = self else { return }
//            if succ {
//                weakSelf.labelUserName?.text = _user?.fullName
//                weakSelf.imgVerifyBadgeRight.isHidden = !(_user?.userVerify ?? false)
//                if let profileImg = _user?.profilePic, !profileImg.isEmpty {
//                    weakSelf.imgUserProfile.loadFromUrlString(profileImg, placeholder: _userPlaceImage)
//                } else {
//                    weakSelf.imgUserProfile.image = _userPlaceImage
//                }
//            }
//        }
    }
    
}

// MARK: - API Calls
extension ProfileVC {
    
    func logOutUser() {
        self.showCentralSpinner()
        _appDelegator.prepareForLogout { [weak self] (success, json) in
            guard let weakSelf = self else { return }
            weakSelf.hideCentralSpinner()
        }
    }
    
    func updateNotificationSwitch(_ cellType: ProfileSettingsCells, isOn: Bool) {
        var param: [String: Any] = [:]
        param["type"] = cellType == .pushNotification ? "push_notify" : "text_notify"
        param["is_notify"] = isOn ? "Yes" : "No"
        
        showCentralSpinner()
        WebCall.call.updateNotitificationPref(param: param) { [weak self] (json, status) in
            guard let `weakself` = self else { return }
            weakself.hideCentralSpinner()
            if status == 200 {
                if cellType == .pushNotification {
                    _user!.pushNotify = isOn
                    weakself.tableView.reloadRows(at: [IndexPath(row: weakself.arrCells.firstIndex(of: .pushNotification) ?? 0, section: 0)], with: .none)

                } else {
                    _user!.textNotify = isOn
                    weakself.tableView.reloadRows(at: [IndexPath(row: weakself.arrCells.firstIndex(of: .textNotification) ?? 0, section: 0)], with: .none)
                }
                _appDelegator.saveContext()
            } else {
                weakself.showError(data: json)
            }
        }
    }
}
