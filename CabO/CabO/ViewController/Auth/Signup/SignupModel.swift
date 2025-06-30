//
//  SignupModel.swift
//  CabO
//
//  Created by Octos.
//

import Foundation
import UIKit

// MARK: - Sign Up Screen Sections
enum SignScreenSection: Int {
    case profile = 1, personal, emergency
    
    var title: String {
        switch self {
        case .profile: return "Profile information"
        case .personal: return "Personal information"
        case .emergency: return "Emergency contacts"
        }
    }
    
    func arrCells() -> [SignUpCells] {
        switch self {
        case .profile: return [.role,.fname, .lname, .email, .phone, .pass, .conPass, .checkOne, .btn, .alreadyAccount]
        case .personal:
            if _user!.role == .rider {
                return [ .dob, .gender, .bio, .btn]
            }else{
                return [ .dob, .gender,.homeAddress, .bio, .btn]
            }
            
        case .emergency: return [ .eInfo, .eContact, .addMore, .btn ]
        }
    }
}

// MARK: - SignUpCells ENUM
enum SignUpCells: CaseIterable {
    case role,title, fname, lname, email, phone, pass, conPass, checkOne, dob, gender,homeAddress, bio, fb, twit, insta, btn, eInfo, eContact, addMore, alreadyAccount
    
    var cellId: String {
        switch self {
        case .role: return "roleCell"
        case .gender: return "genderCell"
        case .title: return TitleTVC.identifier
        case .btn: return ButtonTableCell.identifier
        case .bio: return InputCell.textViewIdentifier
        case .eInfo: return "emergencyInfoCell"
        case .eContact: return AddEmergencyContactCell.identifier
        case .addMore: return "addMoreCell"
        case .checkOne: return "tncCell"
        case .alreadyAccount: return "signinCell"
        default: return InputCell.identifier
        }
    }
    
    var cellHeight: CGFloat {
        switch self {
        case .btn: return ButtonTableCell.cellHeight + 10
        case .gender, .role: return UITableView.automaticDimension
        case .bio: return 140 * _widthRatio
        case .eInfo:
            let titleHeight: CGFloat = "Benefits".heightWithConstrainedWidth(width: _screenSize.width - (232 * _widthRatio), font: AppFont.fontWithName(.mediumFont, size: 20 * _fontRatio)) + 24 * _heightRatio
            let info1Height: CGFloat = "You can add up to 3 people to your emergency contacts".heightWithConstrainedWidth(width: _screenSize.width - (232 * _widthRatio), font: AppFont.fontWithName(.regular, size: 12 * _fontRatio)) + 12 * _heightRatio
            let info2Height: CGFloat = "In case of an emergency you can choose to inform them when you raise an alert".heightWithConstrainedWidth(width: _screenSize.width - (232 * _widthRatio), font: AppFont.fontWithName(.regular, size: 12 * _fontRatio)) + 22 * _heightRatio
            let height = titleHeight + info1Height + info2Height
            return max(height, 220 * _heightRatio)
            
        case .eContact: return AddEmergencyContactCell.normalHeight
        case .addMore: return 44 * _widthRatio
        case .checkOne, .alreadyAccount: return UITableView.automaticDimension
        default: return InputCell.normalHeight
        }
    }
    
    var inputTitle: String {
        switch self {
        case .role: return "Role"
        case .fname: return "First name*"
        case .lname: return "Last name*"
        case .email: return "Email address*"
        case .phone: return "Mobile Number*"
        case .pass: return "Password*"
        case .conPass: return "Confirm password*"
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
        case .email: return "Email address"
        case .phone: return "Mobile Number"
        case .pass: return "Password"
        case .conPass: return "Confirm password"
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
//        case .fname, .lname: return UIImage(named: "ic_person")
//        case .email: return UIImage(named: "ic_mail")
//        case .phone: return UIImage(named: "ic_mobile")
//        case .pass, .conPass: return UIImage(named: "ic_password")
//        case .dob: return UIImage(named: "ic_dob")
//        case .gender: return UIImage(named: "ic_select_gender")
//        case .bio: return UIImage(named: "ic_bio")
//        case .fb: return UIImage(named: "ic_fb")
//        case .twit: return UIImage(named: "ic_twit")
//        case .insta: return UIImage(named: "ic_insta")
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
    
    var maxLength: Int {
        switch self {
        case .fname, .lname: return 32
        case .phone: return 10
        case .pass, .conPass: return 24
        default: return 250
        }
    }
    
    var keyboard: UIKeyboardType {
        switch self {
        case .email: return .emailAddress
        case .phone: return .phonePad
        default: return .asciiCapable
        }
    }
    
    var returnKeyType: UIReturnKeyType {
        switch self {
        case .conPass, .dob, .insta: return .done
        default: return .next
        }
    }
    
    var inputAccView: Bool {
        switch self {
        case .phone, .dob, .bio: return true
        default: return false
        }
    }
    
    var capitalCase: UITextAutocapitalizationType {
        switch self {
        case .fname, .lname: return .sentences
        default: return .none
        }
    }
}

//MARK: - SignUp Data
class SignUpData {
    
    var fName: String = ""
    var lname: String = ""
    var email: String = ""
    var phoneNumber: String = ""
    var pass: String = ""
    var conPass: String = ""
    var dob: Date?
    var gender: Gender?
    var bio: String = ""
    var fb: String = ""
    var twitter: String = ""
    var insta: String = ""
    var social_id: String?
    var login_with: String?
    var apple_auth_code: String?
    var isCheckOneSelected: Bool = false
    var arrEmergencyContacts: [EmergencyContactData] = [EmergencyContactData()]
    var role: Role = .rider
    var param: [String: Any] {
//        var param: [String: String] = [:]
        return [:]
    }
    
    func saveDataKeychain(){
        if !fName.isEmpty {
            let _ = KeyChain.save(key: "firstName", data: self.fName.convertToData)
        }
        if !lname.isEmpty {
            let _ = KeyChain.save(key: "lastName", data: self.lname.convertToData)
        }
        if social_id != nil && !social_id!.isEmpty {
            let _ = KeyChain.save(key: "apple_id", data: self.social_id!.convertToData)
        }
        if !email.isEmpty {
            let _ = KeyChain.save(key: "email", data: self.email.convertToData)
        }
    }

    func getKeychainData(completion:((SignUpData?)->Void)){
        if self.getData(keyName: "apple_id") != "" {
            let apple_id = self.getData(keyName: "apple_id")
            
            if apple_id != self.social_id {
                KeyChain.logout()
                completion(nil)
            } else {
                let user = SignUpData()
                user.social_id = apple_id
                user.fName = self.getData(keyName: "firstName")
                user.lname = self.getData(keyName: "lastName")
                user.email = self.getData(keyName: "email")
                completion(user)
            }
        } else {
            completion(nil)
        }
    }

    func getData(keyName:String) -> String{
        var value = ""
        if let receivedData = KeyChain.load(key: keyName) {
            value = receivedData.decodeData
        }
        return value
    }
    
    func isValidData(_ screenType: SignScreenSection) -> (Bool, String) {
        if screenType == .profile {
            if fName.isEmpty {
                return (false, "Please enter your first name")
            }
            else if !fName.isValidName() {
                return (false, "Please enter a valid first name")
            }
            else if lname.isEmpty {
                return (false, "Please enter your last name")
            }
            else if !lname.isValidName() {
                return (false, "Please enter a valid last name")
            }
            else if email.isEmpty {
                return (false, "Please enter your email address")
            }
            else if !email.isValidEmailAddress() {
                return (false, "Please enter a valid email address")
            }
            else if phoneNumber.isEmpty {
                return (false, "Please enter your Mobile Number")
            }
            else if !phoneNumber.isValidContact() {
                return (false, "Please enter a valid Mobile Number")
            }
            if login_with == nil {
                if pass.isEmpty {
                    return (false, "Please enter a password")
                }
                else if !pass.isPasswordValid() {
                    return (false, "The password must be at least 8 characters long and include a number, lowercase letter, uppercase letter and special character (Any from @!#$%^&+=)")
                }
                else if conPass.isEmpty {
                    return (false, "Please enter confirm password")
                }
                else if conPass != pass {
                    return (false, "Confirm password does not match")
                }
            }
            if !isCheckOneSelected {
                return (false, "Please accept the terms & conditions and privacy policy")
            }
        } else if screenType == .personal {
            if dob == nil {
                return (false, "Please select your date of birth")
            } else if gender == nil {
                return (false, "Please select your gender")
            } else if !fb.isEmpty && !fb.contains(find: "www.facebook.com/"){
                return (false, "Please enter valid facebook url")
            } else if !twitter.isEmpty && !twitter.contains(find: "www.x.com/"){
                return (false, "Please enter valid x url")
            } else if !insta.isEmpty && !insta.contains(find: "www.instagram.com/"){
                return (false, "Please enter valid instagram url")
            }
        }
        return (true, "")
    }
    
    func getParamDict(_ screenType: SignScreenSection) -> [String: Any] {
        if screenType == .profile {
            var param: [String:Any] = [:]
            param["first_name"] = fName
            param["last_name"] = lname
            param["email"] = email
            param["mobile"] = phoneNumber.removeSpace()
            param["password"] = pass
            param["role"] = role.Value
            if let social_id {
                param["social_id"] = social_id
            }
            if let login_with {
                param["login_with"] = login_with
            }
            if let apple_auth_code {
                param["apple_auth_code"] = apple_auth_code
            }
            return param
        } else if screenType == .personal {
            var param: [String: Any] = [:]
            param["type"] = "profile"
            param["date_of_birth"] = Date.localDateString(from: dob!.removeTimeFromDate(), format: DateFormat.serverDateFormat)
            param["gender"] = gender!.title.lowercased()
            param["something_about_you"] = bio
            if _user?.role == .driver {
                param["address"] = bio
            }
//            param["facebook_url"] = fb
//            param["twitter_url"] = twitter
//            param["instagram_url"] = insta
            return param
        }
        return [:]
    }
    
    func getValue(_ cellType: SignUpCells) -> String {
        switch cellType {
        case .fname: return fName
        case .lname: return lname
        case .email: return email
        case .phone: return phoneNumber.formatPhoneNumber()
        case .pass : return pass
        case .conPass: return conPass
        case .dob: return Date.localDateString(from: dob, format: DateFormat.format_MMMddyyyy)
        case .gender: return gender?.title ?? ""
        case .bio: return bio
        case .fb: return fb
        case .twit: return twitter
        case .insta: return insta
        default: return ""
        }
    }
    
    func setValue(_ str: String, cellType: SignUpCells) {
        switch cellType {
        case .fname:
            fName = str
        case .lname:
            lname = str
        case .email:
            email = str
        case .phone:
            phoneNumber = str.removeSpace()
        case .pass:
            pass = str
        case .conPass:
            conPass = str
        case .bio:
            bio = str
        case .fb:
            fb = str
        case .twit:
            twitter = str
        case .insta:
            insta = str
        default: break
        }
    }
}
