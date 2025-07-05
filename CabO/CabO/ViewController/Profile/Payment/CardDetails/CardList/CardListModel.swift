//
//  CardListModel.swift
//  CabO
//
//  Created by Octos.
//

import Foundation
import UIKit

// MARK: - CardListScreenType
enum CardListScreenType {
    case list, booking, tip, subscription
    
    var buttonTitle: String {
        switch self {
        case .list: return "Add card"
        case .booking: return "Book ride"
        case .tip: return "Pay"
        case .subscription: return "Subscribe"
        }
    }
}

// MARK: - CardListModel
class CardListModel: Equatable {
    static func == (lhs: CardListModel, rhs: CardListModel) -> Bool {
        return lhs.cardId == rhs.cardId
    }
    
    
    var id: String!
    var cardId: String!
    var type: CardType!
    var typeName: String!
    var expMonth: Int!
    var expYear: Int!
    var last4Digit: String!
    var holderName: String!
    var isDefault: Bool!
    
    init(_ dict: NSDictionary) {
        id = dict.getStringValue(key: "id")
        cardId = dict.getStringValue(key: "card_id")
        typeName = dict.getStringValue(key: "brand")
        type = CardType(dict.getStringValue(key: "brand").lowercased().removeSpace())
        expMonth = dict.getIntValue(key: "exp_month")
        expYear = dict.getIntValue(key: "exp_year")
        last4Digit = dict.getStringValue(key: "last4")
        holderName = dict.getStringValue(key: "name")
        isDefault = dict.getBooleanValue(key: "is_default")
    }
    
    var isCardExpired: Bool {
        let currentDate = Date()
        let calendar = Calendar.current
        
        let currentYear = calendar.component(.year, from: currentDate)
        let currentMonth = calendar.component(.month, from: currentDate)
        if expYear < currentYear {
            return true
        } else if expYear == currentYear && expMonth < currentMonth {
            return true
        } else {
            return false
        }
    }
}

// MARK: - CardListCell
class CardListCell: ConstrainedTableViewCell {
    
    /// Outlets
    @IBOutlet weak var lblCardType: UILabel!
    @IBOutlet weak var buttonIsDefault: UIButton!
    @IBOutlet weak var labelCardNumber: UILabel!
    @IBOutlet weak var labelCardHolerName: UILabel!
    @IBOutlet weak var labelExpiryDate: UILabel!
//    @IBOutlet weak var imgCardType: UIImageView!
    @IBOutlet weak var btnDelete: UIButton!
    
    /// Variables
    var action_updateCard: (() -> ())?
    var action_deleteCard: (() -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func prepareUI(_ card: CardListModel, type: CardListScreenType,_ isSelected: Bool = false) {
        if type != .list {
            buttonIsDefault.isSelected = isSelected
        } else {
            buttonIsDefault.isSelected = card.isDefault
        }
        lblCardType.text = card.typeName
        labelCardNumber.text = card.last4Digit
        labelCardHolerName.text = card.holderName
        labelExpiryDate.text = card.expMonth.stringValue + "/" + card.expYear.stringValue.suffix(2)
        btnDelete.isHidden = type != .list
    }
    
    @IBAction func actoin_buttonDefaultCardTap(_ sender: UIButton) {
        action_updateCard?()
    }
    
    @IBAction func action_buttonDeleteTap(_ sender: UIButton) {
        action_deleteCard?()
    }
}
