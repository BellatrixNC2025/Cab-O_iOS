//
//  ChangePasswordModel.swift
//  CabO
//
//  Created by Octos.
//

import Foundation
import UIKit

// MARK: - ChangePassCells
enum ChangePassCells: CaseIterable {
    case current, pass, conPass, btn
    
    var cellId: String {
        switch self {
        case .current, .pass, .conPass: return InputCell.identifier
        case .btn: return ButtonTableCell.identifier
        }
    }
    
    var cellHeight: CGFloat {
        switch self {
        case .btn: return ButtonTableCell.cellHeight + 24
        default: return InputCell.normalHeight
        }
    }
    
    var inputTitle: String {
        switch self {
        case .current: return "Current password*"
        case .pass: return "New password*"
        case .conPass: return "Confirm password*"
        default: return ""
        }
    }
    
    var inputPlaceholder: String {
        switch self {
        case .current: return "Current password"
        case .pass: return "New password"
        case .conPass: return "Confirm password"
        default: return ""
        }
    }
    
    var leftImage: UIImage? {
        switch self {
        case .current, .pass, .conPass: return UIImage(named: "ic_password")
        default: return nil
        }
    }
    
    var maxLength: Int {
        switch self {
        default: return 24
        }
    }
}
