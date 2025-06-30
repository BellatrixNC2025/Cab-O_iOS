//
//  CarDetailsModel.swift
//  CabO
//
//  Created by Octos.
//

import Foundation
import UIKit

// MARK: - CarDetail Model
class CarDetailModel {
    
    var id: String = ""
    var userId: String = ""
    var companyId: String = ""
    var company: String = ""
    var modelId: String = ""
    var model: String = ""
    var yearId: String = ""
    var year: String = ""
    var colorId: String = ""
    var color: String = ""
    var availableSeats: String = ""
    var carImage: [CarImageModel] = []
    var licencePlate: String = ""
    var registrationStatus: DocStatus!
    var regImage: String = ""
    var regRejectStr: String = ""
    var insuranceStatus: DocStatus!
    var insImage: String = ""
    var insRejectStr: String = ""
    var carStatus: DocStatus?
    var is_editable: Bool!
    
    var descStr: String {
        return "\(model) - \(year) - \(color)"
    }
    
    var registrationImage: UIImage? {
        var img: UIImage?
        loadImage(from: regImage) { image in
            img = image
        }
        return img
    }
    
    var insuranceImage: UIImage? {
        var img: UIImage?
        loadImage(from: insImage) { image in
            img = image
        }
        return img
    }
    
    init() { }
    
    init(_ dict: NSDictionary) {
        id = dict.getStringValue(key: "user_car_id")
        if id.isEmpty {
            id = dict.getStringValue(key: "car_id")
        }
        userId = dict.getStringValue(key: "user_id")
        companyId = dict.getStringValue(key: "car_company_id")
        company = dict.getStringValue(key: "car_company")
        modelId = dict.getStringValue(key: "car_company_model_id")
        model = dict.getStringValue(key: "car_company_model")
        yearId = dict.getStringValue(key: "car_manufacture_year_id")
        year = dict.getStringValue(key: "year")
        colorId = dict.getStringValue(key: "car_company_model_color_id")
        color = dict.getStringValue(key: "color")
        availableSeats = dict.getStringValue(key: "available_seats")
        licencePlate = dict.getStringValue(key: "licence_plate")
        registrationStatus = DocStatus(dict.getStringValue(key: "registration_status"))
        regImage = dict.getStringValue(key: "registration_image")
        regRejectStr = dict.getStringValue(key: "registration_reject_reason")
        insuranceStatus = DocStatus(dict.getStringValue(key: "insurance_card_status"))
        carStatus = DocStatus(dict.getStringValue(key: "car_status"))
        insImage = dict.getStringValue(key: "insurance_card")
        insRejectStr = dict.getStringValue(key: "insurance_reject_reason")
        is_editable = dict.getBooleanValue(key: "is_editable")
        
        if let imgs = dict["car_image"] as? [NSDictionary] {
            for img in imgs {
                carImage.append(CarImageModel(img))
            }
        }
    }
    
    func getValue(_ cellType: CarDetailsCellype) -> String {
        switch cellType {
        case .name: return company
        case .makeColor: return descStr
        case .documentTitle: return "Documents"
        default: return ""
        }
    }
}

// MARK: - CarImage Model
struct CarImageModel {
    
    var id:String
    var userCarId: String
    var imgStr: String
    
    var img: UIImage? {
        var img: UIImage?
        loadImage(from: imgStr) { image in
            img = image
        }
        return img
    }
    
    init(_ dict: NSDictionary) {
        id = dict.getStringValue(key: "id")
        userCarId = dict.getStringValue(key: "user_car_id")
        imgStr = dict.getStringValue(key: "car_image")
    }
}

// MARK: - CarDetails Cellype
enum CarDetailsCellype: CaseIterable {
    case images, name, makeColor, licenceAndSeats, documentTitle, registration, insurance
    
    var cellId: String {
        switch self {
        case .images: return SliderView.identifier
        case .licenceAndSeats: return "licenceAndSeatCell"
        case .registration, .insurance: return "documentCell"
        default: return TitleTVC.identifier
        }
    }
    
    var cellHeight: CGFloat {
        switch self {
        case .images: return (DeviceType.iPad ? 324 : 246) * _widthRatio
        case .licenceAndSeats: return 70 * _widthRatio
//        case .insurance, .registration: return 244 * _widthRatio
        default: return UITableView.automaticDimension
        }
    }
    
    var titleFont: UIFont {
        switch self {
        case .name: return AppFont.fontWithName(.mediumFont, size: 24 * _fontRatio)
        case .makeColor: return AppFont.fontWithName(.regular, size: 14 * _fontRatio)
        default: return AppFont.fontWithName(.mediumFont, size: 16 * _fontRatio)
        }
    }
}
