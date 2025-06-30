//
//  RideHistoryFilterModel.swift
//  CabO
//
//  Created by Octos.
//

import Foundation
import UIKit

// MARK: - RideHistoryFilter CellType
enum RideHistoryFilterCellType {
    case start, dest, date, status
    
    var cellId: String {
        switch self {
        case .status: return RideFilterStatusCell.identifier
        default: return InputCell.identifier
        }
    }
    
    var cellHeight: CGFloat {
        switch self {
        case .status: return RideFilterStatusCell.addTitleHeight
        default: return InputCell.normalHeight
        }
    }
    
    var title: String {
        switch self {
        case .start: return "Source"
        case .dest: return "Destination"
        case .date: return "Date"
        default: return ""
        }
    }
    
    var placeHolder: String {
        switch self {
        case .start: return "Select source"
        case .dest: return "Select destination"
        case .date: return "Select date"
        default: return ""
        }
    }
}

// MARK: - RideHistoryFilter Model
struct RideHistoryFilterModel {
    
    var start: SearchAddress?
    var dest: SearchAddress?
    var date: Date?
    var status: RideStatus?
    
    var isFilterApplied: Bool {
        if start != nil || dest != nil || date != nil || status != nil {
            return true
        } else {
            return false
        }
    }
    
    var param: [String: Any] {
        var param: [String: Any] = [:]
        if let start {
            param["from_latitude"] = start.lat.rounded(toPlaces: 7)
            param["from_longitude"] = start.long.rounded(toPlaces: 7)
        }
        if let dest {
            param["to_latitude"] = dest.lat.rounded(toPlaces: 7)
            param["to_longitude"] = dest.long.rounded(toPlaces: 7)
        }
        if let date {
            param["date"] = date.converDisplayDateFormet()
        }
        if let status {
            param["status"] = status.rawValue
        }
        return param
    }
    
    mutating func reset() {
        start = nil
        dest = nil
        date = nil
        status = nil
    }
    
    func getValue(_ cellType: RideHistoryFilterCellType) -> String {
        switch cellType {
        case .start: return start?.name ?? ""
        case .dest: return dest?.name ?? ""
        case .date: return Date.localDateString(from: date, format: DateFormat.format_MMMddyyyy)
        default: return ""
        }
    }
}
