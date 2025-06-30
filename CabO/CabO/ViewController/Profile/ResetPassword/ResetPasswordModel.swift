//
//  ResetPasswordModel.swift
//  CabO
//
//  Created by Octos.
//

import Foundation
import UIKit

// MARK: - ResetPassCells
enum ResetPassCells: CaseIterable {
    case title, pass, conPass, btn
    
    var cellId: String {
        switch self {
        case .title: return TitleTVC.identifier
        case .pass, .conPass: return InputCell.identifier
        case .btn: return ButtonTableCell.identifier
        }
    }
    
    var cellHeight: CGFloat {
        switch self {
        case .pass, .conPass: return InputCell.normalHeight
        case .btn: return ButtonTableCell.cellHeight + 24
        default: return InputCell.normalHeight
        }
    }
    
    var inputTitle: String {
        switch self {
        case .title: return "Please enter the New Password for your account"
        case .pass: return "Password*"
        case .conPass: return "Confirm password*"
        default: return ""
        }
    }
    
    var inputPlaceholder: String {
        switch self {
        case .pass: return "Enter Password"
        case .conPass: return "Enter password again"
        default: return ""
        }
    }
    
    var leftImage: UIImage? {
        switch self {
        case .pass, .conPass: return UIImage(named: "ic_password")
        default: return nil
        }
    }
    
    var maxLength: Int {
        switch self {
        default: return 24
        }
    }
}
