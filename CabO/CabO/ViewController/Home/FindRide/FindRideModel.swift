//
//  FindRideModel.swift
//  CabO
//
//  Created by Octos.
//

import Foundation
import UIKit

// MARK: - FindRide Model
class FindRideModel {
    
    var start: SearchAddress?
    var dest: SearchAddress?
    
    var range: Float?
    
    var rideDate: Date = Date()
    var seatReq: Int?
    var arrPrefs: [RidePrefModel] = []
    var isNonStopRide: Int?
    
    var isFilterApplied: Bool {
        if seatReq != nil || !arrPrefs.isEmpty || isNonStopRide != nil || range != nil {
            return true
        } else {
            return false
        }
    }
    
    func swapStartDest() {
        swap(&start, &dest)
    }
    
    var findRideParam: [String: Any] {
        var param: [String: Any] = [:]
        param["from_location"] = start!.customAddress
        param["from_latitude"] = start!.lat.rounded(toPlaces: 7)
        param["from_longitude"] = start!.long.rounded(toPlaces: 7)
        param["from_city"] = start!.city
        
        param["to_location"] = dest!.customAddress
        param["to_latitude"] = dest!.lat.rounded(toPlaces: 7)
        param["to_longitude"] = dest!.long.rounded(toPlaces: 7)
        param["to_city"] = dest!.city
        
        let date = rideDate.removeTimeFromDate().getUtcDate()!
        param["from_date"] = Date.localDateString(from: date.removeTimeFromDate(), format: DateFormat.serverDateTimeFormat)
        
        
        let adate = rideDate.converDisplayDateFormet()
        print(adate)
        param["from_date"] = adate
        
        if let range {
            param["range"] = Int(range).miles
        }
        
        if let seatReq {
            param["required_seats"] = seatReq
        }
        if !arrPrefs.isEmpty {
            if arrPrefs.contains(where: {$0.id == 0}) {
                param["is_luggage"] = 1
            } else {
                param["is_luggage"] = 0
            }
            var prefs = arrPrefs.compactMap({$0.id})
            prefs.remove(0)
            param["preference_id"] = prefs
        }
        if let isNonStopRide {
            param["trip_stopovers"] = isNonStopRide == 1 ? 0 : 1
        }
        return param
    }
    
    func isValidData() -> (Bool, String){
        if start == nil {
            return (false, "Please select from location")
        } else if dest == nil {
            return (false, "Please select to location")
        }
        return (true, "")
    }
}

// MARK: - FindRideList Model
class FindRideListModel {
    
    var start: SearchAddress?
    var dest: SearchAddress?
    var fromDateTime: Date!
    var fromDate: Date!
    var fromTime: Date!
    var timeZoneId: String!
    var timeZoneName: String!
    var isStopover: Bool!
    var price: Double!
    var seatTotal: Int!
    var seatLeft: Int!
    var seatBooked: Int!
    var rideId: Int!
    var rideStopId: Int!
    var userId: Int!
    var driver: DriverModel?
    
    var dateTimeStr: String {
        return Date.formattedString(from: fromDate, format: DateFormat.format_MMMMddyyyy) + " at " + Date.formattedString(from: fromTime, format: DateFormat.format_HHmma) + " (\(timeZoneName.shortName()))"
    }
    
    init(_ dict: NSDictionary) {
        rideId = dict.getIntValue(key: "ride_id")
        rideStopId = dict.getIntValue(key: "ride_stopovers_id")
        userId = dict.getIntValue(key: "user_id")
        start = SearchAddress(fromDict: dict)
        dest = SearchAddress(toDict: dict)
        
        timeZoneId = dict.getStringValue(key: "from_time_zone_id")
        timeZoneName = dict.getStringValue(key: "from_time_zone_name")
        
        var dateStr: String = dict.getStringValue(key: "from_formated_date_time")
        if dateStr.isEmpty {
            dateStr = dict.getStringValue(key: "formated_date_time")
        }
        let date = Date.dateFromServerFormat(from: dateStr, format: DateFormat.serverDateTimeFormat)
        fromDateTime = date?.getTimeZoneDate(timeZoneId)
        
        fromDate = Date.dateFromServerFormat(from: dict.getStringValue(key: "from_date"), format: DateFormat.serverDateTimeFormat)
        fromTime = Date.dateFromServerFormat(from: dict.getStringValue(key: "from_time"), format: DateFormat.serverTimeFormat)
        
        
        isStopover = dict.getBooleanValue(key: "is_stopover")
        
        var seat = dict.getIntValue(key: "total_seats")
        if seat == 0 {
            seat = dict.getIntValue(key: "no_of_seat")
        }
        seatTotal = seat
        seatLeft = dict.getIntValue(key: "left_seat")
        seatBooked = dict.getIntValue(key: "booked_seats")
        price = dict.getDoubleValue(key: "price").rounded(toPlaces: 2)
        if let driv = dict["ride_driver"] as? NSDictionary {
            driver = DriverModel(driv)
        }
    }
}
