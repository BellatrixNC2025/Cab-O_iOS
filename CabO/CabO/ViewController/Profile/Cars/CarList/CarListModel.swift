//
//  CarListModel.swift
//  CabO
//
//  Created by Octos.
//

import Foundation
import UIKit

// MARK: - CarListModel
class CarListModel: Equatable {
    
    static func == (lhs: CarListModel, rhs: CarListModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    var id: String = ""
    var company: String = ""
    var model: String = ""
    var year: String = ""
    var color: String = ""
    var image: String = ""
    var availableSeats: String = ""
    var regStatus: DocStatus!
    var insuStatus: DocStatus!
    var carStatus: DocStatus!
    var userId: String = ""
    
    var descStr: String {
        return "\(model) - \(year) - \(color)"
    }
    
    var carStatusString: String {
        if carStatus == .pending {
            return "You can not use this car as document verification is still pending"
        } else if carStatus == .rejected {
            return "You can not use this car as a document is rejected for the car"
        } else {
            return "You can not use this car as a document has expired"
        }
    }
    
    init() { }
    
    init(_ dict: NSDictionary) {
        id = dict.getStringValue(key: "user_car_id")
        company = dict.getStringValue(key: "car_company")
        model = dict.getStringValue(key: "car_company_model")
        year = dict.getStringValue(key: "year")
        color = dict.getStringValue(key: "color")
        image = dict.getStringValue(key: "car_image")
        userId = dict.getStringValue(key: "user_id")
        availableSeats = dict.getStringValue(key: "available_seats")
        regStatus = DocStatus(dict.getStringValue(key: "registration_status"))
        insuStatus = DocStatus(dict.getStringValue(key: "insurance_card_status"))
        carStatus = DocStatus(dict.getStringValue(key: "car_status"))
    }
    
    init(_ car: CarDetailModel) {
        id = car.id
        company = car.company
        model = car.model
        year = car.year
        color = car.color
        image = car.carImage.isEmpty ? "" : car.carImage[0].imgStr
        availableSeats = car.availableSeats
        regStatus = car.registrationStatus
        insuStatus = car.insuranceStatus
        carStatus = car.carStatus
    }
}
