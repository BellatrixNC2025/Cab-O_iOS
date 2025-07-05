//
//  Enums.swift
//  CabO
//
//  Created by Octos.
//

import Foundation
import UIKit

// MARK: - AppThemeType
enum AppThemeType: Int, CaseIterable {
    case system = 0, light, dark
    
    init?(_ theme: UIUserInterfaceStyle) {
        switch theme {
        case .unspecified: self = .system
        case .light: self = .light
        case .dark: self = .dark
        @unknown default: self = .system
        }
    }
    
    var strValue: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }
    
    var appTheme: UIUserInterfaceStyle {
        switch self {
        case .system: return UITraitCollection.current.userInterfaceStyle
        case .light: return .light
        case .dark: return .dark
        }
    }
    
    var themeImage: UIImage {
        switch self {
        case .system: return UIImage(named: "ic_dropdown")!.withTintColor(AppColor.primaryText)
        case .light: return UIImage(named: "ic_dropdown")!.withTintColor(AppColor.primaryText)
        case .dark: return UIImage(named: "ic_dropdown")!.withTintColor(AppColor.primaryText)
        }
    }
}

//MARK: - POPup
enum ButtonType: Equatable{
    case
    delete,
    cancel,
    ok,
    yes,
    no
    case custom(title: String)
    
    var title: String{
        switch self {
        case .delete:
            return "Delete"
        case .cancel:
            return "Cancel"
        case .ok:
            return "Ok"
        case .yes:
            return "Yes"
        case .no:
            return "No"
        case .custom(let title):
                    return title
        }
    }
}

// MARK: - Gender ENUM
enum Gender: CaseIterable {
    case male, female
    
    init(_ str: String) {
        switch str.lowercased() {
        case "male": self = .male
        case "female": self = .female
        default: self = .male
        }
    }
    
    var title: String {
        switch self {
        case .male: return "Male"
        case .female: return "Female"
        }
    }
    
    var image: UIImage {
        switch self {
        case .male: return UIImage(named: "ic_male")!
        case .female: return UIImage(named: "ic_female")!
        }
    }
}

// MARK: - DocStatus
enum DocStatus {
    case pending, verified, rejected, expired
    
    init(_ str: String) {
        if str.lowercased() == "pending" {
            self = .pending
        } else if str.lowercased() == "verified" {
            self = .verified
        } else if str.lowercased() == "expired" {
            self = .expired
        } else {
            self = .rejected
        }
    }
    
    var apiValue: String {
        switch self {
        case .verified: return "verified"
        case .pending: return "pending"
        case .rejected: return "rejected"
        case .expired: return "expired"
        }
    }
    
    var title: String {
        switch self {
        case .verified: return "Verified"
        case .pending: return "Pending"
        case .rejected: return "Rejected"
        case .expired: return "Expired"
        }
    }
    
    var imgStatus: UIImage {
        switch self {
        case .verified, .pending: return UIImage(systemName: "checkmark.seal.fill")!
        case .rejected: return UIImage(systemName: "xmark.seal.fill")!
        case .expired: return UIImage(named: "ic_doc_expired")!
        }
    }
    
    var statusColor: UIColor {
        switch self {
        case .verified: return AppColor.themeGreen
        case .pending: return AppColor.placeholderText
        case .rejected: return UIColor.red
        case .expired: return UIColor.hexStringToUIColor(hexStr: "#FFBB00")
        }
    }
    
    var enableDisableColor: UIColor {
        switch self {
        case .verified: return AppColor.themeGreen
        default: return AppColor.placeholderText
        }
    }
}

// MARK: - CreateRideRediration
enum CreateRideRediration: String {
    case offerRide = "offer_ride_flag"
    case carVerify = "car_verify_flag"
    case carDocReject = "car_document_rejected_flag"
    case bankDetail = "stripe_flag"
    case carDocExpire = "car_document_expiry_flag"
    case idVerification = "id_verification"
    
    var buttonTitle: String {
        switch self {
        case .offerRide, .carVerify : return "Go to my profile"
        case .carDocExpire, .carDocReject: return "Go to my cars"
        case .bankDetail: return "Connet now"
        case .idVerification: return "Check my documents"
        }
    }
}
// MARK: - Drive Type
enum driveType : String {
    case car = "car"
    case auto = "auto"
    case both = "both"
}
