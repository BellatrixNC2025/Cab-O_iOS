//
//  SideMenuModel.swift
//  CabO
//
//  Created by OctosMac on 25/06/25.
//

import Foundation
import UIKit
// MARK: - Side Menu Sections
enum SideMenuSections: CaseIterable {
    case userDetails, accounts, version
    
    var title: String {
        switch self {
        default: return ""
        }
    }
    
    var arrCells: [SideMenuCells] {
        switch self {
        case .userDetails: return [.userDetails]
        case .accounts:
            if _user!.role == .driver {
                return [.accSetting, .wallet, .myRides, .rideHistory, .subscription, .document, .carDetails, .autoDetails, .driverDetails, .insurance, .paymentMethods, .supportCenter,.logout]
            }else if _user?.role == .rider{
                return [.accSetting, .wallet, .myRides, .myRideRequests, .rideHistory, .paymentMethods, .supportCenter,.logout]
            }else if _user?.role == .subDriver{
                return [.accSetting, .wallet, .rideHistory, .document, .carDetails, .autoDetails, .driverDetails, .insurance, .paymentMethods, .supportCenter,.logout]
            }else{
                return [.accSetting, .wallet, .myRides, .rideHistory, .paymentMethods, .supportCenter,.logout]
            }
            
        case .version: return [.version]
        }
    }
}

// MARK: - ProfileMenu Cells
enum SideMenuCells {
    case userDetails, accSetting, wallet, myRides, myRideRequests, rideHistory, subscription, document, carDetails, autoDetails, driverDetails, insurance, paymentMethods, supportCenter, logout, version
    

    var celld: String {
        switch self {
        case .userDetails: return "userDetailCell"
        case .version: return "versionCell"
        default: return "sideMenuCell"
        }
    }
    
    var title: String {
        switch self {
        case .accSetting: return "Profile & Account Settings"
        case .wallet: return "Cab-O Wallet"
        case .myRides: return "My Rides"
        case .myRideRequests: return "My Rides Requests"
        case .rideHistory: return "My Rides History"
        case .subscription: return "Subscription Plan"
        case .document: return "Documents Center"
        case .carDetails: return "Manage Cars"
        case .autoDetails: return "Manage Auto"
        case .driverDetails: return "Manage Drivers"
        case .insurance: return "Insurance"
        case .paymentMethods: return "Payment methods"
        case .supportCenter: return "Support center"
        case .logout: return "Logout"
        default: return ""
        }
    }
    
    var leftImg: UIImage? {
        switch self {
        case .accSetting: return UIImage(named: "ic_menu_profile")
        case .wallet: return UIImage(named: "ic_menu_wallet")
        case .myRides: return UIImage(named: "ic_menu_myrides")
        case .rideHistory: return UIImage(named: "ic_menu_ride_history")
        case .subscription, .myRideRequests: return UIImage(named: "ic_menu_subscription")
        case .document: return UIImage(named: "ic_menu_document")
        case .carDetails: return UIImage(named: "ic_menu_cars")
        case .autoDetails: return UIImage(named: "ic_menu_auto")
        case .driverDetails: return UIImage(named: "ic_menu_drive")
        case .insurance: return UIImage(named: "ic_menu_insurance")
        case .paymentMethods: return UIImage(named: "ic_menu_payment")
        case .supportCenter:return UIImage(named: "ic_menu_support")
        case .logout: return UIImage(named: "ic_menu_logout")
        default : return nil
        }
    }
}

//MARK: - ProfileMenuCell
class SideMenuCell: ConstrainedTableViewCell {
    
    /// Outlets
    @IBOutlet weak var imgLeft: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgRight: UIImageView!
    @IBOutlet weak var btnLogout: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var stackBtns: UIStackView!
    @IBOutlet weak var vwseperator: UIView!
    
    /// Outlets
    @IBOutlet weak var imgUserProfile: UIImageView!
    @IBOutlet weak var imgVerifyBadgeRight: UIImageView!
    @IBOutlet weak var labelReviews: UILabel!
    @IBOutlet weak var labelRatings: UILabel!
    @IBOutlet weak var labelUserName: UILabel!
    @IBOutlet weak var vwCompleteProfile: UIView!
    @IBOutlet weak var labelPercentage: UILabel!
    @IBOutlet  var vwProgress: CircularProgressView!
    
    /// Variables
    var btnLogoutTap: (() -> ())?
    var btnReviewTap: (() -> ())?
    
    weak var parent: ProfileVC!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        btnLogout?.setViewWidth(width: (DeviceType.iPad ? 124 : 104) * _heightRatio)
        stackBtns?.setViewHeight(height: (DeviceType.iPad ? 40 : 32) * _widthRatio)
        imgLeft?.setViewHeight(height: (DeviceType.iPad ? 26 : 20) * _widthRatio)
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func prepareUI(_ cellType: SideMenuCells) {

        if cellType == .userDetails {
//            vwProgress = CircularProgressView(frame: vwProgress.bounds, lineWidth: 4.0, rounded: true)
//            vwProgress.backgroundColor = AppColor.vwBgColor
            vwProgress.backgroundColor = .red
            vwProgress.trackColor = AppColor.placeholderText
            vwProgress.progressColor = AppColor.appBg
            vwProgress.progress = 0.4
            labelUserName.text = _user?.fullName
            labelPercentage.text = "40%"
            labelRatings.text = "5.0"
            labelReviews.text = "4 Review(s)"
            imgUserProfile.image =  UIImage(named: "user_place")
            imgUserProfile.loadFromUrlString(_user?.profilePic, placeholder: _userPlaceImage)
        } else if cellType == .version {
            lblTitle?.text = getAppVersionAndBuild()
        } else {
            imgLeft?.image = cellType.leftImg?.withTintColor(AppColor.primaryTextDark) ?? UIImage()
            lblTitle?.text = cellType.title
        }
        self.layoutIfNeeded()
    }
    
    @IBAction func btnRightTap(_ sender: UIButton) {
        let _ = AppThemePopupView.initWith()
    }
    
   
}
