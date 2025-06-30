//
//  PaymentDetailModel.swift
//  CabO
//
//  Created by Octos.
//

import Foundation
import UIKit

// MARK: - RideUserPaymentDetails Cell
class RideUserPaymentDetailsCell: ConstrainedTableViewCell {
    
    /// Outlets
    @IBOutlet weak var imgVeiew: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblTip: UILabel!
    @IBOutlet weak var btnCancelInfo: UIButton!
    
    /// Variables
    var info_cancel_tap: ((AnyObject) -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func btn_cancel_info_tap(_ sender: UIButton) {
        info_cancel_tap?(sender)
    }
}

// MARK: - RideUserPaymentDetails Model
class RideUserPaymentDetails {
    
    var userName: String!
    var userImage: String!
    var price: Double!
    var refundAmount: Double!
    var tip: Double!
    var seatCount: Int!
    var isRefund: Bool = false
    
    init(_ dict: NSDictionary) {
        userName = dict.getStringValue(key: "user_name")
        userImage = dict.getStringValue(key: "image")
        price = dict.getDoubleValue(key: "price").rounded(toPlaces: 2)
        refundAmount = dict.getDoubleValue(key: "refund_amount").rounded(toPlaces: 2)
        tip = dict.getDoubleValue(key: "tip_price").rounded(toPlaces: 2)
        seatCount = dict.getIntValue(key: "no_of_seat")
        isRefund = dict.getBooleanValue(key: "is_refund")
    }
    
    init(name: String, img: String, price: Double, tip: Double, seat: Int) {
        self.userName = name
        self.userImage = img
        self.price = price
        self.tip = tip
        self.seatCount = seat
    }
    
}
