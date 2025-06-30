//
//  RideDetailCells.swift
//  CabO
//
//  Created by Octos.
//

import Foundation
import UIKit

// MARK: - RideDetailCell
class RideDetailCell: ConstrainedTableViewCell {
    
    /// Outlets
    @IBOutlet weak var lblStartLoc: UILabel!
    @IBOutlet weak var lblDestLoc: UILabel!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblTripCode: UILabel!
    @IBOutlet weak var lblDurationTitle: UILabel!
    @IBOutlet weak var lblDuration: UILabel!
    @IBOutlet weak var viewStopOversButton: UIView!
    @IBOutlet weak var lblStartTime: UILabel!
    @IBOutlet weak var lblDestTime: UILabel!
    @IBOutlet weak var lblBookCount: UILabel!
    @IBOutlet weak var lblBookCountTitle: UILabel!
    
    @IBOutlet weak var lblBookReqCount: UILabel!
    @IBOutlet weak var lblInviteCount: UILabel!
    
    @IBOutlet weak var carImagesView: UIView!
    @IBOutlet weak var lblCarMake: UILabel!
    @IBOutlet weak var lblCarDetails: UILabel!
    @IBOutlet weak var viewStatus: NRoundView!
    @IBOutlet weak var labelStatus: UILabel!
    @IBOutlet weak var imgStatus: TintImageView!
    @IBOutlet weak var vwCarBg: UIView!
    
    @IBOutlet weak var imgDriver: UIImageView!
    @IBOutlet weak var imgDriverBadge: UIImageView!
    @IBOutlet weak var lblDriverName: UILabel!
    @IBOutlet weak var lblDriverReviews: UILabel!
    @IBOutlet weak var lblDriverRating: UILabel!
    
    @IBOutlet weak var vwMessage: UIView!
    @IBOutlet weak var btnMessage: UIButton!
    
    @IBOutlet weak var lblMessage: UILabel!
    
    @IBOutlet weak var viewRating: UIView!
    
    @IBOutlet weak var viewPrefBg: UIView!
    
    @IBOutlet weak var imgRideStart: UIImageView!
    @IBOutlet weak var imgRideDest: UIImageView!
    
    /// Variables
    var imageSlider: SliderView?
    var action_openStopOver: (() -> ())?
    var action_openBookReq: (() -> ())?
    var action_openInvitations: (() -> ())?
    var action_openCarImage: ((Int) -> ())?
    var action_msg_driver: (() -> ())?
    weak var parent: RideDetailVC!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        carImagesView?.setViewHeight(height: (DeviceType.iPad ? 324 : 246) * _widthRatio)
        imgRideStart?.setViewHeight(height: (DeviceType.iPad ? 22 : 18) * _widthRatio )
        imgRideDest?.setViewHeight(height: (DeviceType.iPad ? 22 : 18) * _widthRatio )
        viewStatus?.setViewHeight(height: (DeviceType.iPad ? 22 : 18) * _widthRatio)
        imgStatus?.setViewHeight(height: (DeviceType.iPad ? 32 : 28) * _widthRatio)
    }
    
    fileprivate func prepareCarStatusUI(_ status: DocStatus) {
        labelStatus.text = status.title
        labelStatus.textColor = status.statusColor
        viewStatus.borderColor = status.statusColor
        imgStatus.image = status.imgStatus
        imgStatus.tintColor = status.statusColor
    }
    
    func prepareUI(_ cellType: RideDetailCellType) {
        let data = parent.data!
        if cellType == .detail {
            lblStartLoc.text = data.start?.name
            lblDestLoc.text = data.dest?.name
            lblDate.text = data.dateTimeStr
            lblTripCode.text = data.tripCode
            lblDuration.text = data.getDurationString(parent.screenType)
            
//            if parent.screenType == .find || parent.screenType == .review || parent.screenType == .book {
                viewStopOversButton.isHidden = !(data.isStopover ?? true)
//            }
        }
        else if cellType == .seatBookedCount {
            lblBookCountTitle?.text = parent.screenType == .find ? "Seat left" : "Seats booked"
            lblBookCount?.text = parent.screenType == .book ? data.seatTotal.stringValue : parent.screenType == .find ? data.seatLeft.stringValue : data.seatBooked.stringValue
        }
        else if cellType == .bookReqCount {
            lblBookReqCount?.text = "\(data.bookingReq!)"
            lblInviteCount?.text = "\(data.inviteCount!)"
        }
        else if cellType == .carInfo {
            lblCarMake.text = data.car?.company
            lblCarDetails.text = data.car?.descStr
            prepareCarStatusUI(data.car?.carStatus ?? .verified)
            if imageSlider == nil {
                imageSlider = Bundle.main.loadNibNamed("SliderView", owner: nil)?.first as? SliderView
            }
            if let imageSlider {
                carImagesView?.addSubview(imageSlider)
                carImagesView?.clipsToBounds = false
                imageSlider.clipsToBounds = false
                imageSlider.addConstraintToSuperView(lead: 0, trail: 0, top: 0, bottom: 0)
                imageSlider.imgs = (parent.data.car?.carImage.compactMap({$0.imgStr})) ?? []
                imageSlider.prepareZoomedUI()
                imageSlider.selectionCall = { [weak self] (indx) in
                    guard let weakSelf = self else { return }
                    weakSelf.action_openCarImage?(indx)
                }
            }
            vwCarBg.isHidden = !parent.arrCells.contains(.pref)
        }
        else if cellType == .driverInfo {
            lblDriverName.text = data.driver?.fullName
            if let img = data.driver?.img {
                imgDriver.loadFromUrlString(img, placeholder: _userPlaceImage)
            }
            if let driver = data.driver {
                lblDriverReviews.text = driver.reviewCount
                lblDriverRating.text = driver.averageRating.stringValues
                viewRating.isHidden = driver.totalReview == 0
            }
                
            vwMessage.isHidden = true
            if parent.screenType == .book {
                if EnumHelper.checkCases(data.status, cases: [.accepted, .ontheway, .started]) {
                    vwMessage.isHidden = false
                }
            }
        }
        else if cellType == .driverMessage {
            lblMessage.text = data.desc
        }
    }
    
    @IBAction func button_messageTap(_ sender: UIButton) {
        action_msg_driver?()
    }
    
    @IBAction func button_openStopover(_ sender: UIButton) {
        action_openStopOver?()
    }
    
    @IBAction func button_bookingReq(_ sender: UIButton) {
        action_openBookReq?()
    }
    
    @IBAction func button_invites(_ sender: UIButton) {
        action_openInvitations?()
    }
}

// MARK: - RideDetail Pref Cell
class RideDetailPrefCell: ConstrainedTableViewCell {
    
    @IBOutlet weak var vwBg: UIView!
    @IBOutlet weak var tblView: UITableView!
    @IBOutlet weak var lblLuggage: UILabel!
    @IBOutlet weak var viewLuggage: UIView!
    
    var arrPrefs: [RidePrefModel] = [] {
        didSet {
            tblView.reloadData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        RideDetailPrefTableCell.prepareToRegisterCells(tblView)
    }
}

// MARK: - TableView Methods
extension RideDetailPrefCell: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrPrefs.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40 * (DeviceType.iPhone ? _widthRatio : _heightRatio)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: "rideDetailPrefTableCell", for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? RideDetailPrefTableCell {
            cell.prepareUI(arrPrefs[indexPath.row])
        }
    }
}
