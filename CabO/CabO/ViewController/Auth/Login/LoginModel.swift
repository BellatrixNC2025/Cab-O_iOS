//
//  LoginModel.swift
//  CabO
//
//  Created by Octos.
//

import Foundation
import UIKit

// MARK: - LoginCells ENUM
enum LoginCells: CaseIterable {
    case header,title, phone, pass, forgot, signin, social
    
    var cellId: String {
        switch self {
        case .header : return "headerCell"
        case .title: return TitleTVC.identifier
        case .phone, .pass: return InputCell.identifier
        case .signin: return ButtonTableCell.identifier
        case .forgot: return "forgotCell"
        case .social: return "socialAlternateCell" //socialCell"
        }
    }
    
    var cellHeight: CGFloat {
        switch self {
        case .header : return 300 * _widthRatio
        case .phone, .pass: return InputCell.normalHeight
        case .signin: return ButtonTableCell.cellHeight
        case .forgot: return 44 * _widthRatio
//        case .social: return 88 * _widthRatio
        default: return InputCell.normalHeight
        }
    }
    
    var inputTitle: String {
        switch self {
        case .title:
            return "Sign in"
        case .phone:
            return "Mobile Number"
        case .pass:
            return "Password"
        case .forgot:
            return ""
        default: return ""
        }
    }
    
    var inputPlaceholder: String {
        switch self {
        case .phone:
            return "Mobile Number"
        case .pass:
            return "Password"
        case .forgot:
            return ""
        default: return ""
        }
    }
    
    var leftImage: UIImage? {
        switch self {
        case .phone: return UIImage(named: "ic_mobile")
        case .pass: return UIImage(named: "ic_password")
        default: return nil
        }
    }
    
    var maxLength: Int? {
        switch self {
        case .phone: return 10
        case .pass: return 24
        default : return 250
        }
    }
    var keyboard: UIKeyboardType {
        switch self {
        case .phone: return .phonePad
        default: return .asciiCapable
        }
    }
}

//MARK: - Login Data
class LoginData {
    
    var mobile = ""
    var password = ""
    
    var param: [String: Any] {
        var param: [String: String] = [:]
        param["source"] = mobile.isNumber ? "mobile" : "email"
        param["sourceid"] = mobile
        param["password"] = password
        return param
    }
    
    func isValidData() -> (Bool, String) {
        if mobile.isEmpty {
            return (false, "Please enter your registered Mobile Number")
        }
        else if mobile.isNumeric {
            return (mobile.removeSpace().isValidContact(), "Please enter a valid Mobile Number")
        } else if !mobile.isValidEmailAddress() {
            return (false, "Please enter a valid email address")
        }
        else if password.isEmpty {
            return (false, "Please enter a password")
        }
        return (true, "")
    }
    
    func getLoginData(_ cellType: LoginCells) -> String {
        switch cellType {
            case .phone: return mobile
            case .pass : return password
            default: return ""
        }
    }
    
    func setLoginData(_ str: String, cellType: LoginCells) {
        switch cellType {
            case .phone:
                mobile = str
            case .pass:
                password = str
            default: break
        }
    }
}

// MARK: - LoginResponse
class LoginResponse {
    
    var id: Int!
    var image: String = ""
    var firstName: String = ""
    var lastName: String = ""
    var email: String = ""
    var mobile: String = ""
    var emailVerify: Bool = false
    var mobileVerify: Bool = false
    var pushNotify: Bool = true
    var textNotify: Bool = true
    var personalInfoAdded: Bool = false
    var emergencyContactAdded: Bool = false
    var roleValue: String = ""
    
    var role: Role {
        return Role(roleValue)
    }
    init(_ dict: NSDictionary) {
        id = dict.getIntValue(key: "id")
        image = dict.getStringValue(key: "image")
        firstName = dict.getStringValue(key: "first_name")
        lastName = dict.getStringValue(key: "last_name")
        email = dict.getStringValue(key: "email")
        mobile = dict.getStringValue(key: "mobile")
        emailVerify = dict.getBooleanValue(key: "email_verify")
        mobileVerify = dict.getBooleanValue(key: "mobile_verify")
        pushNotify = dict.getBooleanValue(key: "push_notify")
        textNotify = dict.getBooleanValue(key: "text_notification")
        personalInfoAdded = dict.getBooleanValue(key: "is_personal_information")
        emergencyContactAdded = dict.getBooleanValue(key: "is_emergency_contacts")
        emergencyContactAdded = dict.getBooleanValue(key: "is_emergency_contacts")
        roleValue = dict.getStringValue(key: "role")
    }
}
