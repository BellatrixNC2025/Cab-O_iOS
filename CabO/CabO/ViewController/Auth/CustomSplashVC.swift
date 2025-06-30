//
//  CustomSplashVC.swift
//  CabO
//
//  Created by Octos.
//

import UIKit
import StripeCore
import AWSCore

class CustomSplashVC: ParentVC {

    override func viewDidLoad() {
        super.viewDidLoad()
        getAppCnfig()
    }
    
    /// Set App Navigation
    func navigateUser() {
        if _appDelegator.isUserLoggedIn() {
            WebCall.call.setAccesTokenToHeader(token: _appDelegator.getAuthorizationToken()!)
            _appDelegator.getUserProfile() { [weak self] (_,_) in
                guard let self = self else { return }
                self.checkForVerification()
            }
        } else {
            _appDelegator.isAppOpenForFirstTime()
        }
        _appDelegator.registerDeviceForPushNotification()
        
//        _appDelegator.navigateUserToHome()
    }
    
    /// Check for user verification
    func checkForVerification() {
        if !(_userDefault.value(forKey: "personalInfoAdded") as? Bool ?? true) {
            let vc = SignUpVC.instantiate(from: .Auth)
            vc.screenType = .personal
            self.navigationController?.pushViewController(vc, animated: true)
        }else if !(_userDefault.value(forKey: "mobileVerify") as? Bool ?? true) {
            let vc = VerifyOtpVC.instantiate(from: .Auth)
            vc.screenType = .registerMobile
            vc.isResendOtp = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
        //As of now no email verification and emergencyInfo during signup flow
//        else if !(_userDefault.value(forKey: "emailVerify") as? Bool ?? true) {
//            let vc = VerifyOtpVC.instantiate(from: .Auth)
//            vc.screenType = .registerEmail
//            vc.isResendOtp = true
//            self.navigationController?.pushViewController(vc, animated: true)
//        } else if !(_userDefault.value(forKey: "emergencyInfoAdded") as? Bool ?? true) {
//            let vc = SignUpVC.instantiate(from: .Auth)
//            vc.screenType = .emergency
//            self.navigationController?.pushViewController(vc, animated: true)
//        }
        else {
            _appDelegator.navigateUserToHome()
        }
    }
}

// MARK: - API Call
extension CustomSplashVC {
    
    func getAppCnfig() {
        WebCall.call.getConfig { [weak self] (json, status) in
            guard let self = self else { return }
            if status == 200, let dict = json as? NSDictionary, let dData = dict["data"] as? [NSDictionary] {
                var param: [String: Any] = [:]
                dData.forEach { data in
                    let key = data.getStringValue(key: "alias_name")
                    let value = data.getStringValue(key: "setting_value")
                    param[key] = value
                }
                _appDelegator.config = Config(param as NSDictionary)
                _appDelegator.configureAWS()
                StripeAPI.defaultPublishableKey = _appDelegator.config.stripe_key
                
                self.navigateUser()
            } else {
                self.getAppCnfig()
            }
        }
    }
}
