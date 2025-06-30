//
//  BankDetailsModel.swift
//  CabO
//
//  Created by Octos.
//

import Foundation
import UIKit

// MARK: - StripeDetailCell
class StripeDetailCell: ConstrainedTableViewCell {
    /// Outlets
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var desc: UILabel!
}

// MARK: - StripeDetails
class StripeDetails {
    var stripeId: String!
    var accountHolderName: String!
    var business_name: String!
    var accountNo: String!
    var routingNo: String!
    var email: String!
    var isActive: Bool!
    var paymentId: Int!
    var status: String!
    
    init(_ dict: NSDictionary) {
        stripeId = dict.getStringValue(key: "stripe_user_account_id")
        accountHolderName = dict.getStringValue(key: "accountholder")
        business_name = dict.getStringValue(key: "business_name")
        accountNo = dict.getStringValue(key: "accountno")
        routingNo = dict.getStringValue(key: "routingno")
        email = dict.getStringValue(key: "email")
        status = dict.getStringValue(key: "status")
        isActive = dict.getBooleanValue(key: "is_active")
        paymentId = dict.getIntValue(key: "paymentid")
    }
    
    func getValue(_ cellType: StripeDetailsCellType) -> String {
        switch cellType {
        case .name: return accountHolderName
        case .business: return business_name
        case .email: return email
        case .accNo: return accountNo
        case .routingNo: return routingNo
        case .status: return status
        }
    }
}

// MARK: - StripeDetailsCellType
enum StripeDetailsCellType: CaseIterable {
    case name, business, email, accNo, routingNo, status
    
    var title: String {
        switch self {
        case .name:
            return "Name"
        case .business:
            return "Business Name"
        case .email:
            return "Email"
        case .accNo:
            return "Account Number (Last 4 Digits)"
        case .routingNo:
            return "Routing Number"
        case .status:
            return "Status"
        }
    }
}
