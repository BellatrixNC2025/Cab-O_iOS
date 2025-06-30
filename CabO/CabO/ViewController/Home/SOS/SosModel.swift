//
//  SosModel.swift
//  CabO
//
//  Created by Octos.
//

import Foundation
import UIKit

// MARK: - Sos CellType
enum SosCellType: CaseIterable {
    case title, info1, info2, car, location, emeType
    
    var cellId: String {
        switch self {
        case .title: return TitleTVC.identifier
        case .info1, .info2: return "infoCell"
        case .car, .location: return "detailCell"
        case .emeType: return "typeCell"
        }
    }
    
    var cellHeight: CGFloat {
        switch self {
        case .car, .location: return UITableView.automaticDimension
        case .emeType: return 110 * _widthRatio
        default: return 24
        }
    }
    
    var img: UIImage? {
        switch self {
        case .car: return UIImage(named: "ic_menu_myrides")
        case .location: return UIImage(named: "ic_ride_dest")
        default: return nil
        }
    }
    
    var title: String {
        switch self {
        case .title: return "Are you in an emergency?"
        case .info1: return "Your emergency contacts and the \(_appName) response team will be notified immediately once you raise an alert."
        case .info2: return "Be very careful and sure while using the SOS service. It is strictly meant for emergencies only."
        case .car: return "Car information"
        case .location: return "Estimated current location"
        case .emeType: return "Type of emergency"
        }
    }
    
    var font: UIFont {
        switch self {
        case .title: return AppFont.fontWithName(.mediumFont, size: 34 * _fontRatio)
        default: return AppFont.fontWithName(.regular, size: 14 * _fontRatio)
        }
    }
}

// MARK: - EmergencyType
class EmergencyType : Equatable{
    
    static func == (lhs: EmergencyType, rhs: EmergencyType) -> Bool {
        return lhs.id == rhs.id
    }
    
    var id: Int!
    var name: String!
    
    init(_ dict: NSDictionary) {
        id = dict.getIntValue(key: "id")
        name = dict.getStringValue(key: "name")
    }
}

// MARK: - SosModel
class SosModel {
    
    var emergencyType: EmergencyType?
    var lat: Double?
    var long: Double?
    var location: String?
    
    var param: [String: Any] {
        var param: [String: Any] = [:]
        param["emergency_type_id"] = emergencyType?.id
        param["latitude"] = lat
        param["longitude"] = long
        param["location"] = location
        param["is_other"] = emergencyType!.name.lowercased() == "other" ? 1 : 0
        param.merge(with: Setting.deviceInfo)
        return param
    }
}

// MARK: - Sos Cell
class SosCell: ConstrainedTableViewCell {
    
    /// Outlets
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    /// Variables
    var arrData: [EmergencyType]! = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    var selectedStatus: EmergencyType?
    var selectionCallBack: ((EmergencyType) -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func registerCell() {
        RideFilterStatusCollectionCell.prepareToRegister(collectionView)
    }
}

// MARK: - Collection Cell
extension SosCell: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let data = arrData[indexPath.row]
        let width = data.name.WidthWithNoConstrainedHeight(font: AppFont.fontWithName(.regular, size: 14 * _fontRatio)) + 24 * _widthRatio
        return CGSize(width: width, height: 34 * _widthRatio)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: RideFilterStatusCollectionCell.identifier, for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let cell = cell as? RideFilterStatusCollectionCell {
            let pref = arrData[indexPath.row]
            cell.prepareUI(pref, pref == selectedStatus)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let pref = arrData[indexPath.row]
        selectedStatus = pref
        selectionCallBack?(pref)
        collectionView.reloadData()
    }
}
