//
//  HomeModel.swift
//  CabO
//
//  Created by Octos.
//

import Foundation
import UIKit

//MARK: - HomeCreateRideCell
class HomeCreateRideCell: ConstrainedTableViewCell {
    
    /// Outlets
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func prepareUI(_ title: String, _ desc: String, _ img: UIImage) {
        lblTitle.text = title
        lblDesc.text = desc
        imgView.image = img
    }
}

// MARK: - HomeCreateRideCVC
class HomeCreateRideCVC: ConstrainedCollectionViewCell {
    
    @IBOutlet var switchRide: UISwitch!
    @IBOutlet var btnNext: NRoundShadowButton!
    /// Outlets
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    
    @IBOutlet var vwBg: NRoundShadowView!
    /// Variables
    var toggleSwitch: ((Bool) -> ())?
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    @IBAction func switchValueChange(_ sender: UISwitch) {
        toggleSwitch?(sender.isOn)
    }
    
    func prepareUI(_ type : HomeCellType, isPostEnable: Bool) {
        lblTitle.text = type.title
        lblDesc.text = type.desc
        imgView.image = type.img
        switchRide.isHidden = type.isSwitch
        btnNext.isHidden = true
        if _user?.role == .rider {
            switchRide.superview?.isHidden = true
        }
        if type ==  .postRide{
            vwBg.backgroundColor = isPostEnable ? vwBg.backgroundColor :vwBg.backgroundColor?.withAlphaComponent(0.5)
            vwBg.isUserInteractionEnabled = isPostEnable ? true : false
        }
    }
}

// MARK: - HomeCellType ENUM
enum HomeCellType : CaseIterable{
    case taxi, carpool, postRide
    
    var title: String {
        switch self {
        case .taxi: return _user?.role == .rider ? "Find a Taxi" : "Taxi"
        case .carpool: return _user?.role == .rider ? "Find a Carpool" : "Carpool"
        case .postRide: return "Post a Ride"
        }
    }
    
    var desc: String {
        switch self {
        case .taxi: return "In City"
        case .carpool: return "Outside City"
        case .postRide: return ""
        }
    }
    
    var img: UIImage {
        switch self {
        case .taxi: return UIImage(named: "ic_taxi_home")!
        case .carpool: return UIImage(named: "ic_carpool")!
        case .postRide: return UIImage(named: "ic_post_ride")!
        }
    }
    var isSwitch : Bool {
        switch self {
        case .taxi: return  false
        case .carpool: return false
        case .postRide: return true
        }
    }
}
