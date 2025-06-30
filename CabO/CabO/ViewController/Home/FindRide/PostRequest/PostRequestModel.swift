//
//  PostRequestModel.swift
//  CabO
//
//  Created by Octos.
//

import Foundation
import UIKit

// MARK: - PostRequest Model
class PostRequestModel {
    
    var id: Int?
    var start: SearchAddress?
    var dest: SearchAddress?
    var rideDate: Date = Date()
    var seatReq: Int?
    var message: String = ""
    
    var isDateChange: Bool = false
    
    func swapStartDest() {
        swap(&start, &dest)
    }
    
    init() { }
    
    init(_ findRide: FindRideModel) {
        start = findRide.start
        dest = findRide.dest
        rideDate = findRide.rideDate
    }
    
    init(_ req: RequestModel) {
        id = req.reqId
        start = req.start
        dest = req.dest
        rideDate = req.date
        seatReq = req.seats
        message = req.desc
    }
    
    func isValidData() -> (Bool, String) {
        if start == nil {
            return (false, "Please select a source location first")
        } else if dest == nil {
            return (false, "Please select a destination first")
        } else if seatReq == nil {
            return (false, "Please select the no of seats required")
        }
        return (true, "")
    }
    
    var postReqParam: [String: Any] {
        var param: [String: Any] = [:]
        if let id {
            param["request_id"] = id
        }
        param["no_of_seat"] = seatReq
        if isDateChange {
            param["date"] = rideDate.converDisplayDateFormet()
        } else {
            param["date"] = Date.formattedString(from: rideDate, format: DateFormat.serverDateFormat)
        }
        param["ride_description"] = message
        param.merge(with: start!.fromParam)
        param.merge(with: dest!.toParam)
        param.merge(with: Setting.deviceInfo)
        return param
    }
}

// MARK: - Request Model
class RequestModel {
    
    var start: SearchAddress?
    var dest: SearchAddress?
    var date: Date!
    var invitation: Int!
    var reqId: Int!
    var userId: Int!
    var desc: String!
    var seats: Int!
    var driver: DriverModel?
    
    init(_ dict: NSDictionary) {
        date = Date.dateFromServerFormat(from: dict.getStringValue(key: "date"), format: DateFormat.serverDateTimeFormat)
        start = SearchAddress(fromDict: dict)
        dest = SearchAddress(toDict: dict)
        desc = dict.getStringValue(key: "ride_description")
        invitation = dict.getIntValue(key: "invitations")
        seats = dict.getIntValue(key: "seats")
        reqId = dict.getIntValue(key: "request_id")
        userId = dict.getIntValue(key: "user_id")
        if let driv = dict["ride_driver"] as? NSDictionary {
            driver = DriverModel(driv)
        }
    }
    
}

// MARK: - RequestDetail CellType
enum RequestDetailCellType {
    case trip, seat, invitaion, msg, driver
    
    var cellId: String {
        switch self {
        case .trip: return "tripInfoCell"
        case .driver: return "driverDetailCell"
        default: return "tripdetailCell"
        }
    }
    
    var title: String {
        switch self {
        case .invitaion: return "Invitations"
        case .seat: return "Seat required"
        case .msg: return "Message"
        default: return ""
        }
    }
    
    var img: UIImage? {
        switch self {
        case .invitaion: return UIImage(systemName: "paperplane")
        case .seat: return UIImage(named: "ic_seat")?.withTintColor(AppColor.primaryText)
        case .msg: return UIImage(systemName: "message")
        default: return nil
        }
    }
}

// MARK: - RequestDetail ScreenType
enum RequestDetailScreenType {
    case carpool, my
}

// MARK: - RequestDetail Cell
class RequestDetailCell: ConstrainedTableViewCell {
    
    /// Outlets
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblStartLoc: UILabel!
    @IBOutlet weak var lblDestLoc: UILabel!
    @IBOutlet weak var stackTripInfo: UIStackView!
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblCount: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    
    @IBOutlet weak var lblCancelTitle: UILabel!
    @IBOutlet weak var lblCancelHeader: UILabel!
    
    @IBOutlet weak var lblReview: UILabel!
    @IBOutlet weak var lblRating: UILabel!
    @IBOutlet weak var viewRating: UIView!
    
    @IBOutlet weak var vwRejectMessag: UIStackView!
    
    @IBOutlet weak var vwMessageUser: UIView!
    @IBOutlet weak var vwSupportUser: UIView!
    @IBOutlet weak var vwRightArrow: UIView!
    
    @IBOutlet weak var imgRideStart: UIImageView!
    @IBOutlet weak var imgRideEnd: UIImageView!
    
    /// Variables
    weak var delegate: ParentVC!
    var action_message_user: (() -> ())?
    var action_support_center: (() -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        stackTripInfo?.spacing = (DeviceType.iPad ? 8 : 4) * _widthRatio
        imgRideStart?.setViewHeight(height: (DeviceType.iPad ? 22 : 18) * _widthRatio)
        imgRideEnd?.setViewHeight(height: (DeviceType.iPad ? 22 : 18) * _widthRatio)
    }
    
    func prepareUI(_ cellType: RequestDetailCellType) {
        let parent = delegate as! RequestDetailVC
        if cellType == .trip {
            lblStartLoc.text = parent.data.start?.customAddress
            lblDestLoc.text = parent.data.dest?.customAddress
            lblDate.text = Date.formattedString(from: parent.data.date, format: DateFormat.format_MMMMddyyyy)
        }
        else if cellType == .driver {
            lblTitle?.text = parent.data.driver?.fullName
            if let img = parent.data.driver?.img {
                imgView?.loadFromUrlString(img, placeholder: _userPlaceImage)
            }
            if let driver = parent.data.driver {
                lblReview.text = driver.reviewCount
                lblRating.text = driver.averageRating.stringValues
                viewRating.isHidden = driver.totalReview == 0
            }
            
            vwRightArrow?.isHidden = false
            vwSupportUser?.isHidden = false
            vwMessageUser?.isHidden = false
        }
        else {
            lblDesc?.isHidden = cellType != .msg
            lblCount?.isHidden = cellType == .msg
            lblCount?.text = cellType == .invitaion ? parent.data.invitation.stringValue : cellType == .seat ? parent.data.seats.stringValue : ""
            lblTitle?.text = cellType.title
            lblDesc?.text = parent.data.desc
            imgView?.image = cellType.img
        }
    }
    
    func prepareUI(_ cellType: BookingRequestDetailCellType) {
        let parent = delegate as! BookingRequestDetailVC
        imgView?.image = cellType.img
        if cellType == .trip {
            lblStartLoc.text = parent.data.fromLoc
            lblDestLoc.text = parent.data.toLoc
            lblDate.text = parent.data.dateTimeStr
        }
        else if cellType == .driver {
            lblTitle?.text = parent.screenType == .invites ? parent.data.driver?.fullName : parent.data.fullName
            if parent.screenType == .invites {
                if let driver = parent.data.driver {
                    lblReview.text = driver.reviewCount
                    lblRating.text = driver.averageRating.stringValues
                    viewRating.isHidden = driver.totalReview == 0
                }
            } else {
                lblReview.text = parent.data.reviewCountString
                lblRating.text = parent.data.userAvgRating.stringValues
                viewRating.isHidden = parent.data.userTotalReviews == 0
            }
            
            vwRightArrow?.isHidden = parent.screenType == .booked
            vwSupportUser?.isHidden = !(parent.screenType == .booked && parent.data.status == .ontheway)
            vwMessageUser?.isHidden = !(parent.screenType == .booked && EnumHelper.checkCases(parent.data.status, cases: [.accepted, .ontheway, .started]))
            
            if parent.screenType == .invites {
                if let img = parent.data.driver?.img {
                    imgView?.loadFromUrlString(img, placeholder: _userPlaceImage)
                } else {
                    imgView.image = _userPlaceImage
                }
            } else {
                if !parent.data.image.isEmpty {
                    imgView?.loadFromUrlString(parent.data.image, placeholder: _userPlaceImage)
                } else {
                    imgView.image = _userPlaceImage
                }
            }
        }
        else if cellType == .msg {
            if parent.screenType == .invites {
                if let driver = parent.data.driver {
                    lblTitle?.text = "Message from \(driver.fName!)"
                }
                lblDesc?.text = parent.data.msg
                lblCount?.isHidden = true
            } else {
                lblTitle?.text = "Message from \(parent.data.firstName!)"
                lblDesc?.text = parent.data.msg
                lblCount?.isHidden = true
            }
        }
        else if cellType == .transaction {
            lblTitle?.text = cellType.title
            imgView?.image = cellType.img
            lblDesc?.text = "₹\(parent.data.price.stringValues)"
        }
        else if cellType == .reject {
            lblCancelHeader?.text = "Reason for reject"
            lblTitle?.text = parent.data.rejectReason
            lblDesc?.text = parent.data.rejectMessage
            vwRejectMessag?.isHidden = !parent.data.isOtherReason
        }
        else if cellType == .cancel {
            lblCancelHeader?.text = "Reason for cancel"
            lblTitle?.text = parent.data.rejectReason
            lblDesc?.text = parent.data.rejectMessage
            vwRejectMessag?.isHidden = !parent.data.isOtherReason
        }
        else if cellType == .seat {
            lblCount?.isHidden = false
            lblDesc?.isHidden = true
            lblTitle?.text = parent.screenType == .booked ? "Seat booked" : "Seat required"
            lblCount?.text = parent.data.seatReq.stringValue
        }
        else {
            lblDesc?.isHidden = cellType != .msg
            lblCount?.isHidden = cellType != .seat
            lblTitle?.text = cellType.title
            lblDesc?.text = parent.data.msg
            imgView?.image = cellType.img
        }
    }
    
    @IBAction func btn_messageTap(_ sender: UIButton) {
        action_message_user?()
    }
    
    @IBAction func btn_supportTap(_ sender: UIButton) {
        action_support_center?()
    }
}
