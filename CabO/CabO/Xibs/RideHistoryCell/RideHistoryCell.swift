//
//  RideHistoryCell.swift
//  CabO
//
//  Created by Octos.
//

import UIKit

class RideHistoryCell: ConstrainedTableViewCell {
    
    static let identifier: String = "rideHistoryCell"
    
    /// Outlets
    @IBOutlet weak var viewSeatBooked: UIView!
    @IBOutlet weak var labelSeatBooked: UILabel!
    @IBOutlet weak var viewSeatHeight: NSLayoutConstraint!
    
    @IBOutlet weak var lblDateTime: UILabel!
    @IBOutlet weak var lblStartLocation: UILabel!
    @IBOutlet weak var lblToLocation: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblSeatReq: UILabel!
    @IBOutlet weak var lblInvites: UILabel!
    @IBOutlet weak var lblInviteCount: UILabel!
    
    @IBOutlet weak var imgDriver: UIImageView!
    @IBOutlet weak var lblDriverName: UILabel!
    @IBOutlet weak var lblDriverReviews: UILabel!
    @IBOutlet weak var lblDriverRating: UILabel!
    @IBOutlet weak var viewRating: UIView!
    
    @IBOutlet weak var viewSeatReq: UIView!
    @IBOutlet weak var viewPrice: UIView!
    @IBOutlet weak var viewRideStatus: UIView!
    @IBOutlet weak var viewInvitations: UIView!
    @IBOutlet weak var viewDriverDetails: UIView!
    @IBOutlet weak var viewInviteRider: UIView!
    
    @IBOutlet weak var imgRideStart: UIImageView!
    @IBOutlet weak var imgRideEnd: UIImageView!
    
    /// Variables
    var action_invitations:(() -> ())?
    var action_invite_rider:(() -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewSeatBooked.isHidden = true
        imgRideStart?.setViewHeight(height: (DeviceType.iPad ? 22 : 18) * _widthRatio)
        imgRideEnd?.setViewHeight(height: (DeviceType.iPad ? 22 : 18) * _widthRatio)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}

// MARK: - UI Methods
extension RideHistoryCell {
    
    func prepareMyRideListUI(_ data: RideHistoryData) {
        viewSeatBooked.isHidden = true
        viewPrice.isHidden = false
        viewRideStatus.isHidden = data.status == .pending
        viewInviteRider.isHidden = data.status != .pending
        viewSeatReq.isHidden = true
        viewDriverDetails.isHidden = true
        viewInvitations.isHidden = true
        
        lblDateTime.text = data.dateTimeStr
        lblStartLocation.text = data.fromLocation
        lblToLocation.text = data.toLocation
        lblStatus.text = data.status.title
        lblStatus.textColor = data.status.color
        lblPrice.text = "₹\(data.price!)"
//        lblInviteCount.text = "\(data.inviteRiders!)"
    }
    
    func prepareBookRideListUI(_ data: RideHistoryData) {
        viewSeatBooked.isHidden = false
        viewPrice.isHidden = false
        viewRideStatus.isHidden = false
        viewInviteRider.isHidden = true
        viewSeatReq.isHidden = true
        viewDriverDetails.isHidden = true
        viewInvitations.isHidden = true
        
        lblDateTime.text = data.dateTimeStr
        lblStartLocation.text = data.fromLocation
        lblToLocation.text = data.toLocation
        lblStatus.text = data.status.title
        lblStatus.textColor = data.status.color
        lblPrice.text = "₹\(data.price!)"
        labelSeatBooked.text = "Seat booked - \(data.seatBooked.stringValue)"
    }
    
    func prepareMyPostRequestListUI(_ data: RideHistoryData) {
        viewSeatBooked.isHidden = true
        viewSeatReq.isHidden = false
        viewInvitations.isHidden = false
        viewInviteRider.isHidden = true
        viewDriverDetails.isHidden = true
        viewPrice.isHidden = true
        viewRideStatus.isHidden = true
        
        lblDateTime.text = Date.serverDateString(from: data.fDate, format: DateFormat.format_MMMMddyyyy)
        lblStartLocation.text = data.fromLocation
        lblToLocation.text = data.toLocation
        lblSeatReq.text = "\(data.seatReq!)"
        lblInvites.text = "\(data.invitations!)"
    }
    
    func prepareCarpoolPostRequestListUI(_ data: RideHistoryData) {
        viewSeatBooked.isHidden = true
        viewSeatReq.isHidden = false
        viewDriverDetails.isHidden = data.driver == nil
        viewInviteRider.isHidden = true
        viewInvitations.isHidden = true
        viewPrice.isHidden = true
        viewRideStatus.isHidden = true
        
        lblDateTime.text = Date.formattedString(from: data.fDate, format: DateFormat.format_MMMMddyyyy)
        lblStartLocation.text = data.fromLocation
        lblToLocation.text = data.toLocation
        lblSeatReq.text = "\(data.seatReq!)"
        
        lblDriverName.text = data.driver?.fullName
        if let img = data.driver?.img {
            imgDriver.loadFromUrlString(img, placeholder: _userPlaceImage)
        }
        
        if let driver = data.driver {
            lblDriverReviews.text = driver.reviewCount
            lblDriverRating.text = driver.averageRating.stringValues
            viewRating.isHidden = driver.totalReview == 0
        }
    }
}

// MARK: - Button Actions
extension RideHistoryCell {
    
    @IBAction func btn_invitation(_ sender: UIButton) {
        action_invitations?()
    }
    
    @IBAction func btn_invite_rider(_ sender: UIButton) {
        action_invite_rider?()
    }
}

//MARK: - Register Cell
extension RideHistoryCell {
    
    class func prepareToRegisterCells(_ sender: UITableView) {
        sender.register(UINib(nibName: "RideHistoryCell", bundle: nil), forCellReuseIdentifier: identifier)
    }
}
