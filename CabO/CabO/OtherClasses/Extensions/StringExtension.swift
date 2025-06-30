import Foundation
import PhoneNumberKit
import UIKit
import CoreTelephony

// MARK: - Localization
extension String {
    
    func localizedString() -> String {
        let str = NSLocalizedString(self, comment: "")
        if str == self {
            return NSLocalizedString(self, tableName: "Localize", comment: "")
        } else {
            return str
        }
    }
    
    func localizeWithFormat(arguments: [CVarArg]) -> String {
        return String(format: self.localizedString(), locale: Locale(identifier: Setting.selectedLanguage.localIdent), arguments: arguments)
    }
}

// MARK: - Registration Validation
extension String {
    
    func getBooleanValue() -> Bool {
        let str = self.lowercased()
        if let num = str.integerValue as? NSNumber {
            return num.boolValue
        } else if let str = str as? NSString {
            if str == "yes" {
                return true
            } else if str == "no" {
                return false
            } else {
                return str.boolValue
            }
        }
        return false
    }
    
    var isNumber : Bool {
        get{
            return !self.isEmpty && self.rangeOfCharacter(from: NSCharacterSet.decimalDigits.inverted) == nil
        }
    }
    
    var isNumeric: Bool {
        return CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: self))
    }
    
    static func validateStringValue(str:String?) -> Bool{
        var strNew = ""
        if str != nil{
            strNew = str!.trimWhiteSpace(newline: true)
        }
        if str == nil || strNew == "" || strNew.count == 0  {  return true  }
        else  {  return false  }
    }
    
    static func validatePassword(str:String?) -> Bool{
        if str == nil || str == "" || str!.count < 6  {  return true  }
        else  {  return false  }
    }
    
    func isValidUsername() -> Bool {
        let usernameRegex = "[0-9a-zA-Z]{3,15}"
        return NSPredicate(format: "SELF MATCHES %@", usernameRegex).evaluate(with: self)
    }
    
    func isOTPValid() -> Bool {
        let otpRegex = "[0-9]{4,6}"
        return NSPredicate(format: "SELF MATCHES %@", otpRegex).evaluate(with: self)
    }
    
    func isValidName() -> Bool{
        let nameRegex = "^[0-9a-zA-Z]{2,32}$"
        return NSPredicate(format: "SELF MATCHES %@", nameRegex).evaluate(with: self.trimmedString().removeSpace())
    }
    
    func isValidFullName() -> Bool{
        let nameRegex = "^[0-9a-zA-Z]{2,64}$"
        return NSPredicate(format: "SELF MATCHES %@", nameRegex).evaluate(with: self.trimmedString().removeSpace())
    }
    
    func isValidPanNumber() -> Bool {
        let panRegex = "^[A-Z]{5}[0-9]{4}[A-Z]{1}$"
        return NSPredicate(format: "SELF MATCHES %@", panRegex).evaluate(with: self)
    }
    
    func isValidAadharNumber() -> Bool {
        let aadharRegex = "^[2-9]{1}[0-9]{11}$"
        return NSPredicate(format: "SELF MATCHES %@", aadharRegex).evaluate(with: self)
    }
    
    func isPasswordValid() -> Bool {
        // least one uppercase,
        // least one digit
        // least one lowercase
        // least one symbol
        // min 8 characters total
        let passwordRegex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[@$!%*?&])[A-Za-z\\d@$!%*?&]{8,24}$"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: self)
    }
    
    func isValidEmailAddress() -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}"
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: self)
    }

    func isValidContact() -> Bool{
        let contactRegEx = "^[0-9]{10,10}$"
        let contactTest = NSPredicate(format:"SELF MATCHES %@", contactRegEx)
        return contactTest.evaluate(with: self)
    }
        
    func isValidBankAccNo() -> Bool{
        let accountRegEx = "^[0-9]{9,18}$"
        let accountTest = NSPredicate(format:"SELF MATCHES %@", accountRegEx)
        return accountTest.evaluate(with: self)
    }
    
    func isValidCreditCardNo() -> Bool{
        let accountRegEx = "^[0-9]{13,19}$"
        let accountTest = NSPredicate(format:"SELF MATCHES %@", accountRegEx)
        return accountTest.evaluate(with: self)
    }
    
    func isValidUrlUsingComponents() -> Bool {
        guard let urlComponents = URLComponents(string: self),
              let scheme = urlComponents.scheme,
              let host = urlComponents.host else {
            return false
        }
        return (scheme == "http" || scheme == "https") && !host.isEmpty
    }
    
    func isValidIFSC() -> Bool {
        let ifscRegex = "^[A-Z]{4}0[A-Z0-9]{6}$"
        return NSPredicate(format: "SELF MATCHES %@", ifscRegex).evaluate(with: self)
    }
    
    func isValidTeamName() -> Bool {
        let teamRegEx = "[0-9a-zA-Z]+"
        let teamTest = NSPredicate(format:"SELF MATCHES %@", teamRegEx)
        return teamTest.evaluate(with: self)
    }
//    
//    func isValidMobileNumber() -> Bool {
//        let numkit = PhoneNumberKit()
//        do {
//            _ = try numkit.parse(self, ignoreType: false)
//            return true
//        } catch {
//            return false
//        }
//    }
    
    func isValidPin() -> Bool {
        let pinRegEx = "^[1-9]{1}[0-9]{5}$"
        let pinTest = NSPredicate(format:"SELF MATCHES %@", pinRegEx)
        return pinTest.evaluate(with: self)
    }
//    
//    func getMobileString() -> String {
//        let numkit = PhoneNumberKit()
//        do {
//            let mobile = try numkit.parse(self, ignoreType: true)
//            return "\(mobile.nationalNumber)"//adjustedNationalNumber()
//        } catch {
//            return ""
//        }
//    }
    
//    private func getFormattedMobileString() -> String {
//        return PartialFormatter().formatPartial(self)
//    }
    var currencyString:String{
        get{
            return  "\(_appDelegator.config.currencySign!)\(String(format: "%.2f", self))"
        }
    }
    func formatCreditCardNumber() -> String {
        let trimmedString = self.replacingOccurrences(of: " ", with: "")
        var formattedString = ""
        var index = 0
        
        for character in trimmedString {
            if index > 0 && index % 4 == 0 {
                formattedString.append(" ") // Add a space after every 4 characters
            }
            formattedString.append(character)
            index += 1
        }
        
        return formattedString
    }

    func formatPhoneNumber() -> String {
        let cleanPhoneNumber = self.trimmedString().removeSpace()
        
        var result = ""
        var index = cleanPhoneNumber.startIndex
        
        // Format Mobile Number as XXX XXX XXXX
        let format = "XXX XXX XXXX"
        
        for ch in format {
            if index == cleanPhoneNumber.endIndex {
                break
            }
            
            if ch == "X" {
                result.append(cleanPhoneNumber[index])
                index = cleanPhoneNumber.index(after: index)
            } else {
                result.append(ch)
            }
        }
        
        // Append remaining digits, if any
        while index < cleanPhoneNumber.endIndex {
            result.append(cleanPhoneNumber[index])
            index = cleanPhoneNumber.index(after: index)
        }
        
        return result
    }
    
    func formateIBanNumber() -> String {
        let str = self.removeSpace().uppercased()
        var formatedStr = ""
        for (idx,char) in str.enumerated() {
            if idx % 4 == 0 {
                formatedStr.append(" ")
            }
            formatedStr.append(char)
        }
        return formatedStr.trimWhiteSpace()
    }
    
    func isValidBicNumber() -> Bool {
        let bicRegEx = "^[a-zA-Z]{6}\\w{2}(\\w{3})?$"
        let bicTest = NSPredicate(format:"SELF MATCHES %@", bicRegEx)
        return bicTest.evaluate(with: self)
    }
    
    func removeIBanFormate() -> String {
        return self.removeSpace()
    }
    
    func getyoutubeId() -> String? {
        do {
//            let regex = try NSRegularExpression(pattern: "(?<=v(=|/))([-a-zA-Z0-9_]+)|(?<=youtu.be/)([-a-zA-Z0-9_]+)", options: NSRegularExpression.Options.caseInsensitive)
            let regex = try NSRegularExpression(pattern: "((?<=(v|V)/)|(?<=be/)|(?<=(\\?|\\&)v=)|(?<=embed/))([\\w-]++)", options: NSRegularExpression.Options.caseInsensitive)
            let res = regex.firstMatch(in: self, options: NSRegularExpression.MatchingOptions.reportProgress, range: NSMakeRange(0, self.lengthOfBytes(using: String.Encoding.utf8)))
            if let result = res {
                let youTubeID = (self as NSString).substring(with: result.range)
                return youTubeID
            } else {
                return nil
            }
        } catch {
            return nil
        }
    }
    
    func shortName() -> String {
        guard !self.isEmpty else { return "" }
        var shortedName = ""
        for component in self.components(separatedBy: .whitespaces) {
            let firstChar = component.first
            shortedName = "\(shortedName)\(firstChar!)"
        }
        return shortedName
    }
    
    var convertToData:Data{
        return Data(self.utf8)
    }
}

// MARK: - Character check
extension String {
    
    func trimmedString() -> String {
        return self.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
    }
    
    func contains(find: String) -> Bool{
        return self.range(of: find, options: String.CompareOptions.caseInsensitive) != nil
    }
    
    func trimWhiteSpace(newline: Bool = false) -> String {
        if newline {
            return self.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
        } else {
            return self.trimmingCharacters(in: NSCharacterSet.whitespaces)
        }
    }
    
    func capitalizingFirstLetter() -> String {
        return prefix(1).capitalized + dropFirst()
    }
    
    func removeSpace() -> String {
        let okayChars : Set<Character> = Set("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890")
        return String(self.filter {okayChars.contains($0) })
    }
    
    var htmlDecoded: String {
        let decoded = try? NSAttributedString(data: Data(utf8), options: [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ], documentAttributes: nil).string
        return decoded ?? self
    }
    
    func removeHTMLTag() -> NSAttributedString? {
        guard let data = data(using: .utf8) else { return nil }
        var temp = NSAttributedString()
        do
        {
            temp = try  NSAttributedString(data: data, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html, NSAttributedString.DocumentReadingOptionKey.characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        }catch{}
        return temp
    }
}

extension Double {
    var stringValues: String {
        get {
            return String(describing: self)
        }
    }
    
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
    
    var kilometers: Double {
        return self * 1.60934 // 1 mile = 1.60934 kilometers
    }
    var currencyString:String{
        get{
            return  "\(_appDelegator.config.currencySign!)\(String(format: "%.2f", self))"
        }
    }
}

extension Int {
    
    var kilometers: Double {
        return (Double(self) * 1.60934).rounded(toPlaces: 2) // 1 mile = 1.60934 kilometers
    }
    
    var miles: Double {
        return (Double(self) / 1.60934).rounded(toPlaces: 2) // Convert kilometers to miles
    }
}

// MARK: - Layout
extension String {
    
    var length: Int {
        return (self as NSString).length
    }
    
    func isEqual(str: String, isCaseSensitive: Bool = true) -> Bool {
        if isCaseSensitive {
            return self.compare(str) == ComparisonResult.orderedSame
        } else {
            return self.caseInsensitiveCompare(str) == .orderedSame
        }
    }
    
    func heightWithConstrainedWidth(width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: [NSStringDrawingOptions.usesLineFragmentOrigin], attributes: [NSAttributedString.Key.font: font], context: nil)
        return boundingBox.height
    }
    
    func singleLineHeight(font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: [NSStringDrawingOptions.usesLineFragmentOrigin], attributes: [NSAttributedString.Key.font: font], context: nil)
        return boundingBox.height
    }
    
    func WidthWithNoConstrainedHeight(font: UIFont) -> CGFloat {
        let width = CGFloat.greatestFiniteMagnitude
        let constraintRect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return boundingBox.width
    }
    
    func stringSize(with font: UIFont) -> CGSize {
        let width = CGFloat.greatestFiniteMagnitude
        let constraintRect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return boundingBox.size
    }
    
    func getStringWithLineSpace(_ height: CGFloat, font: UIFont = AppFont.fontWithName(FontType.regular, size: 13 * _fontRatio), allignment: NSTextAlignment = .natural) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.minimumLineHeight = height
        paragraphStyle.maximumLineHeight = height
        paragraphStyle.alignment = allignment
        
        let attributedString = NSMutableAttributedString(string: self)
        
        // Line spacing attribute
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
        attributedString.addAttribute(NSAttributedString.Key.font, value: font, range: NSMakeRange(0, attributedString.length))
        return attributedString
    }
}

// MARK: - For MRZ Data Processing
extension String {
    
    func replace(target: String, with: String) -> String {
        return self.replacingOccurrences(of: target, with: with, options: .literal, range: nil)
    }
    
    func toUInt() -> UInt? {
        let scanner = Scanner(string: self)
        var u: UInt64 = 0
        if scanner.scanUnsignedLongLong(&u)  && scanner.isAtEnd {
            return UInt(u)
        }
        return nil
    }
    
    func toNumber() -> String {
        return self
            .replace(target: "O", with: "0")
            .replace(target: "Q", with: "0")
            .replace(target: "U", with: "0")
            .replace(target: "D", with: "0")
            .replace(target: "I", with: "1")
            .replace(target: "Z", with: "2")
            .replace(target: "A", with: "4")
            .replace(target: "S", with: "5")
            .replace(target: "S", with: "8")
            .replace(target: "H", with: "4")
    }
    
    func toString() -> String{
        return self
            .replace(target: "0", with: "O")
            .replace(target: "0", with: "Q")
            .replace(target: "0", with: "U")
            .replace(target: "0", with: "D")
            .replace(target: "1", with: "I")
            .replace(target: "2", with: "Z")
            .replace(target: "4", with: "A")
            .replace(target: "5", with: "S")
            .replace(target: "8", with: "S")
    }
    
    func subString(_ from: Int, to: Int) -> String {
        let f: String.Index = self.index(self.startIndex, offsetBy: from)
        let t: String.Index = self.index(self.startIndex, offsetBy: to + 1)
        let range = f..<t
        return String(self[range])
    }
    
    func base64Encoded() -> String? {
        return data(using: .utf8)?.base64EncodedString()
    }

    func base64Decoded() -> String? {
        guard let data = Data(base64Encoded: self) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}

extension StringProtocol {
    var masked: String {
        return String(repeating: "X", count: Swift.max(0, count - 4)) + suffix(4)
    }
}
