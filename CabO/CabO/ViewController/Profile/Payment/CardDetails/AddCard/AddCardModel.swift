//
//  AddCardModel.swift
//  CabO
//
//  Created by Octos.
//

import Foundation
import UIKit

// MARK: - AddCardCellType
enum AddCardCellType: CaseIterable {
    case header, cardNumber, cardHolderName, expiry, cvv, setDefault, stripe, btn
    
    var cellId: String {
        switch self {
        case .header: return "headerCell"
        case .setDefault: return "setAsDefault"
        case .stripe: return "stripe"
        case .btn: return ButtonTableCell.identifier
        default: return InputCell.identifier
        }
    }
    
    var cellHeight: CGFloat {
        switch self {
        case .header: return DeviceType.iPhone ? 175 * _heightRatio : 250 * _heightRatio
        case .setDefault: return 44 * _widthRatio
        case .stripe: return UITableView.automaticDimension
        case .btn: return ButtonTableCell.cellHeight + 24
        default: return InputCell.normalHeight
        }
    }
    
    var title: String {
        switch self {
        case .cardNumber: return "Card number"
        case .cardHolderName: return "Card holder name"
        case .expiry: return "Expiration date (MM/YY)"
        case .cvv: return "CVV"
        default: return ""
        }
    }
    
    var placeholder: String {
        switch self {
        case .cardNumber: return "Card number"
        case .cardHolderName: return "Card holder name"
        case .expiry: return "Expiration date"
        case .cvv: return "CVV"
        default: return ""
        }
    }
    
    var keyboard: UIKeyboardType {
        switch self {
        case .cardHolderName: return .asciiCapable
        default: return .phonePad
        }
    }
    
    var returnKeyType: UIReturnKeyType {
        switch self {
        case .cvv: return .done
        default: return .next
        }
    }
    
    var inputAccView: Bool {
        switch self {
        case .cardHolderName: return false
        default: return true
        }
    }
    
    var maxLength: Int {
        switch self {
        case .cardNumber: return 19
        case .cardHolderName: return 32
        case .expiry: return 4
        case .cvv: return 4
        default: return 5
        }
    }
}

// MARK: - AddCardData
class AddCardData {
    
    var cardNumber: String = ""
    var cardHolderName: String = ""
    var expiryDate: String = ""
    var cvv: String = ""
    var isDefault: Bool = true
    
    var param: [String: Any] {
        var param: [String: Any] = [:]
        param["card_number"] = cardNumber
        param["expiry_month"] = expiryDate.prefix(2)
        param["expiry_year"] = expiryDate.suffix(2)
        param["cvv"] = cvv
        return param
    }
    
    func isValid() -> (Bool, String) {
        if cardNumber.isEmpty {
            return (false, "Please enter card number")
        }
        else if !cardNumber.isValidCreditCardNo() {
            return (false, "Please enter valid card number")
        }
        else if cardHolderName.isEmpty {
            return (false, "Please enter card holder name")
        }
        else if !cardHolderName.isValidName() {
            return (false, "Please enter valid card holder name")
        }
        else if expiryDate.isEmpty {
            return (false, "Please enter card expiry date")
        }
        else if expiryDate.count != 5 {
            return (false, "Please enter valid card expiry date")
        }
        else if String(expiryDate.prefix(2)).integerValue! > 12 {
            return (false, "Please enter valid card expiry month")
        }
        else if cvv.isEmpty {
            return (false, "Please enter CVV number of the card")
        }
        else if cvv.count < 3 {
            return (false, "Please enter valid CVV number of the card")
        }
        return (true, "")
    }
    
    func getValue(_ cellType: AddCardCellType) -> String {
        switch cellType {
        case .cardNumber: return cardNumber.formatCreditCardNumber()
            
        case .cardHolderName: return cardHolderName
        case .expiry:
            var expStr: String = ""
            if expiryDate.count < 3 || expiryDate.last == "/"{
                if expiryDate.contains("/"), let indx = expiryDate.firstIndex(of: "/") {
                    expiryDate.remove(at: indx)
                }
                expStr = expiryDate
            } else {
                if !expiryDate.contains("/") {
                    expiryDate.insert("/", at: String.Index(utf16Offset: 2, in: expiryDate))
                }
                expStr = expiryDate
            }
            return expStr
        case .cvv: return cvv
        default: return ""
        }
    }
    
    func setValue(_ str: String, _ cellType: AddCardCellType) {
        switch cellType {
        case .cardNumber: cardNumber = str.removeSpace()
        case .cardHolderName: cardHolderName = str
        case .expiry: expiryDate = str
        case .cvv: cvv = str
        default: break
        }
    }
}

// MARK: - AddCardCell
class AddCardCell: ConstrainedTableViewCell {
    
    /// Outlets
    @IBOutlet weak var btnDefault: TintButton!
    
    /// Variables
    var action_default: (() -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    /// Set Default
    @IBAction func btnDefaultTap(_ sender: UIButton) {
        action_default?()
    }
}
