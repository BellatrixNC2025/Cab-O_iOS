//
//  LoginVC.swift
//  CabO
//
//  Created by Octos.
//

import UIKit
import GoogleSignIn
import AuthenticationServices

//MARK: - Login VC
class LoginVC: ParentVC {
    
    /// Outlets
    @IBOutlet weak var lblSignUp: NLinkLabel!
    
    /// Variables
    var arrCells: [LoginCells] = LoginCells.allCases
    var data = LoginData()
    var isSecurePass: Bool = true
    
    /// This is attributed string for terms and condition
    var signupSrting: NSAttributedString {
        let normalAttribute = [NSAttributedString.Key.foregroundColor: AppColor.primaryText, NSAttributedString.Key.font: AppFont.fontWithName(.mediumFont, size: 14 * _fontRatio)]
        let termsColorAttributed: [NSAttributedString.Key : Any] = [ NSAttributedString.Key.foregroundColor: AppColor.primaryText,  NSAttributedString.Key.attachment : "signUp", NSAttributedString.Key.font: AppFont.fontWithName(.bold, size: 14 * _fontRatio), NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue]
        
        let para = NSMutableParagraphStyle()
        para.minimumLineHeight = 20
        para.maximumLineHeight = 20
        para.alignment = .center
        
        let mutableStr = NSMutableAttributedString(attributedString: NSAttributedString.attributedText(texts: ["Don't have an Account? ","Sign Up"], attributes: [normalAttribute, termsColorAttributed]))
        let range = NSMakeRange(0, mutableStr.string.count)
        mutableStr.addAttribute(NSAttributedString.Key.paragraphStyle, value: para, range: range)
        
        return mutableStr
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareU()
        addKeyboardObserver()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        for v in self.tableView.constraints {
//            if v.identifier == "id_height"{
//                if let height_constraint = self.tableView.constraints.first(where: {$0.identifier == v.identifier}){
//                    height_constraint.constant = self.tableView.contentSize.height
//                }
//            }
//        }
    }
}

//MARK: - UI Methods
extension LoginVC {
    
    func prepareU() {
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
//        tableView.translatesAutoresizingMaskIntoConstraints = false
//        tableView.contentInsetAdjustmentBehavior = .never
//        tableView.alwaysBounceVertical = true
        
        registerCells()
        lblSignUp.setTagText(attriText: signupSrting, linebreak: .byTruncatingTail)
        lblSignUp.delegate = self
    }
    
    func registerCells() {
        TitleTVC.prepareToRegisterCells(tableView)
        InputCell.prepareToRegisterCells(tableView)
        ButtonTableCell.prepareToRegisterCells(tableView)
    }
}

//MARK: - Button Actions
extension LoginVC {
    
    func loginAction() {
        let valid = data.isValidData()
        if valid.0 {
            loginCall()
        } else {
            _ = ValidationToast.showStatusMessage(message: valid.1)
        }
    }
    
    func openForgotPassVC() {
        let vc = ForgotPasswordVC.instantiate(from: .Auth)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func action_social_signin(_ tag: Int) {
        if tag == 0 {
            self.loginWithGoogle()
        } else if tag == 1 {
            self.loginWithFacebook()
        } else {
            self.loginWithApple()
        }
    }
    
    // MARK: - Google Login
    func loginWithGoogle() {
        self.view.endEditing(true)
        
        GIDSignIn.sharedInstance.disconnect()
        GIDSignIn.sharedInstance.signOut()
        let signInConfig = GIDConfiguration.init(clientID: Setting.google_signin_key)
        GIDSignIn.sharedInstance.configuration = signInConfig
        GIDSignIn.sharedInstance.signIn(withPresenting: self){ result, error in
            print("\n\n\nGOOGLE : DID SIGN IN ")
            
            if (error == nil) {
                // Perform any operations on signed in user here.
                if let user = result?.user {
                    
                    var param: [String: Any] = [:]
                    param["login_with"] = "Google"
                    param["social_id"] = user.userID
                    param.merge(with: Setting.deviceInfo)
                    
                    let userData: SignUpData = SignUpData()
                    userData.social_id = user.userID
                    userData.login_with = "Google"
                    
                    userData.fName = user.profile!.givenName ?? ""
                    userData.lname = user.profile!.familyName ?? ""
                    userData.email = user.profile!.email
                    
                    self.socialSignInUser(param, signUpModel: userData)
                }

            } else {
                print("GOOGLE ERR : \(error!.localizedDescription)")
                ValidationToast.showStatusMessage(message: error!.localizedDescription)
            }
        }
    }
    
    func loginWithFacebook() {
        
    }
    
    // MARK: - Apple Login
    func loginWithApple() {
//        self.performExistingAccountSetupFlows()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.signInwithApple()
        }
    }
    
    private func performExistingAccountSetupFlows() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = Setting.UDID
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    func signInwithApple(){
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
}

// MARK: - Sign in with Apple Delegates
extension LoginVC : ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding{
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return _appDelegator.window! //self.view.window!
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        
    }
    
    func authorizationController
    (controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            
            print("User Id - \(appleIDCredential.user)")
            print("First Name - \(appleIDCredential.fullName?.givenName ?? "N/A")")
            print("Last Name - \(appleIDCredential.fullName?.familyName ?? "N/A")")
            print("User Email - \(appleIDCredential.email ?? "N/A")")
            print("Real User Status - \(appleIDCredential.realUserStatus.rawValue)")
            
            if let identityTokenData = appleIDCredential.identityToken,
                let identityTokenString = String(data: identityTokenData, encoding: .utf8) {
                print("Identity Token \(identityTokenString)")
            }
            let authorizationCode = String(data: appleIDCredential.authorizationCode!, encoding: .utf8)!
            print("authorizationCode: \(authorizationCode)")
            
            var param: [String: Any] = [:]
            param["login_with"] = "Apple"
            param["social_id"] = appleIDCredential.user
            param["apple_auth_code"] = authorizationCode
            param.merge(with: Setting.deviceInfo)
            
            let userData: SignUpData = SignUpData()
            userData.social_id = appleIDCredential.user
            userData.login_with = "Apple"
            userData.apple_auth_code = authorizationCode
            
            userData.fName = appleIDCredential.fullName?.givenName ?? ""
            userData.lname = appleIDCredential.fullName?.familyName ?? ""
            userData.email = appleIDCredential.email ?? ""
            
            userData.getKeychainData { (userdata) in
                if userdata == nil{
                    debugPrint("save data to keychain")
                    userData.saveDataKeychain()
                }else{
                    debugPrint("already saved to keychain")
                    if !userData.email.isEmpty && !userData.fName.isEmpty && !userData.lname.isEmpty {
                        userData.saveDataKeychain()
                    }else{
                        userData.fName = userdata!.fName
                        userData.lname = userdata!.lname
                        userData.email = userdata!.email
                        userData.social_id = userdata!.social_id
                    }
                }
            }
            
            self.socialSignInUser(param, signUpModel: userData)
            
        } else if let passwordCredential = authorization.credential as? ASPasswordCredential {
            // Sign in using an existing iCloud Keychain credential.
            let username = passwordCredential.user
            let password = passwordCredential.password
            
            nprint(items: [username, password])
        }
    }
    
}

//MARK: - TableView Methods
extension LoginVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrCells.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellType = arrCells[indexPath.row]
        if cellType == .title {
            return TitleTVC.height(for: cellType.inputTitle, width: _screenSize.width - (32 * _widthRatio), font: AppFont.fontWithName(.bold, size: 20 * _fontRatio)) + 16 * _widthRatio
        }
        else if cellType == .social {
            return _appDelegator.config.isSocialLogInOn ? UITableView.automaticDimension : 0
        }
        return arrCells[indexPath.row].cellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: arrCells[indexPath.row].cellId, for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cellType = arrCells[indexPath.row]
        if let cell = cell as? TitleTVC {
            cell.prepareUI(cellType.inputTitle, AppFont.fontWithName(.bold, size: 20 * _fontRatio), clr: AppColor.primaryTextDark)
            applyRoundedBackground(to: cell, at: indexPath, in: self.tableView, isTopRadius: true)

        }
        else if let cell = cell as? InputCell {
            cell.tag = indexPath.row
            cell.delegate = self
            applyRoundedBackground(to: cell, at: indexPath, in: self.tableView)

        }
        else if let cell = cell as? CenterButtonTableCell {
            cell.btn.setAttributedText(texts: ["Forgot Password?"], attributes: [[NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue]], state: .normal)
            cell.btnTapAction = { [weak self] in
                guard let `self` = self else { return }
                self.openForgotPassVC()
            }
            applyRoundedBackground(to: cell, at: indexPath, in: self.tableView,isBottomRadius: true)

        }
        else if let cell = cell as? LoginCell {
            cell.prepareUI()
            cell.action_social_login = { [weak self] (tag) in
                guard let self = self else { return }
                self.action_social_signin(tag)
            }
        }
        else if let cell = cell as? ButtonTableCell {
            cell.btn.setTitle("Sign In", for: .normal)
            cell.btnTapAction = { [weak self] (_) in
                guard let `self` = self else { return }
                self.loginAction()
            }
        }
    }
}

// MARK: - KPLinkLabelDelagete
extension LoginVC: NLinkLabelDelagete {
    
    func tapOnEmpty(index: IndexPath?) {}
    
    func tapOnTag(tagName: String, type: ActiveType, tappableLabel: NLinkLabel) {
        nprint(items: tagName)
        if tagName == "signUp" {
            let vc = RoleVC.instantiate(from: .Auth)
            self.navigationController?.pushViewController(vc, animated: true)
//            let vc = SignUpVC.instantiate(from: .Auth)
//            vc.screenType = .profile
//            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// MARK: - UIKeyboard Observer
extension LoginVC {
    
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
        tableView.contentInset = UIEdgeInsets.zero
    }
}

// MARK: - API Calls
extension LoginVC {
    
    func loginCall() {
        let cell = tableViewCell(index: arrCells.firstIndex(of: .signin)!) as! ButtonTableCell
        self.showSpinnerIn(container: cell.bgView, control: cell.btn, isCenter: true)
        
        WebCall.call.loginUser(param: data.param.merged(with: Setting.deviceInfo)) { [weak self] (json, status) in
            guard let self = self else { return }
            self.hideSpinnerIn(container: cell.bgView, control: cell.btn)
            if status == 200, let dict = json as? NSDictionary, let data = dict["data"] as? NSDictionary  {
                self.manageUserFlow(data)
            } else {
                self.showError(data: json, yCord: _statusBarHeight)
            }
        }
    }
    
    func socialSignInUser(_ param: [String: Any], signUpModel: SignUpData? = nil) {
        showCentralSpinner()
        WebCall.call.socialSignIn(param: param) { [weak self] (json, status) in
            guard let self = self else { return }
            self.hideCentralSpinner()
            if status == 200, let jData = json as? NSDictionary {
                if let data = jData["data"] as? NSDictionary {
                    self.manageUserFlow(data)
                } else {
                    guard let signUpModel else { return }
                    self.openSignUpForSocial(signUpModel)
                }
            } else {
                self.showError(data: json)
            }
        }
    }
    
    private func openSignUpForSocial(_ data: SignUpData) {
        let vc = RoleVC.instantiate(from: .Auth)
        vc.data = data
        self.navigationController?.pushViewController(vc, animated: true)
//        let vc = SignUpVC.instantiate(from: .Auth)
//        vc.data = data
//        vc.screenType = .profile
//        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    /// Manage app Flow
    private func manageUserFlow(_ data: NSDictionary) {
        
        
        let token = data.getStringValue(key: "token")
        if !token.isEmpty {
            _appDelegator.storeAuthorizationToken(token)
            _appDelegator.saveContext()
        }
        
        let user = LoginResponse(data)
        
        _user = User.addUpdateEntity(key: "id", value: data.getStringValue(key: "id"))
        _user?.initWith(data)
        _user?.pushNotify = data.getBooleanValue(key: "push_notify")
        _user?.textNotify = data.getBooleanValue(key: "text_notification")
        _appDelegator.saveContext()
        
        _userDefault.set(data.getBooleanValue(key: "mobile_verify"), forKey: "mobileVerify")
        _userDefault.set(data.getBooleanValue(key: "email_verify"), forKey: "emailVerify")
        _userDefault.set(data.getBooleanValue(key: "is_personal_information"), forKey: "personalInfoAdded")
        _userDefault.set(data.getBooleanValue(key: "is_emergency_contacts"), forKey: "emergencyInfoAdded")
        _userDefault.synchronize()
        
        if let usr = _user {
            WebCall.call.updatePushToken(param: ["user_id": usr.id]) { (json, status) in
                nprint(items: "Device Token Updated")
            }
        }
        
        if !user.mobileVerify {
            let vc = VerifyOtpVC.instantiate(from: .Auth)
            vc.screenType = .registerMobile
            self.navigationController?.pushViewController(vc, animated: true)
        }else if !user.emailVerify && _appDelegator.config.isEmailOn {
            let vc = VerifyOtpVC.instantiate(from: .Auth)
            vc.screenType = .registerEmail
            self.navigationController?.pushViewController(vc, animated: true)
        } else if !user.personalInfoAdded {
            let vc = SignUpVC.instantiate(from: .Auth)
            vc.screenType = .personal
            vc.loginResponse = user
            self.navigationController?.pushViewController(vc, animated: true)
        } else if !user.emergencyContactAdded {
            let vc = SignUpVC.instantiate(from: .Auth)
            vc.screenType = .emergency
            vc.loginResponse = user
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            _appDelegator.navigateUserToHome()
        }
    }
}
