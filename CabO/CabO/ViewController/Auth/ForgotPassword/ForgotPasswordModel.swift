//
//  ForgotPasswordModel.swift
//  CabO
//
//  Created by Octos.
//

import Foundation
import UIKit

// MARK: - ForgotPassCells ENUM
enum ForgotPassCells: CaseIterable {
    case title, desc, email, signin
    
    var cellId: String {
        switch self {
        case .title, .desc: return TitleTVC.identifier
        case .email: return InputCell.identifier
        case .signin: return ButtonTableCell.identifier
        }
    }
    
    var cellHeight: CGFloat {
        switch self {
        case .email: return InputCell.normalHeight 
        case .signin: return ButtonTableCell.cellHeight + 10
        default: return InputCell.normalHeight
        }
    }
    
    var inputTitle: String {
        switch self {
        case .title: return "Don't worry!"
        case .desc: return "It happens. Please enter the mobile number associated with your account"
        case .email: return "Mobile Number"
        default: return ""
        }
    }
    
    var inputPlaceholder: String {
        switch self {
        case .email: return "Mobile Number"
        default: return ""
        }
    }
    
    var leftImage: UIImage? {
        switch self {
        case .email: return UIImage(named: "ic_mobile")
        default: return nil
        }
    }
}

// MARK: - ResetPasswordData MODEL
class ResetPasswordData {
    
    var emailMobile: String = ""
    
    var currentPass: String = ""
    var newPass: String = ""
    var confirmPass: String = ""
    
    var passVisible: Bool = false
    var confirmPassVisible: Bool = false
    
    var changeParam: [String: Any] {
        var param: [String: Any] = [:]
        param["current_password"] = currentPass
        param["n_password"] = newPass
        return param
    }
    
    func isValidForgotData() -> (Bool, String) {
        if emailMobile.isEmpty {
            return (false, "Please enter Mobile Number")
        }
        else if emailMobile.isNumeric && !emailMobile.isValidContact(){
            return (false, "Please enter valid Mobile Number")
        } else if !emailMobile.isNumeric && !emailMobile.isValidEmailAddress() {
            return (false, "Please enter valid Mobile Number")
        }
        return (true, "")
    }
    
    func isValidResetPass() -> (Bool, String) {
        if newPass.isEmpty {
            return (false, "Please enter new password")
        }
        else if !newPass.isPasswordValid() {
            return (false, "The password must be at least 8 characters long and include a number, lowercase letter, uppercase letter and special character (Any from @!#$%^&+=)")
        }
        else if confirmPass.isEmpty {
            return (false, "Please enter new password again")
        }
        else if confirmPass != newPass {
            return (false, "Confirm password does not match")
        }
        return (true, "")
    }
    
    func isValidChangePass() -> (Bool, String) {
        if currentPass.isEmpty {
            return (false, "Please enter current password")
        }
        else if newPass.isEmpty {
            return (false, "Please enter new password")
        }
        else if !newPass.isPasswordValid() {
            return (false, "The password must be at least 8 characters long and include a number, lowercase letter, uppercase letter and special character (Any from @!#$%^&+=)")
        }
        else if confirmPass.isEmpty {
            return (false, "Please enter new password again")
        }
        else if confirmPass != newPass {
            return (false, "Confirm password does not match")
        }
        return (true, "")
    }
    
    func getValue(_ cellType: ForgotPassCells) -> String {
        switch cellType {
        case .email: return emailMobile
        default: return ""
        }
    }
    
    func getValue(_ cellType: ResetPassCells) -> String{
        switch cellType {
        case .pass: return newPass
        case .conPass: return confirmPass
        default: return ""
        }
    }
    
    func getValue(_ cellType: ChangePassCells) -> String{
        switch cellType {
        case .current: return currentPass
        case .pass: return newPass
        case .conPass: return confirmPass
        default: return ""
        }
    }
    
    func setValue(_ str: String, _ cellType: ForgotPassCells) {
        switch cellType {
        case .email: emailMobile = str
        default: break
        }
    }
    
    func setValue(_ str: String, _ cellType: ResetPassCells) {
        switch cellType {
        case .pass: newPass = str
        case .conPass: confirmPass = str
        default: break
        }
    }
    
    func setValue(_ str: String, _ cellType: ChangePassCells) {
        switch cellType {
        case .current: currentPass = str
        case .pass: newPass = str
        case .conPass: confirmPass = str
        default: break
        }
    }
}
