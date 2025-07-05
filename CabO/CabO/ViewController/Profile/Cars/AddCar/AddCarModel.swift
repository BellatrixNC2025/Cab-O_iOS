//
//  AddCarModel.swift
//  CabO
//
//  Created by Octos.
//

import Foundation
import UIKit

// MARK: - AddCarCellType
enum AddCarCellType {
    case addcarImage, imageCollection,type, make, model, yearAndColor, licencePlate, availableSeat, uploadDocTitle, carRegTitle, carRegistration, insuranceTitle, insurance, info, btn
    
    var cellId: String {
        switch self {
        case .addcarImage: return "addCarImageCell"
        case .imageCollection: return ImageCollectionCell.identifier
        case .info: return "infoCell"
        case .carRegistration, .insurance: return "documentPickerCell"
        case .uploadDocTitle: return TitleTVC.identifier
        case .carRegTitle, .insuranceTitle: return "titleStatusCell"
        case .yearAndColor: return DualInputCell.identifier
        case .availableSeat: return AvailableSeatsCell.identifier
        case .btn: return ButtonTableCell.identifier
        default: return InputCell.identifier
        }
    }
    
    var cellHeight: CGFloat {
        switch self {
        case .info: return UITableView.automaticDimension
        case .carRegistration, .insurance: return (DeviceType.iPad ? 264 : 196) * _widthRatio
        case .yearAndColor: return DualInputCell.normalHeight + 8
        case .availableSeat: return AvailableSeatsCell.cellHeight
        case .btn: return ButtonTableCell.cellHeight
        default: return InputCell.normalHeight
        }
    }
    
    var title: (String, String) {
        switch self {
        case .uploadDocTitle: return ("Upload Car RC Book","")
        case .carRegistration: return ("Front side of your RC","")
        case .insurance: return ("Back side of your RC","")
        case .type: return ("Car Type","")
        case .make: return ("Make","")
        case .model: return ("Model","")
        case .yearAndColor: return ("Year","Color")
        case .licencePlate: return ("Licence plate","")
        default: return ("", "")
        }
    }
    
    var placeholder: (String, String) {
        switch self {
        case .type: return ("Select type","")
        case .make: return ("Select make","")
        case .model: return ("Select model","")
        case .yearAndColor: return ("Select","Select")
        case .licencePlate: return ("Enter licence plate number","")
        default: return ("","")
        }
    }
    
    var returnKeyType: UIReturnKeyType {
        switch self {
        case .licencePlate: return .done
        default: return .next
        }
    }
    
    var infoText: String {
        switch self {
        case .model: return "Ex. Ford Focus, Toyota, Hundai"
        default: return ""
        }
    }
}

// MARK: - AddCarModel
class AddCarModel {
    
    var id: String?
    var carType : String = ""
    var carCompany: CarCompanyModel? {
        didSet {
            self.carModel = nil
            self.carYear = nil
            self.carColor = nil
        }
    }
    var carModel: CarNameModel? {
        didSet {
            self.carYear = nil
            self.carColor = nil
        }
    }
    var carYear: CarYearModel? {
        didSet {
            self.carColor = nil
        }
    }
    var carColor: CarColorModel?
    var licencePlate: String = ""
    var seats: Int?
    var registrationImage: UIImage?
    var registrationImageStr: String?
    var registrationStatus: DocStatus?
    var insuranceImage: UIImage?
    var insuranceImageStr: String?
    var insuranceStatus: DocStatus?
    var carImages: [UIImage] = []
    var editCarImages: [Any] = []
    
    init() { }
    
    init(_ car: CarDetailModel) {
        id = car.id
        carCompany = CarCompanyModel(car.companyId, car.company)
        carModel = CarNameModel(car.modelId, car.model)
        carYear = CarYearModel(car.yearId, car.year)
        carColor = CarColorModel(car.colorId, car.color)
        licencePlate = car.licencePlate
        seats = car.availableSeats.integerValue
        editCarImages = car.carImage
        registrationImageStr = car.regImage
//        registrationImage = car.registrationImage
        registrationStatus = car.registrationStatus
        insuranceImageStr = car.insImage
//        insuranceImage = car.insuranceImage
        insuranceStatus = car.insuranceStatus
    }
    
    var addParam: [String: Any] {
        var param: [String: Any] = [:]
        param["car_company_id"] = carCompany!.id
        param["car_company_model_id"] = carModel!.id
        param["car_manufacture_year_id"] = carYear!.id
        param["car_company_model_color_id"] = carColor!.id
        param["licence_plate"] = licencePlate
        param["available_seats"] = "\(seats!)"
        return param
    }
    
    func isValid() -> (Bool, String) {
        if carImages.isEmpty {
            return (false, "Please upload atleast one car image")
        } else if carCompany == nil {
            return (false, "Please select make of car")
        } else if carModel == nil {
            return (false, "please select model of car")
        } else if carYear == nil {
            return (false, "Please select year of car")
        } else if carColor == nil {
            return (false, "Please select color of car")
        } else if licencePlate.isEmpty {
            return (false, "Please enter licence plate number")
        } else if seats == nil {
            return (false, "Please select seats available")
        } else if registrationImage == nil {
            return (false, "Please select the registration image")
        } else if insuranceImage == nil {
            return (false, "Please select the insurance image")
        }
        return (true, "")
    }
    
    func isEditValid() -> (Bool, String) {
        if editCarImages.isEmpty {
            return (false, "Please upload atleast one car image")
        } else if carCompany == nil {
            return (false, "Please select make of car")
        } else if carModel == nil {
            return (false, "please select model of car")
        } else if carYear == nil {
            return (false, "Please select year of car")
        } else if carColor == nil {
            return (false, "Please select color of car")
        } else if licencePlate.isEmpty {
            return (false, "Please enter licence plate")
        } else if seats == nil {
            return (false, "Please select seats available")
        } else if registrationImage == nil && registrationImageStr == nil {
            return (false, "Please select the registration image")
        } else if insuranceImage == nil && insuranceImageStr == nil {
            return (false, "Please select the insurance image")
        }
        return (true, "")
    }
    
    func getValue(_ cellType: AddCarCellType) -> String {
        switch cellType {
        case .make: return carCompany?.name ?? ""
        case .model: return carModel?.name ?? ""
        case .licencePlate: return licencePlate
        default: return ""
        }
    }
    
    func setValue(_ str: String, _ cellType: AddCarCellType) {
        switch cellType {
        case .licencePlate: licencePlate = str
            default: break
        }
    }
}

// MARK: - CarCompanyModel
struct CarCompanyModel {
    
    var id: String = ""
    var name: String = ""
    
    init(_ id: String, _ name: String) {
        self.id = id
        self.name = name
    }
    
    init(_ dict: NSDictionary) {
        id = dict.getStringValue(key: "id")
        name = dict.getStringValue(key: "name")
    }
}

// MARK: - CarNameModel
struct CarNameModel {
    
    var id: String = ""
    var name: String = ""
    
    init(_ id: String, _ name: String) {
        self.id = id
        self.name = name
    }
    
    init(_ dict: NSDictionary) {
        id = dict.getStringValue(key: "id")
        name = dict.getStringValue(key: "name")
    }
}

// MARK: - CarYearModel
struct CarYearModel {
    
    var id: String = ""
    var year: String = ""
    
    init(_ id: String, _ year: String) {
        self.id = id
        self.year = year
    }
    
    init(_ dict: NSDictionary) {
        id = dict.getStringValue(key: "id")
        year = dict.getStringValue(key: "year")
    }
}

// MARK: - CarColorModel
struct CarColorModel {
    
    var id: String = ""
    var color: String = ""
    
    init(_ id: String, _ color: String) {
        self.id = id
        self.color = color
    }
    
    init(_ dict: NSDictionary) {
        id = dict.getStringValue(key: "id")
        color = dict.getStringValue(key: "color")
    }
}
