//
//  BookingReqListModel.swift
//  CabO
//
//  Created by Octos.
//

import Foundation
import UIKit

// MARK: - BookingReqList Model
class BookingReqListModel {
    
    var bookRideId: Int!
    var requestId: Int!
    var userId: Int!
    var img: String!
    var seats: Int!
    var name: String!
    var mobile: String!
    var isInvited: Bool = true
    var status: RideStatus?
    var verificationCode: String!
    
    init(_ dict: NSDictionary) {
        bookRideId = dict.getIntValue(key: "book_ride_id")
        requestId = dict.getIntValue(key: "request_id")
        userId = dict.getIntValue(key: "user_id")
        img = dict.getStringValue(key: "image")
        seats = dict.getIntValue(key: "no_of_seat")
        name = dict.getStringValue(key: "user_name")
        mobile = dict.getStringValue(key: "mobile")
        status = RideStatus(rawValue: dict.getStringValue(key: "status"))
        verificationCode = dict.getStringValue(key: "verification_code")
    }
    
    init(invite dict: NSDictionary) {
        requestId = dict.getIntValue(key: "request_id")
        img = dict.getStringValue(key: "image")
        seats = dict.getIntValue(key: "seats")
        name = dict.getStringValue(key: "user_name")
        isInvited = dict.getBooleanValue(key: "is_invited")
    }
    
}

// MARK: - BookingReqList Cell
class BookingReqListCell: ConstrainedTableViewCell {
    
    /// Outlets
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblSeatReq: UILabel!
    @IBOutlet weak var imgSeat: UIImageView!
    @IBOutlet weak var btnCompleted: UIButton!
    
    @IBOutlet weak var vwInvited: UIView!
    @IBOutlet weak var vwArrowRight: UIView!
    @IBOutlet weak var vwStartRide: UIView!
    @IBOutlet weak var vwEndRide: UIView!
    @IBOutlet weak var vwCompleted: UIView!
    @IBOutlet weak var vwMessage: UIView!
    @IBOutlet weak var btnRateReview: UIButton!
    
    @IBOutlet weak var centerConstant: NSLayoutConstraint!
    
    /// Variables
    var action_start_ride: (() -> ())?
    var action_end_ride: (() -> ())?
    var action_msg_driver: (() -> ())?
    var action_review_driver: (() -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        vwInvited.isHidden = true
        vwArrowRight.isHidden = true
        vwStartRide.isHidden = true
        vwEndRide.isHidden = true
        vwCompleted.isHidden = true
        vwMessage.isHidden = true
        btnRateReview.isHidden = true
    }
    
    func prepareUI(_ rider: BookingReqListModel, _ screenType: BookingRequestListScreenType, isRider: Bool) {
        lblName.text = rider.name
        lblSeatReq.text = "Seat \(screenType == .booked ? "booked" : "required") - \(rider.seats!)"
        lblSeatReq.textColor = AppColor.primaryText
        imgSeat.isHidden = false
        btnRateReview.isHidden = true
        
        if screenType == .invites {
            vwInvited.isHidden = !rider.isInvited
            vwArrowRight.isHidden = rider.isInvited
        } else {
            vwInvited.isHidden = true
            vwArrowRight.isHidden = false
        }
        
        if rider.img.isEmpty {
            imgView.image = _userPlaceImage
        } else {
            imgView.loadFromUrlString(rider.img, placeholder: _userPlaceImage)
        }
        
        if isRider {
            vwMessage.isHidden = true
            vwInvited.isHidden = true
            vwStartRide.isHidden = true
            vwEndRide.isHidden = true
            vwCompleted.isHidden = true
        } else if let status = rider.status {
            vwStartRide.isHidden = status != .ontheway
            vwEndRide.isHidden = status != .started
            btnCompleted.setTitle(status.title, for: .normal)
            btnCompleted.setTitleColor(status.color, for: .normal)
            vwCompleted.isHidden = (status != .completed && status != .cancelled && status != .autoCancelled)
        }
    }
    
    func prepareDriverUI(_ driver: DriverModel, reviewGiven: Bool = true) {
        lblName.text = driver.fullName
        lblSeatReq.text = "Your driver"
        lblSeatReq.textColor = AppColor.themeGreen
        
        vwInvited.isHidden = true
        vwArrowRight.isHidden = true
        imgSeat.isHidden = true
        
        vwMessage.isHidden = false
        btnRateReview.isHidden = reviewGiven
        centerConstant.constant = reviewGiven ? 0 : (-18 * _widthRatio)
        
        if driver.img.isEmpty {
            imgView.image = _userPlaceImage
        } else {
            imgView.loadFromUrlString(driver.img, placeholder: _userPlaceImage)
        }
    }
    
    @IBAction func button_start_ride(_ sender: UIButton) {
        action_start_ride?()
    }
    
    @IBAction func button_end_ride(_ sender: UIButton) {
        action_end_ride?()
    }
    
    @IBAction func button_msg_driver(_ sender: UIButton) {
        action_msg_driver?()
    }
    
    @IBAction func button_review(_ sender: UIButton) {
        action_review_driver?()
    }
}
