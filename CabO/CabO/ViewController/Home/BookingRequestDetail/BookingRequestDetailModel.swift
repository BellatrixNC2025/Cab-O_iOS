//
//  BookingRequestDetailModel.swift
//  CabO
//
//  Created by Octos.
//

import Foundation
import UIKit

// MARK: - BookingRequestDetail CellType
enum BookingRequestDetailCellType {
    case trip, seat, msg, transaction, driver, reject, cancel, review
    
    var cellId: String {
        switch self {
        case .trip: return "tripInfoCell"
        case .transaction: return "transactionCell"
        case .driver: return "driverDetailCell"
        case .reject, .cancel: return "rejectCell"
        case .review: return RideReviewTVC.identifier
        default: return "tripdetailCell"
        }
    }
    
    var title: String {
        switch self {
        case .seat: return "Seat required"
        case .msg: return "Message"
        case .transaction: return "Transaction details"
        default: return ""
        }
    }
    
    var img: UIImage? {
        switch self {
        case .seat: return UIImage(named: "ic_seat")?.withTintColor(AppColor.primaryText)
        case .msg: return UIImage(systemName: "message")
        case .transaction: return UIImage(named: "ic_dollar")?.withTintColor(AppColor.primaryText)
        default: return nil
        }
    }
}

// MARK: - BookingRequestDetail Model
class BookingRequestDetailModel {
    
    var bookRideId: Int!
    var requestId: Int!
    var rideId: Int!
    var riderId: Int!
    var driver: DriverModel?
    var image: String!
    var firstName: String!
    var fullName: String!
    var mobile: String!
    var fromDate: Date!
    var fromTime: Date!
    var fromLoc: String!
    var toLoc: String!
    var seatReq: Int!
    var msg: String!
    var price: Double!
    var userTotalReviews: Int!
    var userAvgRating: Double!
    var userId: Int!
    var status: RideStatus!
    var isInvited: Bool!
    var isOtherReason: Bool!
    var rejectReason: String!
    var rejectMessage: String!
    var isReviewGiven: Bool!
    var review: ReviewModel?
    var verificationCode: String!
    var fromTimeZoneId: String!
    var fromTimeZoneName: String!
    var transactionId: String!
    
    var reviewCountString: String {
        return "\(userTotalReviews!) \(userTotalReviews == 1 ? "Review" : "Reviews")"
    }
    
    var dateTimeStr: String {
           let str = Date.formattedString(from: fromDate, format: DateFormat.format_MMMMddyyyy) + " " + Date.formattedString(from: fromTime, format: DateFormat.format_HHmma)
        if let fromTimeZoneName = fromTimeZoneName, !fromTimeZoneName.shortName().isEmpty {
            return str + " (\(fromTimeZoneName.shortName()))"
        }
        return str
    }
    
    init(_ dict: NSDictionary) {
        bookRideId = dict.getIntValue(key: "book_ride_id")
        rideId = dict.getIntValue(key: "ride_id")
        riderId = dict.getIntValue(key: "user_id")
        image = dict.getStringValue(key: "image")
        firstName = dict.getStringValue(key: "first_name")
        fullName = dict.getStringValue(key: "user_name")
        mobile = dict.getStringValue(key: "mobile")
        fromTimeZoneId = dict.getStringValue(key: "from_time_zone_id")
        fromTimeZoneName = dict.getStringValue(key: "from_time_zone_name")
        fromDate = Date.dateFromServerFormat(from: dict.getStringValue(key: "from_date"), format: DateFormat.serverDateTimeFormat)
        fromTime = Date.dateFromServerFormat(from: dict.getStringValue(key: "from_time"), format: DateFormat.serverTimeFormat)
        fromLoc = dict.getStringValue(key: "from_location")
        toLoc = dict.getStringValue(key: "to_location")
        seatReq = dict.getIntValue(key: "no_of_seat")
        msg = dict.getStringValue(key: "msg_for_driver")
        price = dict.getDoubleValue(key: "price")
        userTotalReviews = dict.getIntValue(key: "total_review")
        userId = dict.getIntValue(key: "user_id")
        userAvgRating = dict.getDoubleValue(key: "average_rating").rounded(toPlaces: 1)
        isOtherReason = dict.getBooleanValue(key: "is_other")
        rejectReason = dict.getStringValue(key: "cancel_reject_reason")
        rejectMessage = dict.getStringValue(key: "cancel_reject_message")
        isReviewGiven = dict.getBooleanValue(key: "is_rating_given")
        verificationCode = dict.getStringValue(key: "verification_code")
        transactionId = dict.getStringValue(key: "txtId")
        
        status = RideStatus(rawValue: dict.getStringValue(key: "status"))
        if let driv = dict["driver_detail"] as? NSDictionary {
            driver = DriverModel(driv)
        }
        
        if let rev = dict["own_rating"] as? NSDictionary {
            review = ReviewModel(rev)
        }
    }
    
    init(invite dict: NSDictionary) {
        requestId = dict.getIntValue(key: "request_id")
        firstName = dict.getStringValue(key: "first_name")
        fullName = dict.getStringValue(key: "user_name")
        userId = dict.getIntValue(key: "user_id")
//        fromTimeZoneId = dict.getStringValue(key: "from_time_zone_id")
//        fromTimeZoneName = dict.getStringValue(key: "from_time_zone_name")
        fromDate = Date.dateFromServerFormat(from: dict.getStringValue(key: "date"), format: DateFormat.serverDateTimeFormat)
        fromLoc = dict.getStringValue(key: "from_location")
        toLoc = dict.getStringValue(key: "to_location")
        seatReq = dict.getIntValue(key: "seats")
        msg = dict.getStringValue(key: "ride_description")
        price = dict.getDoubleValue(key: "price")
        status = RideStatus(rawValue: dict.getStringValue(key: "status"))
        isInvited = dict.getBooleanValue(key: "is_invited")
        if let driv = dict["ride_driver"] as? NSDictionary {
            driver = DriverModel(driv)
        }
    }
    
    init(_ data: BookingReqListModel) {
        bookRideId = data.bookRideId
        requestId = data.requestId
        image = data.img
        seatReq = data.seats
        fullName = data.name
        mobile = data.mobile
        verificationCode = data.verificationCode
    }
}
