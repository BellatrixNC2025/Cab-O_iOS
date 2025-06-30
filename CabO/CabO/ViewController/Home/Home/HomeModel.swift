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
    
    /// Variables
    var toggleSwitch: ((Bool) -> ())?
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    @IBAction func switchValueChange(_ sender: UISwitch) {
        toggleSwitch?(sender.isOn)
    }
    
    func prepareUI(_ title: String, _ desc: String, _ img: UIImage) {
        lblTitle.text = title
        lblDesc.text = desc
        imgView.image = img
//        switchRide.isHidden = true
        btnNext.isHidden = true
    }
}

// MARK: - HomeCellType ENUM
enum HomeCellType {
    case taxi, carpool, postRide
    
    var title: String {
        switch self {
        case .taxi: return "Find a Taxi"
        case .carpool: return "Find a Carpool"
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
}
