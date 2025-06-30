//
//  IdVerificationModel.swift
//  CabO
//
//  Created by Octos.
//

import Foundation
import UIKit

// MARK: - IdVerification CellType
enum IdVerificationCellType {
    case addLicenceTitle, addLicenceInfo, addLicenceImage, addLIcenceButton
    case enterNameTitle, firstName, midName, lastName, uploadLicenceTitle, info, imageUpload, verifyStatus, rejectInfo, verifiedSuccess
    
    var cellId: String {
        switch self {
        case .info: return "infoCell"
        case .addLicenceImage: return "addLicenceImageInfo"
        case .addLIcenceButton: return ButtonTableCell.identifier
        case .firstName, .midName, .lastName: return InputCell.identifier
        case .imageUpload: return "documentPickerCell"
        case .verifyStatus: return "verifyStatusCell"
        case .rejectInfo: return "invalidLicenceCell"
        case .verifiedSuccess: return "successCell"
        default: return TitleTVC.identifier
        }
    }
    
    var cellHeight: CGFloat {
        switch self {
        case .addLicenceImage: return _screenSize.height / 2
        case .addLIcenceButton: return ButtonTableCell.cellHeight
        case .imageUpload: return (DeviceType.iPad ? 264 : 196) * _widthRatio
        case .firstName, .midName, .lastName: return InputCell.normalHeight
        default: return UITableView.automaticDimension
        }
    }
    
    var title: String {
        switch self {
        case .addLicenceTitle: return "Let's add your driving licence"
        case .addLicenceInfo: return "This helps us check that you're really you. ID verification is one of the ways we keep \(_appName) secure."
        case .enterNameTitle: return "Enter your name as per ID"
        case .firstName: return "First name*"
        case .midName: return "Middle name"
        case .lastName: return "Last name*"
        case .uploadLicenceTitle: return "Upload driving licence"
        default: return ""
        }
    }
    
    var placeholder: String {
        switch self {
        case .firstName: return "First name*"
        case .midName: return "Middle name (Optional)"
        case .lastName: return "Last name*"
        default: return ""
        }
    }
    
    var titleFont: UIFont {
        switch self {
        case .addLicenceTitle: return AppFont.fontWithName(.mediumFont, size: 24 * _fontRatio)
        case .enterNameTitle, .uploadLicenceTitle: return AppFont.fontWithName(.mediumFont, size: 18 * _fontRatio)
        case .addLicenceInfo: return AppFont.fontWithName(.regular, size: 14 * _fontRatio)
        default: return AppFont.fontWithName(.mediumFont, size: 16 * _fontRatio)
        }
    }
    
    var maxLength: Int {
        switch self {
        default: return 32
        }
    }
}

// MARK: - IdVerification Data
class IdVerificationData {
    
    var id: String?
    var fName: String = ""
    var mName: String = ""
    var lName: String = ""
    var imgLicence: UIImage?
    var imgStr: String?
    var status: DocStatus?
    var rejectStr: String?
    
    init() { }
    
    init(_ dict: NSDictionary) {
        id = dict.getStringValue(key: "driving_license_id")
        fName = dict.getStringValue(key: "first_name")
        mName = dict.getStringValue(key: "middle_name")
        lName = dict.getStringValue(key: "last_name")
        imgStr = dict.getStringValue(key: "driving_license")
        status = DocStatus(dict.getStringValue(key: "status"))
        rejectStr = dict.getStringValue(key: "reject_reason")
    }
    
    var param: [String: Any] {
        var param: [String: Any] = [:]
        if let id {
            param["driving_license_id"] = id
        }
        param["first_name"] = fName
        param["middle_name"] = mName
        param["last_name"] = lName
        return param
    }
    
    func isValid() -> (Bool, String) {
        if fName.isEmpty {
            return (false, "Please enter first name")
        }
        else if !fName.isValidName() {
            return (false, "Please enter valid first name")
        }
        else if !mName.isEmpty && !mName.isValidName() {
            return (false, "Please enter valid middle name")
        }
        else if lName.isEmpty {
            return (false, "Please enter last name")
        }
        else if !lName.isValidName() {
            return (false, "Please enter valid last name")
        }
        else if imgStr == nil && imgLicence == nil {
            return (false, "Please upload licence image")
        } else if id != nil && imgLicence == nil {
            return (false, "Please upload new licence image befor submitting")
        }
        return (true, "")
    }
    
    func getData(_ cellType: IdVerificationCellType) -> String {
        switch cellType {
        case .firstName: return fName
        case .midName: return mName
        case .lastName: return lName
        default: return ""
        }
    }
    
    func setData(_ str: String, _ cellType: IdVerificationCellType) {
        switch cellType {
        case .firstName: fName = str
        case .midName: mName = str
        case .lastName: lName = str
        default: return
        }
    }
}
