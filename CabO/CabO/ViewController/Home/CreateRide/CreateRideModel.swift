//
//  CreateRideModel.swift
//  CabO
//
//  Created by Octos.
//

import Foundation
import UIKit

// MARK: - Create Ride Sections
enum CreateRideSteps: Int {
    case step1 = 1, step2, step3, step4, step5
}

// MARK: - CreateRideCellType ENUM
enum CreateRideCellType {
    case startDest, stopover, addStopover, date, time, btn
    case selectCarTitle, selectCarInfo, car, noCar
    case availSeats, ridePrefs, luggage
    case everyRiderPayTitle, everyRiderPayInfo, paymentDistribution
    case rideDescTitle, rideDescInfo, rideMessage
    
    var cellId: String {
        switch self {
        case .startDest: return StartDestPickerCell.identifier
        case .stopover: return "stopoverCell"
        case .addStopover: return "addStopoverCell"
        case .date, .time: return DatePickerCell.identifier
        case .selectCarTitle, .selectCarInfo, .everyRiderPayTitle, .everyRiderPayInfo, .rideDescTitle, .rideDescInfo: return TitleTVC.identifier
        case .car: return CarListCell.identifier
        case .noCar: return NoDataCell.identifier
        case .btn: return ButtonTableCell.identifier
        case .availSeats: return AvailableSeatsCell.identifier
        case .ridePrefs: return CreateRidePreferenceCell.identifier
        case .luggage: return CreateRideLuggageCell.identifier
        case .paymentDistribution: return "paymentDistributionCell"
        case .rideMessage: return InputCell.textViewIdentifier
//        default: return ButtonTableCell.identifier
        }
    }
    
    var cellHeight: CGFloat {
        switch self {
        case .startDest: return StartDestPickerCell.height
        case .stopover: return 92 * _widthRatio
        case .addStopover: return 48 * _widthRatio
        case .date, .time: return DatePickerCell.height
        case .car: return CarListCell.normalHeight
        case .btn: return ButtonTableCell.cellHeight + 36
        case .availSeats: return AvailableSeatsCell.cellHeight
        case .ridePrefs: return CreateRidePreferenceCell.addHeight
        case .luggage: return CreateRideLuggageCell.addHeight
        case .paymentDistribution: return 148 * _widthRatio
        case .rideMessage: return InputCell.textViewHeight
        default: return ButtonTableCell.cellHeight
        }
    }
    
    var title: String {
        switch self {
        case .date: return "Select date"
        case .time: return "Select time"
        case .selectCarTitle: return "Select a car"
        case .selectCarInfo: return "Please pick your preferred verified vehicle to ensure a comfortable and efficient ride for your passengers."
        case .everyRiderPayTitle: return "Every rider will pay"
        case .everyRiderPayInfo: return "Fair price per seat that will cover your gas and other expenses."
        case .rideDescTitle: return "Ride description"
        case .rideDescInfo: return "Share any important information about this ride that you want your passengers to know before booking the ride."
        case .rideMessage: return "Message"
        default: return ""
        }
    }
    
    var datePickerMode: UIDatePicker.Mode {
        switch self {
        case .time: return .time
        default: return .date
        }
    }
    
    var titleFont: UIFont {
        switch self {
        case .selectCarInfo, .everyRiderPayInfo, .rideDescInfo: return AppFont.fontWithName(.regular, size: 12 * _fontRatio)
        default: return AppFont.fontWithName(.mediumFont, size: 20 * _fontRatio)
        }
    }
}

// MARK: - CreateRideData Model
class CreateRideData {
    
    var rideId: Int?
    var start: SearchAddress?
    var dest: SearchAddress?
    var miles: Double = 0.0
    var totalPrice: Double = 0.0
    var price: Double = 0.0
    var bookingFee: Double = 0.0
    var duration: Int = 0
    var eta: String = ""
    var desc: String = ""
    var bookedSeats: Int?
    
    var arrStopOver: [SearchAddress] = []
    
    var arrRideWayPoints: [RideStopOver] = []
    var rideWayPoint: RideStopOver?
    
    var rideDate: Date = Date()
    var rideTime: Date = Date().adding(.minute, value: 5)
    
    var isTimeChanged: Bool = false
    
    var utcRideDate: Date {
        let fDate = Date.dateFromServerFormat(from: Date.serverDateString(from: rideDate, format: DateFormat.serverDateFormat) + " " + Date.serverDateString(from: rideTime.getTime(), format: DateFormat.serverTimeFormat), format: DateFormat.serverDateTimeFormat)!
        
        return fDate.getUtcDate(fromTimeZone: start!.timeZoneId)!
    }
    
    var rideDateTime: Date {
        if rideId != nil {
            if !isTimeChanged {
                return Date.formattedDate(from: Date.formattedString(from: rideDate, format: DateFormat.serverDateFormat) + " " + Date.formattedString(from: rideTime.getTime(), format: DateFormat.serverTimeFormat), format: DateFormat.serverDateTimeFormat)!
            } else {
                return Date.formattedDate(from: Date.formattedString(from: rideDate, format: DateFormat.serverDateFormat) + " " + Date.formattedString(from: rideTime.getTimeZoneDate(start!.timeZoneId)?.getTime(), format: DateFormat.serverTimeFormat), format: DateFormat.serverDateTimeFormat)!
            }
        } else {
            let fDate = Date.formattedDate(from: Date.formattedString(from: rideDate, format: DateFormat.serverDateFormat) + " " + Date.localDateString(from: rideTime.getTime(), format: DateFormat.serverTimeFormat), format: DateFormat.serverDateTimeFormat)!
            return fDate
        }
    }
    
    var selectedCar: CarListModel?
    var availableSeats: Int?
    
    var arrPrefs: [RidePrefModel] = []
    var arrLuggage: [RidePrefModel] = _arrLuggage.map({$0.copy()})
    
    var seatBooked: Int = 0
    
    func swapStartDest() {
        swap(&start, &dest)
    }
    
    init() { }
    
    init(ride: RideDetails) {
        self.rideId = ride.id
        
        self.start = ride.start?.copy()
        self.dest = ride.dest?.copy()
        
        self.arrStopOver = ride.arrStopOvers.compactMap({$0.start?.copy()})
        if !arrStopOver.isEmpty {
            arrStopOver.removeFirst()
        }
        
        if ride.seatBooked != 0 {
            self.bookedSeats = ride.seatBooked
        }
        
        self.rideDate = ride.fromDate
        self.rideTime = ride.fromTime
        
        self.selectedCar = CarListModel(ride.car!)
        self.availableSeats = ride.seatTotal
        
        self.arrPrefs = ride.arrPrefs
        
        let lug = ride.arrLuggage.compactMap({$0.copy()})
        
        lug.forEach { rideLug in
            if let index = arrLuggage.firstIndex(where: {$0.id == rideLug.id}) {
                self.arrLuggage[index].count = rideLug.count
            }
        }
        
        self.seatBooked = ride.seatBooked
        self.desc = ride.desc
    }
    
    func isValidData(_ step: CreateRideSteps) -> (Bool, String){
        if step == .step1 {
            if start == nil {
                return (false, "Please select a source location first")
            } else if dest == nil {
                return (false, "Please select a destination first")
            }
        } else if step == .step2 {
            if selectedCar == nil {
                return (false, "Please select a car first")
            }
        } else if step == .step3 {
            if availableSeats == nil {
                return (false, "Please select number of seats available")
            }
        }
        return (true, "")
    }
    
    func isValidRestrictData() -> (Bool, String){
        if selectedCar == nil {
            return (false, "Please select a car first")
        }
        else if availableSeats == nil {
            return (false, "Please select number of seats available")
        }
        return (true, "")
    }
    
    var createRideParam: [String: Any] {
        var param: [String: Any] = [:]
        if let rideId {
            param["ride_id"] = rideId
        }
        
        param["car_id"] = selectedCar!.id
        param["no_of_seat"] = availableSeats!
        
        param["from_date"] = Date.formattedString(from: rideDate, format: DateFormat.serverDateFormat)
        if rideId != nil {
            if isTimeChanged {
                param["from_time"] = Date.formattedString(from: rideTime.getTimeZoneDate(start!.timeZoneId)?.getTime(), format: DateFormat.serverTimeFormat)
            } else {
                param["from_time"] = Date.formattedString(from: rideTime.getTime(), format: DateFormat.serverTimeFormat)
            }
        } else {
            param["from_time"] = Date.localDateString(from: rideTime.getTime(), format: DateFormat.serverTimeFormat)
        }
        param["formated_date_time"] = Date.serverDateString(from: utcRideDate, format: DateFormat.serverDateTimeFormat)
        
        param["estimated_time"] = eta
        param["int_duration"] = duration
        
        let toDate = rideDateTime.adding(.second, value: duration)
        
        param["to_date"] = Date.serverDateString(from: toDate, format: DateFormat.serverDateFormat)
        param["to_time"] = Date.serverDateString(from: toDate, format: DateFormat.serverTimeFormat)
        
        param["total_miles"] = miles
//        param["price"] = price
        param["price"] = totalPrice
        param["ride_description"] = desc
        param.merge(with: start!.fromParam)
        param.merge(with: dest!.toParam)
        if !arrRideWayPoints.isEmpty {
            param["offer_ride_stop_over"] = arrRideWayPoints.compactMap({$0.createRideParam})
        }
        param["preference_id"] = arrPrefs.compactMap({$0.id})
        if !arrLuggage.isEmpty {
            param["ride_luggage"] = arrLuggage.filter({$0.count > 0}).compactMap({$0.luggageParam})
        }
        param.merge(with: Setting.deviceInfo)
        return param
    }
    
    var updateRideParam: [String: Any] {
        var param: [String: Any] = [:]
        param["ride_id"] = rideId
        param["car_id"] = selectedCar!.id
        param["no_of_seat"] = availableSeats!
        param["ride_description"] = desc
        
        param.merge(with: Setting.deviceInfo)
        return param
    }
}

// MARK: - Ride Prefrences Model
class RidePrefModel: Equatable {
    
    static func == (lhs: RidePrefModel, rhs: RidePrefModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    var id: Int!
    var title: String!
    var image: String!
    var count: Int = 0
    
    var img: UIImage!
    
    var luggageCountStr: String {
        return title + " - " + "\(count)"
    }
    
    init(_ dict: NSDictionary) {
        id = dict.getIntValue(key: "id")
        if id == 0 {
            id = dict.getIntValue(key: "preference_id")
        }
        title = dict.getStringValue(key: "name")
        image = dict.getStringValue(key: "image")
        count = dict.getIntValue(key: "no_of_count")
    }
    
    init(_ id: Int!,_ title: String,_ image: String,_ count: Int) {
        self.id = id
        self.title = title
        self.image = image
        self.count = count
    }
    
    func copy() -> RidePrefModel {
        let copiedObject = RidePrefModel(self.id, self.title, self.image, self.count)
        return copiedObject
    }
    
    var luggageParam: [String: Any] {
        var param: [String: Any] = [:]
        param["luggage_id"] = id
        param["no_of_count"] = count
        return param
    }
}

// MARK: - Ride StopOver Model
class RideStopOver {
    
    var start: SearchAddress?
    var dest: SearchAddress?
    var fDate: Date!
    var fUtcDate: Date!
    var tDate: Date!
    var tUtcDate: Date!
    var miles: Double = 0.0
    var totalPrice: Double = 0.0
    var bookingFee: Double = 0.0
    var eta: String = ""
    var duration: Int!
    var stopOverOrder: Int = 0
    
    var requestPriceParam: [String: Any] {
        var param: [String: Any] = [:]
        param["stop_order_number"] = stopOverOrder
        param["miles"] = miles
        return param
    }
    
    var createRideParam: [String: Any] {
        var param: [String: Any] = [:]
        
        param["from_date"] = Date.formattedString(from: fDate, format: DateFormat.serverDateFormat)
        param["from_time"] = Date.formattedString(from: fDate, format: DateFormat.serverTimeFormat)
        param["to_date"] = Date.serverDateString(from: tDate, format: DateFormat.serverDateFormat)
        param["to_time"] = Date.serverDateString(from: tDate, format: DateFormat.serverTimeFormat)
        
        param["from_formated_date_time"] = Date.serverDateString(from: fUtcDate, format: DateFormat.serverDateTimeFormat)
        
        param["stop_order_number"] = stopOverOrder
        param["estimated_time"] = eta
        param["int_duration"] = duration
        param["total_miles"] = miles
        param["price"] = totalPrice
//        param["price"] = totalPrice
        param.merge(with: start!.fromParam)
        param.merge(with: dest!.toParam)
        return param
    }
    
}

// MARK: - Update Price Model
class UpdatePriceModel {
    
    var miles: Double!
    var total_price: Double!
    var order: Int!
    
    init(_ dict: NSDictionary) {
        miles = dict.getDoubleValue(key: "miles")
        total_price = dict.getDoubleValue(key: "total_price").rounded(toPlaces: 2)
        order = dict.getIntValue(key: "stop_order_number")
    }
}
