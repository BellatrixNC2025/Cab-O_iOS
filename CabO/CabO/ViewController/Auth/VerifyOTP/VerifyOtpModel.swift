//
//  VerifyOtpModel.swift
//  CabO
//
//  Created by Octos.
//

import Foundation
import UIKit

// MARK: - Otp Screen Type ENUM
enum OtpVCType {
    case registerMobile, registerEmail, forgotMobile, forgotEmail, updateEmail, updateMobile, riderCode
    
    var title: String {
        switch self {
        case .updateEmail, .registerEmail, .forgotEmail: return "4-digit Code"
        case .updateMobile, .registerMobile, .forgotMobile: return "4-digit Code"
        case .riderCode: return "Code"
        }
    }
    var subTitle: String {
        switch self {
        case .updateEmail, .registerEmail, .forgotEmail: return "Please enter the verification code\nyou received on email"
        case .updateMobile, .registerMobile, .forgotMobile: return "Please enter the verification code\nyou received on Mobile Number"
        case .riderCode: return "Please enter the verification code\nyou received on Mobile Number"
        }
    }
    
    var sourceFrom: String {
        switch self {
        case .registerEmail, .registerMobile: return "signup"
        case .updateEmail, .updateMobile: return "profile"
        default: return ""
        }
    }
    
    var sourceType: String {
        switch self {
        case .updateEmail, .registerEmail: return "email"
        case .updateMobile, .registerMobile: return "mobile"
        default: return ""
        }
    }
    
    var resendSource: String {
        switch self {
        case .registerEmail: return "email"
        case .registerMobile: return "mobile"
        case .forgotEmail: return "forgot_email"
        case .forgotMobile: return "forgot_mobile"
        case .updateEmail: return "new_email"
        case .updateMobile: return "new_mobile"
        case .riderCode: return "rider_code"
        }
    }
    
    var animationType: LottieAnimationName {
        switch self {
        case .updateEmail, .registerEmail, .forgotEmail: return .otpEmail
        case .updateMobile, .registerMobile, .forgotMobile: return .otpMobile
        case .riderCode: return .otpMobile
        }
    }
    
    var gif: String {
        switch self {
        case .updateEmail, .registerEmail, .forgotEmail: return "email_otp"
        case .updateMobile, .registerMobile, .forgotMobile, .riderCode: return "mobile_otp"
        }
    }
}

// MARK: - VerifyOtpCells ENUM
enum VerifyOtpCells: CaseIterable {
    case title, subtitle, email, otp, otpTimer, btn
    
    var cellId: String {
        switch self {
        case .title, .subtitle: return TitleTVC.identifier
        case .email: return "editInfoCell"
        case .otp: return OtpCell.otpIdentifier
        case .otpTimer: return "timerCell"
        case .btn: return ButtonTableCell.identifier
        }
    }
    
    var cellHeight: CGFloat {
        switch self {
        case .email: return 60
        case .otp: return OtpCell.normalHeight
        case .otpTimer: return 54 * _widthRatio
        case .btn: return ButtonTableCell.cellHeight + 24
        default: return 24
        }
    }
    
    var inputTitle: String {
        switch self {
        case .email: return "Mobile Number"
        default: return ""
        }
    }
    
    var inputPlaceholder: String {
        switch self {
        default: return ""
        }
    }
}
