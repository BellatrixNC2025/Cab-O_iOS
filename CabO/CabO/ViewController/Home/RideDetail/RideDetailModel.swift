//
//  RideDetailModel.swift
//  CabO
//
//  Created by Octos.
//

import Foundation
import UIKit

// MARK: - RideDetail CellType
enum RideDetailCellType {
    
    case detail, title, availableSeats, seatBookedCount, seatListCell, bookReqCount, carInfo, pref, driverInfo, driverMessage, tip, review
    
    var cellId: String {
        switch self {
        case .detail: return "detailCell"
        case .title: return TitleTVC.identifier
        case .availableSeats: return AvailableSeatsCell.identifier
        case .seatBookedCount: return "seatBookedCell"
        case .seatListCell: return RideDetailBookingListTVC.identifier // "seatsListCell"
        case .bookReqCount: return "countsCell"
        case .carInfo: return "carDetailCell"
        case .pref: return "prefCell"
        case .driverInfo: return "driverDetail"
        case .driverMessage: return "driverMessage"
        case .tip: return RideTipTVC.identifier
        case .review: return RideReviewTVC.identifier
        }
    }
    
    var cellHeight: CGFloat {
        switch self {
        case .title: return 40 * _widthRatio
        case.availableSeats: return 90 * _widthRatio
        case .seatBookedCount: return 44 * _widthRatio
//        case .seatListCell: return 90 * _widthRatio
        case .bookReqCount: return 90 * _widthRatio
        default: return UITableView.automaticDimension
        }
    }
}

// MARK: - RideDetails Model
class RideDetails {
    
    var userId: Int!
    var id: Int!
    var book_ride_id: Int?
    var tripCode: String!
    var start: SearchAddress?
    var dest: SearchAddress?
    var car: CarDetailModel?
    var seatTotal: Int!
    var seatLeft: Int!
    var seatBooked: Int!
    var bookingReq: Int!
    var inviteCount: Int!
    var eta: String!
    var fromDate: Date!
    var fromTime: Date!
    var fromTimeZoneId: String!
    var fromTimeZoneName: String!
    var fromDateTime: Date!
    var toDate: Date!
    var fromStopId: Int!
    var toStopId: Int!
    var desc: String!
    var totalMiles: Double!
    var duration: Int!
    var status: RideStatus!
    var rideType: String!
    var arrStopOvers: [StopoverDetail] = []
    var driver: DriverModel?
    var isStopover: Bool?
    var price: Double!
    var arrPrefs: [RidePrefModel] = []
    var arrLuggage: [RidePrefModel] = []
    var transation: RideTransactionDetail!
    var bookingList: [RideDetailBookingListModel] = []
    var showStartButton: Bool!
    var cancelReason: String!
    var cancelReasonDesc: String!
    var isTipGiven: Bool!
    var isReviewGiven: Bool!
    var review: ReviewModel?
    var canceRideReason: String!
    var cancelRideMessage : String!
    
    var verificationCode: String!
    
    var dateTimeStr: String {
           let str = Date.formattedString(from: fromDate, format: DateFormat.format_MMMMddyyyy) + " " + Date.formattedString(from: fromTime, format: DateFormat.format_HHmma)
        return str + " (\(fromTimeZoneName.shortName()))"
    }
    
    var rideLuggageStr: String {
        return arrLuggage.compactMap({$0.luggageCountStr}).joined(separator: ", ")
    }
    
    init(_ dict: NSDictionary) {
        userId = dict.getIntValue(key: "user_id")
        id = dict.getIntValue(key: "ride_id")
        book_ride_id = dict.getIntValue(key: "book_ride_id")
        tripCode = dict.getStringValue(key: "trip_code")
        start = SearchAddress(fromDict: dict)
        dest = SearchAddress(toDict: dict)
        seatTotal = dict.getIntValue(key: "no_of_seat")
        seatLeft = dict.getIntValue(key: "left_seat")
        seatBooked = dict.getIntValue(key: "booked_seats")
        bookingReq = dict.getIntValue(key: "booking_request")
        inviteCount = dict.getIntValue(key: "invite_riders")
        eta = dict.getStringValue(key: "estimated_time")
        fromTimeZoneId = dict.getStringValue(key: "from_time_zone_id")
        fromTimeZoneName = dict.getStringValue(key: "from_time_zone_name")
        fromDate = Date.dateFromServerFormat(from: dict.getStringValue(key: "from_date"), format: DateFormat.serverDateTimeFormat)
        fromTime = Date.dateFromServerFormat(from: dict.getStringValue(key: "from_time"), format: DateFormat.serverTimeFormat)
        
        var dateStr = dict.getStringValue(key: "formated_date_time")
        if dateStr.isEmpty {
            dateStr = dict.getStringValue(key: "from_formated_date_time")
        }
        let date = Date.dateFromServerFormat(from: dateStr, format: DateFormat.serverDateTimeFormat)
        fromDateTime = date?.getTimeZoneDate(fromTimeZoneId)
        
        toDate = Date.dateFromServerFormat(from: dict.getStringValue(key: "to_date"), format: DateFormat.serverDateTimeFormat)
        fromStopId = dict.getIntValue(key: "from_stopover_id")
        toStopId = dict.getIntValue(key: "to_stopover_id")
        totalMiles = dict.getDoubleValue(key: "total_miles")
        desc = dict.getStringValue(key: "ride_description")
        status = RideStatus(rawValue: dict.getStringValue(key: "status"))
        rideType = dict.getStringValue(key: "ride_type")
        isStopover = dict.getBooleanValue(key: "is_stopover")
        price = dict.getDoubleValue(key: "price").rounded(toPlaces: 2)
        duration = dict.getIntValue(key: "int_duration")
        showStartButton = dict.getBooleanValue(key: "is_started_btn_show")
        cancelReason = dict.getStringValue(key: "cancel_reject_reason")
        cancelReasonDesc = dict.getStringValue(key: "cancel_reject_message")
        cancelRideMessage = dict.getStringValue(key: "cancel_message")
        canceRideReason = dict.getStringValue(key: "cancel_reason")
        
        isTipGiven = dict.getBooleanValue(key: "is_tip_given")
        isReviewGiven = dict.getBooleanValue(key: "is_rating_given")
        
        verificationCode = dict.getStringValue(key: "verification_code")
        
        if let carData = dict["car_detail"] as? NSDictionary {
            car = CarDetailModel(carData)
        }
        
        if let arrStops = dict["ride_stopovers"] as? [NSDictionary] {
            arrStops.forEach { stop in
                arrStopOvers.append(StopoverDetail(stop, timeZone: fromTimeZoneId))
            }
        }
        if let driv = dict["driver_detail"] as? NSDictionary {
            driver = DriverModel(driv)
        }
        
        if let prefs = dict["ride_preferences"] as? [NSDictionary] {
            prefs.forEach { pref in
                arrPrefs.append(RidePrefModel(pref))
            }
        }
        
        if let luggages = dict["ride_luggage"] as? [NSDictionary] {
            luggages.forEach { lug in
                arrLuggage.append(RidePrefModel(lug))
            }
        }
        
        if let pay = dict["transaction_detail"] as? NSDictionary {
            transation = RideTransactionDetail(pay)
        }
        
        if let booking = dict["booking_detail"] as? [NSDictionary] {
            booking.forEach { book in
                bookingList.append(RideDetailBookingListModel(book))
            }
        } else if let booking = dict["co_riders"] as? [NSDictionary] {
            booking.forEach { book in
                bookingList.append(RideDetailBookingListModel(book))
            }
        }
        
        if let rev = dict["own_rating"] as? NSDictionary {
            review = ReviewModel(rev)
        }
    }
    
    func getDurationString(_ screenType: RideDetailScreenType) -> String{
        if EnumHelper.checkCases(screenType, cases: [.find, .review, .book]){
            let hms = secondsToETA(duration)
            let eta = "\(hms.0) hour \(hms.1) mins"
            return "\(totalMiles.kilometers.rounded(toPlaces: 2)) Kms" + " - " + eta
        } else {
            return "\(totalMiles.kilometers.rounded(toPlaces: 2)) Kms" + " - " + eta
        }
    }
    
    init(_ request: BookingRequestDetailModel) {
        self.id = request.rideId
        self.book_ride_id = request.bookRideId
        
    }
    
    func getShareString(_ str: String) -> String{
        var str = str
        str = str.replacingOccurrences(of: "{source}", with: start!.name)
        str = str.replacingOccurrences(of: "{destination}", with: dest!.name!)
        str = str.replacingOccurrences(of: "{date}", with: Date.formattedString(from: fromDate, format: DateFormat.format_MMMMddyyyy))
        str = str.replacingOccurrences(of: "{time}", with: Date.formattedString(from: fromTime, format: DateFormat.format_HHmma))
        str = str.replacingOccurrences(of: "{no_of_seat}", with: seatLeft.stringValue)
        return str
    }
}

class RideDetailBookingListModel {
    
    var id: Int!
    var book_ride_id: Int!
    var image: String!
    
    init(_ dict: NSDictionary) {
        id = dict.getIntValue(key: "user_id")
        book_ride_id = dict.getIntValue(key: "book_ride_id")
        image = dict.getStringValue(key: "image")
    }
}

// MARK: - Ride Transaction Model
class RideTransactionDetail {
    
    var cardId: Int!
    var bookingFee: Double!
    var discountPrice: Double!
    var tipAmount: Double!
    var price: Double!
    var finalPrice: Double!
    var cancelCharge: Double!
    var refund: Double!
    var seatBooked: Int!
    var isRefund: Bool = false
    
    var cardNum: Int!
    var cardType: String!
    
    var txtId: String!
    
    init(_ dict: NSDictionary) {
        cardId = dict.getIntValue(key: "card_id")
        bookingFee = dict.getDoubleValue(key: "booking_fees")
        discountPrice = dict.getDoubleValue(key: "coupon_price")
        tipAmount = dict.getDoubleValue(key: "tip_price")
        price = dict.getDoubleValue(key: "price")
        finalPrice = dict.getDoubleValue(key: "final_price")
        cancelCharge = dict.getDoubleValue(key: "cancellation_charge")
        seatBooked = dict.getIntValue(key: "no_of_seat")
        refund = dict.getDoubleValue(key: "refund_amount")
        isRefund = dict.getBooleanValue(key: "is_refund")
        txtId = dict.getStringValue(key: "txtId")
        if let card = dict["get_card"] as? NSDictionary {
            cardNum = card.getIntValue(key: "card_number")
            cardType = card.getStringValue(key: "brand")
        }
    }
}

// MARK: - StopoverDetail
class StopoverDetail {
    
    var id: Int!
    var rideId: Int!
    var start: SearchAddress?
    var dest: SearchAddress?
    var stopOverNumber: Int!
    var fromLocation: String!
    var toLocation: String!
    var fromDateTime: Date!
    var fromTimeZoneId: String!
    var fromTimeZoneName: String!
    var price: Double!
    
    var fDate: Date!
    var fTime: Date!

    var tDate: Date!
    var tTime: Date!
    
    var dateTimeStr: String {
        return Date.formattedString(from: fDate, format: DateFormat.format_MMMMddyyyy) + " " + Date.formattedString(from: fTime, format: DateFormat.format_HHmma)
    }
    
    var toDateTimeStr: String {
        return Date.formattedString(from: tDate, format: DateFormat.format_MMMMddyyyy) + " " + Date.formattedString(from: tTime, format: DateFormat.format_HHmma)
    }
    
    var toDate: Date {
        return Date.dateFromServerFormat(from: Date.serverDateString(from: tDate, format: DateFormat.serverDateFormat) + " " + Date.serverDateString(from: tTime, format: DateFormat.serverTimeFormat), format: DateFormat.serverDateTimeFormat)!
    }
    
    init(_ dict: NSDictionary, timeZone: String = "UTC") {
        id = dict.getIntValue(key: "stopover_id")
        rideId = dict.getIntValue(key: "ride_id")
        stopOverNumber = dict.getIntValue(key: "stop_order_number")
        fromLocation = dict.getStringValue(key: "from_location")
        toLocation = dict.getStringValue(key: "to_location")
        price = dict.getDoubleValue(key: "price").rounded(toPlaces: 2)
        fromTimeZoneId = dict.getStringValue(key: "from_time_zone_id")
        fromTimeZoneName = dict.getStringValue(key: "from_time_zone_name")
        
        let date = Date.dateFromServerFormat(from: dict.getStringValue(key: "from_formated_date_time"), format: DateFormat.serverDateTimeFormat)
        fromDateTime = date?.getTimeZoneDate(timeZone)
        
        fDate = Date.dateFromServerFormat(from: dict.getStringValue(key: "from_date"), format: DateFormat.serverDateTimeFormat)
        fTime = Date.dateFromServerFormat(from: dict.getStringValue(key: "from_time"), format: DateFormat.serverTimeFormat)
        
        tDate = Date.dateFromServerFormat(from: dict.getStringValue(key: "to_date"), format: DateFormat.serverDateTimeFormat)
        tTime = Date.dateFromServerFormat(from: dict.getStringValue(key: "to_time"), format: DateFormat.serverTimeFormat)
        
        start = SearchAddress(fromDict: dict)
        dest = SearchAddress(toDict: dict)
    }
}
