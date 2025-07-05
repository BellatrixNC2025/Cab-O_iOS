//
//  AddDriverModel.swift
//  CabO
//
//  Created by OctosMac on 05/07/25.
//

import Foundation
import UIKit

// MARK: - Add Driver Cell Type
enum AddDriverCellType {
    case title, fname, lname, email, mobile, driveType, btn
    
    var identifier: String {
        switch self {
        case .title: return "titleCell"
        case .btn: return "btnCell"
        default: return InputCell.identifier
        }
    }
    
    var cellHeight: CGFloat {
        switch self {
        case .btn: return ButtonTableCell.cellHeight
        default: return InputCell.normalHeight //UITableView.automaticDimension
        }
    }
    
    var inputTitle: String {
        switch self {
        case .fname: return "First name*"
        case .lname: return "Last name*"
        case .mobile: return "Mobile Number*"
        case .email: return "Email address*"
        case .driveType: return "Drive Type*"
        default: return ""
        }
    }
    
    var inputPlaceholder: String {
        switch self {
        case .fname: return "First name"
        case .lname: return "Last name"
        case .mobile: return "Mobile Number*"
        case .email: return "Email address*"
        case .driveType: return "Select drive type"
       
        default: return ""
        }
    }
    
  
    var returnKeyType: UIReturnKeyType {
        switch self {
        case .lname : return .done
        default: return .next
        }
    }
    
    var inputAccView: Bool {
        switch self {
        default: return false
        }
    }

    
    var capitalCase: UITextAutocapitalizationType {
        switch self {
        case .fname, .lname: return .sentences
        default: return .none
        }
    }
    
    var keyboardType: UIKeyboardType {
        switch self {
        default: UIKeyboardType.asciiCapable
        }
    }
    
    var maxLength: Int {
        switch self {
        case .fname, .lname : return 32
        case .mobile: return 10
        default: return 250
        }
    }
}
//MARK: - Edit Profile Data
class AddDriverData {
    
    var fName: String = ""
    var lName: String = ""
    var email: String = ""
    var mobile: String = ""
    var driveType: String = ""
    
    init() { }

    var addDeriverParam: [String: Any] {
        var param: [String: Any] = [:]
        param["first_name"] = fName
        param["last_name"] = lName
        param["email"] = email
        param["mobile"] = mobile.removeSpace()
        param["driveType"] = driveType
       
        return param
    }
    

    
    func isValidData() -> (Bool, String) {
        if fName.isEmpty {
            return (false, "Please enter first name")
        }
        else if !fName.isValidName() {
            return (false, "Please enter valid first name")
        }
        else if lName.isEmpty {
            return (false, "Please enter last name")
        }
        else if !lName.isValidName() {
            return (false, "Please enter valid last name")
        }
        else if mobile.isEmpty {
            return (false, "Please enter your Mobile Number")
        }
        else if !mobile.isValidContact() {
            return (false, "Please enter a valid Mobile Number")
        }
        else if email.isEmpty {
            return (false, "Please enter your email address")
        }
        else if !email.isValidEmailAddress() {
            return (false, "Please enter a valid email address")
        }
        return (true, "")
    }
    
    func getValue(_ cellType: AddDriverCellType) -> String{
        switch cellType {
        case .fname: return fName
        case .lname: return lName
        case .mobile: return mobile.formatPhoneNumber()
        case .email: return email
        case .driveType: return driveType
        default: return ""
        }
    }
    
    func setValue(_ str: String, _ cellType: AddDriverCellType) {
        switch cellType {
        case .fname: fName = str
        case .lname: lName = str
        case .mobile: mobile = str.removeSpace()
        case .email: email = str
        case .driveType : driveType = str
        default: break
        }
    }
}
// MARK: - DeleteAccountCell
class AddDriverCell: ConstrainedTableViewCell {
    
    /// Outlets
    @IBOutlet weak var labelTitle: UILabel!
    
    @IBOutlet var btnSubmit: NRoundButton!
    @IBOutlet var btnClose: TintButton!
    /// Variables
    weak var parent: AddDriverVC!
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
    }
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func prepareU() {
    }
    
    @IBAction func btnCloseTap(_ sender: UIButton) {
        parent.btnCloseTap(sender)
    }
    @IBAction func btnSubmitTap(_ sender: UIButton) {
        parent.btnSubmitTap(sender)
    }
    
}
