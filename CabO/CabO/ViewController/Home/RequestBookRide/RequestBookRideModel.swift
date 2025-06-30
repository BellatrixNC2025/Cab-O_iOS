//
//  RequestBookRideModel.swift
//  CabO
//
//  Created by Octos.
//

import Foundation
import UIKit

// MARK: - RequestBookRide CellType
enum RequestBookRideCellType {
    case seatRequired, promoCode, fareDetails, cardDetail, message
    
    var cellId: String {
        switch self {
        case .seatRequired: return "seatRequiredCell"
        case .promoCode: return "promoCodeCell"
        case .fareDetails: return "fareDetails"
        case .cardDetail: return "cardDetails"
        case .message: return InputCell.textViewIdentifier
        }
    }
    
    var cellHeight: CGFloat {
        switch self {
        case .message: return InputCell.textViewHeight
        default: return UITableView.automaticDimension
        }
    }
}

class RequestBookRideModel {
    
    var rideDetails: RideDetails!
    var seatsReq: Int! = 1
    var cardId: Int!
    var msgForDriver: String = ""
    var couponId: Int?
    
    var bookingFee: Double! = 0.0
    var price: Double! = 0.0
    var discountAmount: Double! = 0.0
    var totalPrice: Double! = 0.0
    var finalPrice: Double! = 0.0
    
    func updatePrice(_ dict: NSDictionary) {
        bookingFee = dict.getDoubleValue(key: "booking_fees")
        price = dict.getDoubleValue(key: "price")
        discountAmount = dict.getDoubleValue(key: "promo_code_price")
        totalPrice = dict.getDoubleValue(key: "total_price")
    }
    
    func applyPromo(_ dict: NSDictionary) {
        couponId = dict.getIntValue(key: "coupon_id")
        discountAmount = dict.getDoubleValue(key: "discount_amount")
        finalPrice = dict.getDoubleValue(key: "final_price")
    }
    
    var param: [String: Any] {
        var param: [String: Any] = [:]
        param["no_of_seat"] = seatsReq
        param["from_stopover_id"] = rideDetails.fromStopId
        param["to_stopover_id"] = rideDetails.toStopId
        param["amount"] = couponId != nil ? finalPrice : totalPrice
        param["booking_fees"] = bookingFee
        param["msg_for_driver"] = msgForDriver
        param["coupon_id"] = couponId
        param["coupon_price"] = discountAmount
        param.merge(with: Setting.deviceInfo)
        return param
    }
}
