//
//  EditProfileModel.swift
//  CabO
//
//  Created by Octos.
//

import Foundation
import UIKit

// MARK: - EditProfileScreenType
enum EditProfileScreenType {
    case profile,  emergency
    
    init?(_ type: ProfileSettingsCells) {
        switch type {
        case .profileInfo: self = .profile
        case .emergencyContact: self = .emergency
        default: self = .profile
        }
    }
    
    var title: String {
        switch self {
        case .profile: return "Profile information"
        case .emergency: return "Emergency contacts"
        }
    }
}

// MARK: - EditProfileCellType
enum EditProfileCellType {
    case fname, lname, email, emailVerified, mobile, mobileVerified, dob, gender,homeAddress, bio, fb, twit, insta, btn, eContact, addMore
    
    var identifier: String {
        switch self {
        case .btn: return ButtonTableCell.identifier
        case .bio: return InputCell.textViewIdentifier
        case .addMore: return "addMoreCell"
        case .eContact: return AddEmergencyContactCell.identifier
        default: return InputCell.identifier
        }
    }
    
    var cellHeight: CGFloat {
        switch self {
        case .btn: return ButtonTableCell.cellHeight + 24
        case .gender: return InputCell.normalHeight
        case .bio: return 140 * _widthRatio
//        case .eInfo:
//            let titleHeight: CGFloat = "Benefits".heightWithConstrainedWidth(width: _screenSize.width - (232 * _widthRatio), font: AppFont.fontWithName(.mediumFont, size: 20 * _fontRatio)) + 24 * _heightRatio
//            let info1Height: CGFloat = "You can add up to 3 people to your emergency contacts".heightWithConstrainedWidth(width: _screenSize.width - (232 * _widthRatio), font: AppFont.fontWithName(.regular, size: 12 * _fontRatio)) + 12 * _heightRatio
//            let info2Height: CGFloat = "In case of an emergency you can choose to inform them when you raise an alert".heightWithConstrainedWidth(width: _screenSize.width - (232 * _widthRatio), font: AppFont.fontWithName(.regular, size: 12 * _fontRatio)) + 22 * _heightRatio
//            let height = titleHeight + info1Height + info2Height
//            return max(height, 220 * _heightRatio)
        case .addMore: return 44 * _widthRatio
        case .eContact: return AddEmergencyContactCell.normalHeight
        default: return InputCell.normalHeight //UITableView.automaticDimension
        }
    }
    
    var inputTitle: String {
        switch self {
        case .fname: return "First name*"
        case .lname: return "Last name*"
        case .mobile: return "Mobile Number*"
        case .email: return "Email address*"
        case .dob: return "Date of birth*"
        case .gender: return "Gender*"
        case .bio: return "Add something about you"
        case .fb: return "Facebook"
        case .twit: return "X"
        case .insta: return "Instagram"
        case .homeAddress: return "Home Address*"
        default: return ""
        }
    }
    
    var inputPlaceholder: String {
        switch self {
        case .fname: return "First name"
        case .lname: return "Last name"
        case .mobile: return "Mobile Number*"
        case .email: return "Email address*"
        case .dob: return "Date of birth"
        case .gender: return "Gender"
        case .bio: return "Write something here (Optional)"
        case .fb: return "Facebook profile link (Optional)"
        case .twit: return "X profile link (Optional)"
        case .insta: return "Instagram profile link (Optional)"
        default: return ""
        }
    }
    
    var leftImage: UIImage? {
        switch self {
        case .fname, .lname: return UIImage(named: "ic_person")
        case .email: return UIImage(named: "ic_mail")
        case .mobile: return UIImage(named: "ic_mobile")
        case .dob: return UIImage(named: "ic_dob")
        case .bio: return UIImage(named: "ic_bio")
        case .gender: return UIImage(named: "ic_select_gender")
        case .fb: return UIImage(named: "ic_fb")
        case .twit: return UIImage(named: "ic_twit")
        case .insta: return UIImage(named: "ic_insta")
        default: return nil
        }
    }
    
    var infoText: String {
        switch self {
        case .fb: return "Ex. www.facebook.com/jone"
        case .twit: return "Ex. www.x.com/jone"
        case .insta: return "Ex. www.instagram.com/jone"
        default: return ""
        }
    }
    
    var returnKeyType: UIReturnKeyType {
        switch self {
        case .lname, .insta: return .done
        default: return .next
        }
    }
    
    var inputAccView: Bool {
        switch self {
        case .dob, .bio: return true
        default: return false
        }
    }
    
    var isEditable: Bool {
        switch self {
        case .email, .mobile: return false
        default: return true
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
class EditProfileData {
    
    var fName: String = _user!.firstName
    var lName: String = _user!.lastName
    var email: String = _user!.emailAddress
    var mobile: String = _user!.mobileNumber.formatPhoneNumber()
    var dob: Date?
    var gender: Gender?
    var bio: String = ""
    var fbLink: String = ""
    var twitLink: String = ""
    var instaLink: String = ""
    var homeAddress: SearchAddress?
    init() { }
    
    init(_ dict: NSDictionary) {
        dob = Date.dateFromLocalFormat(from: dict.getStringValue(key: "date_of_birth"), format: DateFormat.serverDateFormat)
        gender = Gender(dict.getStringValue(key: "gender"))
        bio = dict.getStringValue(key: "something_about_you")
        fbLink = dict.getStringValue(key: "facebook_url")
        twitLink = dict.getStringValue(key: "twitter_url")
        instaLink = dict.getStringValue(key: "instagram_url")
    }
    
    var isDataReady: Bool {
        return false
    }
    
    var isDataChanged: Bool {
        if fName != _user!.firstName {
            return true
        }
        if lName != _user!.lastName {
            return true
        }
        return false
    }
    
    var editProfileInfoParam: [String: Any] {
        var param: [String: Any] = [:]
        param["type"] = "profile"
        param["first_name"] = fName
        param["last_name"] = lName
        param["date_of_birth"] = Date.localDateString(from: dob!, format: DateFormat.serverDateFormat)
        param["gender"] = gender?.title.lowercased()
        param["something_about_you"] = bio
        if _user?.role == .driver {
            param["address"] = homeAddress?.formatedAddress
            param["zipcode"] = homeAddress?.zipcode
            param["state"] = homeAddress?.state
            param["city"] = homeAddress?.city
            param["county"] = homeAddress?.country
            param["latitude"] = homeAddress?.lat
            param["longitude"] = homeAddress?.long
            
        }
        return param
    }
    
    var personalInfoParam: [String: Any] {
        var param: [String: Any] = [:]
        param["type"] = "personal_information"
        param["date_of_birth"] = Date.localDateString(from: dob!, format: DateFormat.serverDateFormat)
        param["gender"] = gender?.title.lowercased()
        param["something_about_you"] = bio
        param["facebook_url"] = fbLink
        param["twitter_url"] = twitLink
        param["instagram_url"] = instaLink
        return param
    }
    
    func isValidData(_ editType: EditProfileScreenType) -> (Bool, String) {
        if editType == .profile {
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
//        } else if editType == .personal {
            if dob == nil {
                return (false, "Please select date of birth")
            } else if gender == nil {
                return (false, "Please select gender")
            }else if homeAddress == nil && _user!.role == .driver {
                return (false, "Please select your gender")
            }
//            else if !fbLink.isEmpty && !fbLink.contains(find: "www.facebook.com/"){
//                return (false, "Please enter valid facebook url")
//            } else if !twitLink.isEmpty && !twitLink.contains(find: "www.x.com/"){
//                return (false, "Please enter valid x url")
//            } else if !instaLink.isEmpty && !instaLink.contains(find: "www.instagram.com/"){
//                return (false, "Please enter valid instagram url")
//            }
        }
        return (true, "")
    }
    
    func getValue(_ cellType: EditProfileCellType) -> String{
        switch cellType {
        case .fname: return fName
        case .lname: return lName
        case .mobile: return mobile.formatPhoneNumber()
        case .email: return email
        case .dob: return Date.localDateString(from: dob, format: DateFormat.format_MMMddyyyy)
        case .gender: return gender?.title ?? ""
        case .bio: return bio
        case .fb: return fbLink
        case .twit: return twitLink
        case .insta: return instaLink
        default: return ""
        }
    }
    
    func setValue(_ str: String, _ cellType: EditProfileCellType) {
        switch cellType {
        case .fname: fName = str
        case .lname: lName = str
        case .mobile: mobile = str.removeSpace()
        case .email: email = str
        case .bio: bio = str
        case .fb: fbLink = str
        case .twit: twitLink = str
        case .insta: instaLink = str
        default: break
        }
    }
}

// MARK: - EmergencyContactData
class EmergencyContactData{
    
    var name: String = ""
    var phoneNumber: String = ""
    
    init() { }
    
    init(_ dict: NSDictionary) {
        name = dict.getStringValue(key: "user_name")
        phoneNumber = dict.getStringValue(key: "phone_number")
    }
    
    var param: [String: Any] {
        var param: [String: Any] = [:]
        param["user_name"] = name
        param["phone_number"] = phoneNumber
        return param
    }
    
    func isValid() -> (Bool, String) {
        if name.isEmpty {
            return (false, "Please enter name of contact")
        } else if !name.isValidName() {
            return (false, "Please enter valid name of contact")
        } else if phoneNumber.isEmpty {
            return (false, "Please enter Mobile Number of contact")
        } else if !phoneNumber.isValidContact() {
            return (false, "Please enter valid Mobile Number of contact")
        }
        return (true, "")
    }
    
    func getValue(_ tag: Int) -> String {
        switch tag {
            case 0: return name
        case 1 : return phoneNumber.formatPhoneNumber()
            default: return ""
        }
    }
    
    func setValue(_ str: String,_ tag: Int) {
        switch tag {
            case 0:
                name = str
            case 1:
                phoneNumber = str.removeSpace()
            default: break
        }
    }
}
//MARK: - ProfileMenuCell
class DataVerifiedCell: ConstrainedTableViewCell {
    

    /// Outlets
    @IBOutlet weak var imgVerifyBadgeRight: TintImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnChange: UIButton!
    
    /// Variables
    var btnChangeTap: (() -> ())?
    
    weak var parent: ProfileVC!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func prepareUI(_ cellType: EditProfileCellType) {

        if cellType == .mobileVerified {
            if _user?.mobileVerify == true{
                lblTitle?.text = "Verified"
                btnChange.backgroundColor = AppColor.appBg
                btnChange.setTitle("Change", for: .normal)
                lblTitle.textColor = AppColor.themeGreen
                imgVerifyBadgeRight.tintColor = AppColor.themeGreen
            }else{
                lblTitle?.text = "Verified Pending"
                btnChange.backgroundColor = AppColor.themeGreen
                btnChange.setTitle("Verify", for: .normal)
                lblTitle.textColor = AppColor.themeGray
                imgVerifyBadgeRight.tintColor = AppColor.themeGray
            }
        } else {
            if _user?.emailVerify == true{
                lblTitle?.text = "Verified"
                btnChange.backgroundColor = AppColor.appBg
                btnChange.setTitle("Change", for: .normal)
                lblTitle.textColor = AppColor.themeGreen
                imgVerifyBadgeRight.tintColor = AppColor.themeGreen
            }else{
                lblTitle?.text = "Verified Pending"
                btnChange.backgroundColor = AppColor.themeGreen
                btnChange.setTitle("Verify", for: .normal)
                lblTitle.textColor = AppColor.themeGray
                imgVerifyBadgeRight.tintColor = AppColor.themeGray
            }
        }
        self.layoutIfNeeded()
    }
    
    @IBAction func btnRightTap(_ sender: UIButton) {
        self.btnChangeTap?()
    }
    
   
}
