//
//  SupportTicketModel.swift
//  CabO
//
//  Created by Octos.
//

import Foundation
import UIKit

// MARK: - SupportTicketIssueType
struct SupportTicketIssueType {
    
    var id: String = ""
    var name: String = ""
    var alias: String = ""
    
    init() { }
    
    init(_ dict: NSDictionary) {
        id = dict.getStringValue(key: "id")
        name = dict.getStringValue(key: "issue_name")
        alias = dict.getStringValue(key: "alias")
    }
    
    init(reason dict: NSDictionary) {
        id = dict.getStringValue(key: "id")
        name = dict.getStringValue(key: "reason")
    }
}

// MARK: - SupportTicketModel
class SupportTicketModel {
    
    var issueIType: SupportTicketIssueType?
    var rideDetails: RideDetails?
    var bookDetails: BookingRequestDetailModel?
    var bookRideId: Int?
    var otherTitle: String = ""
    var message: String = ""
    var image: UIImage?
    var lat: Double?
    var long: Double?
    var location: String?
    
    var toUserId: Int?
    
    var type: Int = 0
    
    init() { }
    
    var param: [String : Any] {
        var param: [String: Any] = [:]
        if let ride = rideDetails {
            param["ride_id"] = ride.id
            
            if let bookId = ride.book_ride_id {
                param["book_ride_id"] = bookId
            }
        }
        if let bookRideId {
            param["book_ride_id"] = bookRideId
        }
        
        if let toUserId {
            param["to_user_id"] = toUserId
        }
        
        param["type"] = type == 0 ? "general" : type == 1 ? "driver" : "rider"
        
        param["support_ticket_issue_id"] = issueIType!.id
        param["is_other"] = issueIType!.name.lowercased() == "other" ? 1 : 0
        param["other"] = otherTitle
        param["message"] = message
        
        param["location"] = location
        param["latitude"] = lat
        param["longitude"] = long
        return param
    }
    
    func isValid() -> (Bool, String) {
        if issueIType == nil {
            return (false, "Please select your issue type")
        }
        else if issueIType!.name.lowercased() == "other" && otherTitle.isEmpty {
            return (false, "Please enter your issue title")
        }
        else if message.isEmpty {
            return (false, "Please enter message")
        }
        else if message.count < 10 {
            return (false, "Message should be of minimum 10 characters")
        }
        return (true, "")
    }
    
    func getValue(_ cellType: AddSupportTicketCellType) -> String {
        switch cellType {
        case .issueType: return issueIType?.name ?? ""
        case .other: return otherTitle
        case .message: return message
        default: return ""
        }
    }
    
    func setValue(_ str: String,_ cellType: AddSupportTicketCellType) {
        switch cellType {
        case .other: otherTitle = str
        case .message: message = str
            default: break
        }
    }
}

// MARK: - SupportTicketStatus
enum SupportTicketStatus: String {
    case pending = "pending", approved = "approved", rejected = "rejected", in_progress = "in_progress"
    
    var title: String {
        switch self {
        case .pending: return "Pending"
        case .approved: return "Approved"
        case .rejected: return "Rejected"
        case .in_progress: return "In progress"
        }
    }
    
    var color: UIColor{
        switch self {
        case .pending: return AppColor.themeBlue
        case .rejected: return UIColor.red
        case .approved: return AppColor.themeGreen
        case .in_progress: return AppColor.themeBlue
        }
    }
}

// MARK: - AddSupportTicketCellType
enum AddSupportTicketCellType: Equatable {
    case rideInfo, issueType, other, message, addImage, image
    
    var cellId: String {
        switch self {
        case .rideInfo: return "detailCell"
        case .message: return InputCell.textViewIdentifier
        case .addImage: return "addImageCell"
        case .image: return "imageCell"
        default: return InputCell.identifier
        }
    }
    
    var cellHeight: CGFloat {
        switch self {
        case .rideInfo: return 150 * _widthRatio
        case .message: return InputCell.textViewHeight
        case .addImage: return 90 * _widthRatio
        case .image: return (DeviceType.iPad ? 264 : 196) * _widthRatio
        default: return InputCell.normalHeight
        }
    }
    
    var title: String {
        switch self {
        case .issueType: return "Issue type*"
        case .other: return "Other*"
        case .message: return "Message*"
        default: return ""
        }
    }
    
    var inputPlaceholder: String {
        switch self {
        case .issueType: return "Issue type"
        case .other: return "Other"
        case .message: return "Message"
        default: return ""
        }
    }
    
    var inputAccView: Bool {
        switch self {
        case .message: return true
        default: return false
        }
    }
    
    var maxLength: Int {
        switch self {
        case .other: return 64
        default: return 250
        }
    }
}

// MARK: - SupportTicketDetailCellType
enum SupportTicketDetailCellType: Equatable {
    case ticket, tripInfo, issueType, driver, other, message, rejectReason, image
    
    var cellId: String {
        switch self {
        case .ticket: return "ticketListCell"
        case .tripInfo: return "detailCell"
//        case .issueType: return "issueTypeCell"
        case .issueType, .other, .message, .driver, .rejectReason: return "otherIssueCell"
        case .image: return "imageCell"
        }
    }
    
    var cellHeight: CGFloat {
        switch self {
        default: return UITableView.automaticDimension
        }
    }
    
    var title: String {
        switch self {
        case .issueType: return "Issue type*"
        case .other: return "Other issue"
        case .message: return "Message"
        case .rejectReason: return "Reject reason"
        case .driver: return "Driver"
        default: return ""
        }
    }
    
    var detailTitle: String {
        switch self {
        case .issueType: return "Issue type"
        case .other: return "Other issue"
        case .message: return "Message"
        case .rejectReason: return "Reject reason"
        case .driver: return "Driver"
        default: return ""
        }
    }
    
}

// MARK: - SupportTicketDetailCellType
class TicketListData {
    
    var ticketId: String!
    var status: SupportTicketStatus!
    var ticketNo: String!
    var createdAt: Date!
    
    init(_ dict: NSDictionary) {
        ticketId = dict.getStringValue(key: "support_ticket_id")
        status = SupportTicketStatus(rawValue: dict.getStringValue(key: "status"))
        ticketNo = dict.getStringValue(key: "ticket_no")
        createdAt = Date.dateFromServerFormat(from: dict.getStringValue(key: "created_at"))
    }
}

// MARK: - SupportTicketData
class SupportTicketData {
    
    var createdAt: Date
    var ticketNo: String
    var status: SupportTicketStatus!
    var image: String
    var issueName: String
    var message: String
    var reason: String
    var otherReason: String
    var driverFName: String
    var driverLName: String
    var rideId: String
    var tripCode: String
    var startLoc: String
    var destLoc: String
    var type: String
    
    var userType: String {
        if type == "driver" {
            return "Rider"
        } else {
            return "Driver"
        }
    }
    
    var dFullname: String {
        return driverFName + " " + driverLName
    }
    
    init(_ dict: NSDictionary) {
        createdAt = Date.dateFromServerFormat(from: dict.getStringValue(key: "created_at"))!
        ticketNo = dict.getStringValue(key: "ticket_no")
        status = SupportTicketStatus(rawValue: dict.getStringValue(key: "status"))
        image = dict.getStringValue(key: "image")
        issueName = dict.getStringValue(key: "issue_name")
        message = dict.getStringValue(key: "message")
        reason = dict.getStringValue(key: "reason")
        otherReason = dict.getStringValue(key: "other_message")
        driverFName = dict.getStringValue(key: "first_name")
        driverLName = dict.getStringValue(key: "last_name")
        rideId = dict.getStringValue(key: "ride_id")
        tripCode = dict.getStringValue(key: "trip_code")
        startLoc = dict.getStringValue(key: "from_location")
        destLoc = dict.getStringValue(key: "to_location")
        type = dict.getStringValue(key: "type")
    }
    
    func getValue(_ cellType: SupportTicketDetailCellType) -> String {
        switch cellType {
        case .issueType : return issueName
        case .other: return otherReason
        case .message: return message
        case .rejectReason: return reason
        case .driver: return dFullname
        default: return ""
        }
    }
}
