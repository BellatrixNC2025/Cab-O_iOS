//
//  UserDetailModel.swift
//  CabO
//
//  Created by Octos.
//

import Foundation
import UIKit

// MARK: - UserDetail Model
class UserDetailModel {
    
    var userId: Int!
    var fName: String!
    var lName: String!
    var image: String!
    var joinDate: Date!
    var email: String!
    var mobile: String!
    var rideDriven: Int!
    var rideTaken: Int!
    var kmShared: Double!
    var bio: String!
    var licenceStatus: DocStatus!
    var carStatus: DocStatus!
    var fbLink: String!
    var instaLink: String!
    var twiterLink: String!
    var totalReview: Int!
    var rating: Double!
    
    var reviewCountStr: String {
        return "\(totalReview!) \(totalReview == 1 ? "Review" : "Reviews")"
    }
    
    var fullName: String {
        return fName + " " + lName
    }
    
    init(_ dict: NSDictionary) {
        userId = dict.getIntValue(key: "user_id")
        fName = dict.getStringValue(key: "first_name")
        lName = dict.getStringValue(key: "last_name")
        image = dict.getStringValue(key: "image")
        joinDate = Date.dateFromServerFormat(from: dict.getStringValue(key: "created_at"))
        email = dict.getStringValue(key: "email")
        mobile = dict.getStringValue(key: "mobile")
        rideDriven = dict.getIntValue(key: "ride_driven")
        rideTaken = dict.getIntValue(key: "ride_taken")
        kmShared = dict.getDoubleValue(key: "km_shared").rounded(toPlaces: 2)
        bio = dict.getStringValue(key: "something_about_you")
        licenceStatus = DocStatus(dict.getStringValue(key: "driving_license"))
        carStatus = DocStatus(dict.getStringValue(key: "car_status"))
        fbLink = dict.getStringValue(key: "facebook_url")
        instaLink = dict.getStringValue(key: "instagram_url")
        twiterLink = dict.getStringValue(key: "twitter_url")
        totalReview = dict.getIntValue(key: "total_review")
        rating = dict.getDoubleValue(key: "average_rating").rounded(toPlaces: 1)
    }
}

// MARK: - UserDetail CellType
enum UserDetailCellType {
    case info, count, verification, bio, social
    
    var cellId: String {
        switch self {
        case .info: return "userInfo"
        case .count: return "countCell"
        case .verification: return "infoVerifyCell"
        case .bio: return "bioCell"
        case .social: return "socialLinkCell"
        }
    }
    
    var cellHeight: CGFloat {
        switch self {
        case .info: return 86 * _widthRatio
        case .count: return 80 * _widthRatio
        case .verification: return 72 * _widthRatio
        default: return UITableView.automaticDimension
        }
    }
}

// MARK: - UserDetail Cell
class UserDetailCell: ConstrainedTableViewCell {
    
    /// Outlets
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var lblReviews: UILabel!
    @IBOutlet weak var lblRating: UILabel!
    @IBOutlet weak var btnVerifyBadge: UIButton!
    @IBOutlet weak var viewRating: UIView!
    
    @IBOutlet weak var vwRideDriven: UIView!
    @IBOutlet weak var vwRideTaken: UIView!
    @IBOutlet weak var vwKmShared: UIView!
    @IBOutlet weak var vwSpacer: UIView!
    
    @IBOutlet weak var lblRideDriven: UILabel!
    @IBOutlet weak var lblRideTaken: UILabel!
    @IBOutlet weak var lblKmShared: UILabel!
    
    @IBOutlet weak var vwEmail: UIView!
    @IBOutlet weak var vwMobile: UIView!
    @IBOutlet weak var vwLicence: UIView!
    @IBOutlet weak var vwCar: UIView!
    
    @IBOutlet weak var vwLicenceVerify: UIView!
    @IBOutlet weak var vwCarVerify: UIView!
    
    @IBOutlet weak var vwFb: UIView!
    @IBOutlet weak var vwInsta: UIView!
    @IBOutlet weak var vwTwiter: UIView!
    
    @IBOutlet weak var lblFb: UILabel!
    @IBOutlet weak var lblInsta: UILabel!
    @IBOutlet weak var lblTwit: UILabel!
    
    @IBOutlet weak var vwStatusSpacer1: UIView!
    @IBOutlet weak var vwStatusSpacer2: UIView!
    @IBOutlet weak var vwLicenceStatus: NRoundView!
    @IBOutlet weak var imgLicenceStatus: TintImageView!
    @IBOutlet weak var lblLicenceStatus: UILabel!
    
    @IBOutlet weak var vwCarStatus: NRoundView!
    @IBOutlet weak var imgCarStatus: TintImageView!
    @IBOutlet weak var lblCarStatus: UILabel!
    
    /// Variables
    var action_reviews: (() -> ())?
    var action_open_fb: (() -> ())?
    var action_open_insta: (() -> ())?
    var action_open_twiter: (() -> ())?
    var action_call: (() -> ())?
    var action_email: (() -> ())?
    var action_verify_badge: (() -> ())?
    
    weak var parent: UserDetailVC! {
        didSet {
            prepareUI()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func prepareUI() {
        let cellType = parent.arrCells[self.tag]
        let data = parent.data!
        if cellType == .info {
            lblTitle.text = data.fullName
            lblReviews.text = data.reviewCountStr
            lblRating.text = data.rating.stringValues
            lblDesc.text = "Joined \(data.joinDate.getChatSectionHeader())"
            userImage.loadFromUrlString(data.image, placeholder: _userPlaceImage)
            viewRating.isHidden = data.totalReview == 0
            btnVerifyBadge?.isHidden = !parent.isDriver
            
        } else if cellType == .count {
            lblRideDriven.text = data.rideDriven.stringValue
            lblRideTaken.text = data.rideTaken.stringValue
            lblKmShared.text = data.kmShared.formatPoints()
        } else if cellType == .bio {
            lblDesc.text = data.bio
        } else if cellType == .verification {
            vwLicenceStatus.borderColor = data.licenceStatus.enableDisableColor
            vwCarStatus.borderColor = data.carStatus.enableDisableColor
            
            imgLicenceStatus.tintColor = data.licenceStatus.enableDisableColor
            imgCarStatus.tintColor = data.carStatus.enableDisableColor
            
            lblLicenceStatus.textColor = data.licenceStatus.enableDisableColor
            lblCarStatus.textColor = data.carStatus.enableDisableColor
            
        } else if cellType == .social {
            lblFb.text = data.fbLink
            lblInsta.text = data.instaLink
            lblTwit.text = data.twiterLink
            
            vwFb.isHidden = data.fbLink.isEmpty
            vwInsta.isHidden = data.instaLink.isEmpty
            vwTwiter.isHidden = data.twiterLink.isEmpty
        }
        
        if DeviceType.iPhone {
            if cellType == .count {
                vwRideDriven.isHidden = self.tag != 1
                vwRideTaken.isHidden = self.tag != 1
                vwKmShared.isHidden = self.tag == 1
                vwSpacer.isHidden = self.tag == 1
            } else if cellType == .verification {
                vwEmail.isHidden = self.tag != 4
                vwMobile.isHidden = self.tag != 4
                vwLicence.isHidden = self.tag == 4
                vwCar.isHidden = self.tag == 4
            }
        } else {
            if cellType == .count {
                vwRideDriven.isHidden = false
                vwRideTaken.isHidden = false
                vwKmShared.isHidden = false
                vwSpacer.isHidden = true
            } else if cellType == .verification {
                vwEmail.isHidden = self.tag != 3
                vwMobile.isHidden = self.tag != 3
                vwLicence.isHidden = self.tag != 3
                vwStatusSpacer1.isHidden = self.tag == 3
                vwStatusSpacer2.isHidden = self.tag == 3
                vwCar.isHidden = self.tag == 3
            }
        }
    }
    
    @IBAction func btn_reviews_tap(_ sender: UIButton) {
        action_reviews?()
    }
    
    @IBAction func btn_email(_ sender: UIButton) {
        action_email?()
    }
    
    @IBAction func btn_call(_ sender: UIButton) {
        action_call?()
    }
    
    @IBAction func btn_fb(_ sender: UIButton) {
        action_open_fb?()
    }
    
    @IBAction func btn_insta(_ sender: UIButton) {
        action_open_insta?()
    }
    
    @IBAction func btn_twiter(_ sender: UIButton) {
        action_open_twiter?()
    }
    
    @IBAction func btn_verify_badge(_ sender: UIButton) {
        action_verify_badge?()
    }
}
