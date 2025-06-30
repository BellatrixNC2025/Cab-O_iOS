//
//  RideHistoryModel.swift
//  CabO
//
//  Created by Octos.
//

import Foundation
import UIKit

// MARK: - RideStatus
enum RideStatus: String {
    case pending = "pending"
    case accepted = "accepted"
    case rejected = "rejected"
    case ontheway = "on_the_way"
    case started = "started"
    case completed = "completed"
    case cancelled = "cancelled"    
    case autoCancelled = "auto_cancelled"
    
    var title: String {
        switch self {
        case .pending: return "Pending"
        case .accepted: return "Accepted"
        case .rejected: return "Rejected"
        case .ontheway: return "On the way"
        case .started: return "Ride started"
        case .completed: return "Completed"
        case .cancelled: return "Cancelled"
        case .autoCancelled: return "Auto Cancelled"
        }
    }
    
    var color: UIColor {
        switch self {
        case .pending: return AppColor.themeBlue
        case .accepted: return AppColor.themeGreen
        case .rejected, .cancelled, .autoCancelled: return UIColor.systemRed
        case .ontheway: return UIColor.systemPurple
        case .started: return UIColor.systemOrange
        case .completed: return UIColor.systemBlue
        }
    }
    
    var order: Int {
        switch self {
        case .cancelled: return 1
        case .autoCancelled: return 2
        default: return 0
        }
    }
}

// MARK: - RideHistoryData
class RideHistoryData {
    
    var fDate: Date!
    var fromLocation: String!
    var fromDate: Date!
    var fromTime: Date!
    var fromTimeZoneId: String!
    var fromTimeZoneName: String!
    var inviteRiders: Int!
    var price: Double!
    var rideId: Int!
    var requestId: Int!
    var bookRideId: Int!
    var seatReq: Int!
    var seatBooked: Int!
    var inviteCount: Int!
    var invitations: Int!
    var status: RideStatus!
    var toLocation: String!
    var userId: Int!
    var driver: DriverModel?
    
    var dateTimeStr: String {
        return Date.formattedString(from: fromDate, format: DateFormat.format_MMMMddyyyy) + " at " + Date.formattedString(from: fromTime, format: DateFormat.format_HHmma) + " (\(fromTimeZoneName.shortName()))"
    }
    
    init(_ dict: NSDictionary, isRequest: Bool = false) {
        fromTimeZoneId = dict.getStringValue(key: "from_time_zone_id")
        fromTimeZoneName = dict.getStringValue(key: "from_time_zone_name")
        
        var dateStr = dict.getStringValue(key: "formated_date_time")
        if dateStr.isEmpty {
            dateStr = dict.getStringValue(key: "date")
        }
        
        if isRequest {
            fDate = Date.formattedDate(from: dateStr, format: DateFormat.serverDateTimeFormat)
        } else {
            let date = Date.dateFromServerFormat(from: dateStr, format: DateFormat.serverDateTimeFormat)
            fDate = date?.getTimeZoneDate(fromTimeZoneId)
        }
        
        fromLocation = dict.getStringValue(key: "from_location")
        fromDate = Date.dateFromServerFormat(from: dict.getStringValue(key: "from_date"), format: DateFormat.serverDateTimeFormat)
        fromTime = Date.dateFromServerFormat(from: dict.getStringValue(key: "from_time"), format: DateFormat.serverTimeFormat)
        
        inviteRiders = dict.getIntValue(key: "invite_riders")
        price = dict.getDoubleValue(key: "price").rounded(toPlaces: 2)
        rideId = dict.getIntValue(key: "ride_id")
        status = RideStatus(rawValue: dict.getStringValue(key: "status"))
        toLocation = dict.getStringValue(key: "to_location")
        userId = dict.getIntValue(key: "user_id")
        requestId = dict.getIntValue(key: "request_id")
        bookRideId = dict.getIntValue(key: "book_ride_id")
        seatReq = dict.getIntValue(key: "seats")
        seatBooked = dict.getIntValue(key: "no_of_seat")
        inviteCount = dict.getIntValue(key: "invite_riders")
        invitations = dict.getIntValue(key: "invitations")
        if let data = dict["ride_driver"] as? NSDictionary {
            driver = DriverModel(data)
        }
    }
    
    init(booked dict: NSDictionary) {
        fromTimeZoneId = dict.getStringValue(key: "from_time_zone_id")
        fromTimeZoneName = dict.getStringValue(key: "from_time_zone_name")
        
        var dateStr = dict.getStringValue(key: "from_formated_date_time")
        if dateStr.isEmpty {
            dateStr = dict.getStringValue(key: "from_date")
        }
        
        let date = Date.dateFromServerFormat(from: dateStr, format: DateFormat.serverDateTimeFormat)
        fDate = date?.getTimeZoneDate(fromTimeZoneId)
        
        fromLocation = dict.getStringValue(key: "from_location")
        fromDate = Date.dateFromServerFormat(from: dict.getStringValue(key: "from_date"), format: DateFormat.serverDateTimeFormat)
        fromTime = Date.dateFromServerFormat(from: dict.getStringValue(key: "from_time"), format: DateFormat.serverTimeFormat)
        inviteRiders = dict.getIntValue(key: "invite_riders")
        price = dict.getDoubleValue(key: "price").rounded(toPlaces: 2)
        rideId = dict.getIntValue(key: "ride_id")
        status = RideStatus(rawValue: dict.getStringValue(key: "status"))
        toLocation = dict.getStringValue(key: "to_location")
        userId = dict.getIntValue(key: "user_id")
        requestId = dict.getIntValue(key: "request_id")
        bookRideId = dict.getIntValue(key: "book_ride_id")
        seatReq = dict.getIntValue(key: "seats")
        seatBooked = dict.getIntValue(key: "no_of_seat")
        inviteCount = dict.getIntValue(key: "invite_riders")
        invitations = dict.getIntValue(key: "invitations")
        if let data = dict["ride_driver"] as? NSDictionary {
            driver = DriverModel(data)
        }
    }
}


// MARK: - DriverModel
struct DriverModel {
    
    var id: Int!
    var fName: String!
    var lName: String!
    var img: String!
    var totalReview: Int!
    var averageRating: Double!
    
    var reviewCount: String {
        return totalReview == 1 ? "\(totalReview!) Review" : "\(totalReview!) Reviews"
    }
    
    var fullName: String {
        return fName + " " + lName
    }
    
    init(_ dict: NSDictionary) {
        id = dict.getIntValue(key: "id")
        if id == 0 {
            id = dict.getIntValue(key: "user_id")
        }
        fName = dict.getStringValue(key: "first_name")
        lName = dict.getStringValue(key: "last_name")
        img = dict.getStringValue(key: "image")
        totalReview = dict.getIntValue(key: "total_review")
        averageRating = dict.getDoubleValue(key: "average_rating").rounded(toPlaces: 1)
    }
}

// MARK: - RiderModel
struct RiderModel {
    
    var id: Int!
    var fName: String!
    var lName: String!
    var img: String!
    
    var fullName: String {
        return fName + " " + lName
    }
    
    init(_ dict: NSDictionary) {
        id = dict.getIntValue(key: "user_id")
        fName = dict.getStringValue(key: "first_name")
        lName = dict.getStringValue(key: "last_name")
        img = dict.getStringValue(key: "image")
    }
}
