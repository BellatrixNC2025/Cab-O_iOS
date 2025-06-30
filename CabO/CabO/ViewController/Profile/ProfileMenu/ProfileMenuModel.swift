//
//  ProfileMenuModel.swift
//  CabO
//
//  Created by Octos.
//

import Foundation
import UIKit

// MARK: - Profile Settings Cells
enum ProfileSettingsCells : CaseIterable{
    case profileImage
    case profileInfo
    case emergencyContact
    case changePass
    case faq
    case aboutUS
    case tnc
    case privacyPolicy
    case cancellationPolicy
    case pushNotification
    case textNotification

    
    var celld: String {
        switch self {
        default: return "profileMenuCell"
        }
    }
    
    var title: String {
        switch self {
        case .profileImage: return "Profile Image"
        case .profileInfo:  return "Personal Information"
        case .emergencyContact:  return "Emergency contacts"
        case .changePass: return "Change password"
        case .faq: return "FAQ's"
        case .aboutUS: return "About Us"
        case .tnc: return "Terms & Conditions"
        case .privacyPolicy:  return "Privacy Policy"
        case .cancellationPolicy: return "Cancellation Policy"
        case .pushNotification: return "Push Notification"
        case .textNotification: return "Text Notification"
        }
    }
    
    var leftImg: UIImage? {
        switch self {
        case .profileImage: return UIImage(named: "ic_profile_image")
        case .profileInfo:  return UIImage(named: "ic_profile_info")
        case .emergencyContact: return UIImage(named: "ic_profile_emergency")
        case .changePass: return UIImage(named: "ic_profile_change_password")
        case .faq: return  UIImage(named: "ic_profile_faqs")
        case .aboutUS: return UIImage(named: "ic_profile_aboutus")
        case .tnc: return UIImage(named: "ic_profile_terms")
        case .privacyPolicy: return UIImage(named: "ic_profile_privacy")
        case .cancellationPolicy: return UIImage(named: "ic_profile_cancellation")
        case .pushNotification: return UIImage(named: "ic_profile_notification")
        case .textNotification: return UIImage(named: "ic_profile_text")
        }
    }
    
    var isSwitch: Bool {
        switch self {
        case .pushNotification, .textNotification: return true
        default: return false
        }
    }
}
