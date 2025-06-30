//
//  CancellationModel.swift
//  CabO
//
//  Created by Octos.
//

import Foundation
import UIKit

// MARK: - Cancel ScreenType
enum CancelScreenType {
    case rejectRequest, cancelRide, cancelBooking
    
    var screenTitle: String {
        switch self {
        case .cancelRide: return "Cancel ride"
        case .rejectRequest: return "Reject booking"
        case .cancelBooking: return "Cancel booking"
        }
    }
    
    var screenInfo: String {
        switch self {
        case .cancelRide, .cancelBooking: return "Reason for canceling"
        case .rejectRequest: return "Reason for denying this booking request"
        }
    }
    
    var apiEnd: String {
        switch self {
        case .cancelRide: return "driver_cancellation"
        case .cancelBooking: return "rider_cancellation"
        case .rejectRequest: return "reject_booking"
        }
    }
    
    var updateStatus: String {
        switch self {
        case .cancelRide: return "cancel_ride"
        case .cancelBooking: return "cancel_booking"
        case .rejectRequest: return "rejected"
        }
    }
}

// MARK: - AddSupportTicketCellType
enum CancellationCellType: Equatable {
    case title, info, rideInfo, issueType, other, message
    
    var cellId: String {
        switch self {
        case .title: return TitleTVC.identifier
        case .info: return "infoCell"
        case .rideInfo: return "detailCell"
        case .message: return InputCell.textViewIdentifier
        default: return InputCell.identifier
        }
    }
    
    var cellHeight: CGFloat {
        switch self {
        case .rideInfo: return 150 * _widthRatio
        case .message: return InputCell.textViewHeight
        default: return InputCell.normalHeight
        }
    }
    
    var title: String {
        switch self {
        case .issueType: return "Reason*"
        case .other: return "Other*"
        case .message: return "Message"
        default: return ""
        }
    }
    
    var inputPlaceholder: String {
        switch self {
        case .issueType: return "Select reason"
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

// MARK: - SupportTicketModel
class CancellationModel {
    
    var issueType: SupportTicketIssueType?
    var otherTitle: String = ""
    var message: String = ""
    
    init() { }
    
    var param: [String : Any] {
        var param: [String: Any] = [:]
        if issueType!.name.lowercased() == "other" {
            
        } else {
            param["reason_id"] = issueType!.id
        }
        param["is_other"] = issueType!.name.lowercased() == "other" ? 1 : 0
        param["message"] = message
        
        return param
    }
    
    func isValid() -> (Bool, String) {
        if issueType == nil {
            return (false, "Please select your reason")
        } else if issueType!.name.lowercased() == "other" && message.isEmpty {
            return (false, "Please enter your message")
        }
        return (true, "")
    }
    
    func getValue(_ cellType: CancellationCellType) -> String {
        switch cellType {
        case .issueType: return issueType?.name ?? ""
        case .other: return otherTitle
        case .message: return message
        default: return ""
        }
    }
    
    func setValue(_ str: String,_ cellType: CancellationCellType) {
        switch cellType {
        case .other: otherTitle = str
        case .message: message = str
            default: break
        }
    }
}
