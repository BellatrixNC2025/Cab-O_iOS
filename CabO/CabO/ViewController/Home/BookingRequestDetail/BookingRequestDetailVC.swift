//
//  BookingRequestDetailVC.swift
//  CabO
//
//  Created by Octos.
//

import UIKit

class BookingRequestDetailVC: ParentVC {
    
    /// Outlets
    @IBOutlet weak var viewAcceptReject: UIView!
    @IBOutlet weak var btnAccept: UIButton!
    @IBOutlet weak var btnReject: UIButton!
    @IBOutlet weak var btnInvite: UIButton!
    @IBOutlet weak var btnStartRide: UIButton!
    @IBOutlet weak var btnEndRide: UIButton!
    @IBOutlet weak var btnRateReview: UIButton!
    
    /// Variables
    var arrCells: [BookingRequestDetailCellType] = [.trip, .seat, .msg, .driver]
    var rideId: Int!
    var rideDetails: RideDetails!
    var bookRideId: Int!
    var isRider: Bool = false
    var data: BookingRequestDetailModel!
    var screenType: BookingRequestListScreenType = .bookingReq
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
    }
}

// MARK: - UI Methods
extension BookingRequestDetailVC {
    
    func prepareUI() {
        lblTitle?.text = screenType.detailTitle
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 50, right: 0)
        
        btnAccept.isHidden = true
        btnReject.isHidden = true
        btnInvite.isHidden = true
        btnStartRide.isHidden = true
        btnEndRide.isHidden = true
        btnRateReview.isHidden = true
        
        if screenType == .invites {
            getRequestDetail()
        } else {
            getBookingReqDetail()
        }
        
        RideReviewTVC.prepareToRegister(tableView)
    }
    
    func updateUI() {
        btnAccept.isHidden = true
        btnReject.isHidden = true
        btnInvite.isHidden = true
        btnStartRide.isHidden = true
        btnEndRide.isHidden = true
        btnRateReview.isHidden = true
        
        guard isRider == false else { return }
        if screenType == .bookingReq {
            btnAccept.isHidden = data.status != .pending
            btnReject.isHidden = data.status != .pending
            
            if data.status == .rejected {
                if !arrCells.contains(.reject) {
                    arrCells.append(.reject)
                }
                tableView.reloadData()
            }
            
            if data.transactionId.isEmpty {
                if arrCells.contains(.transaction) {
                    arrCells.append(.transaction)
                }
                tableView.reloadData()
            }
        }
        else if screenType == .booked {
            if !data.transactionId.isEmpty && !arrCells.contains(.transaction) {
                arrCells.insert(.transaction, at: 3)
            }
            tableView.reloadData()
            if data.status == .ontheway {
                btnStartRide.isHidden = false
            }
            else if data.status == .started {
                btnEndRide.isHidden = false
            }
            else if data.status == .completed && !data.isReviewGiven {
                btnRateReview.isHidden = false
            } else {
                viewAcceptReject.isHidden = true
            }
            if data.review != nil {
                arrCells.append(.review)
            }
            if data.status == .cancelled {
                if !arrCells.contains(.cancel) {
                    arrCells.append(.cancel)
                }
                tableView.reloadData()
            }
        }
    }
    
    private func updateInviteButton() {
        btnInvite.isHidden = false
        btnInvite.alpha = data.isInvited ? 0.5 : 1
        btnInvite.isUserInteractionEnabled = !data.isInvited
        if data.driver == nil && arrCells.contains(.driver){
            arrCells.remove(.driver)
        }
        if data.msg.isEmpty && arrCells.contains(.msg){
            arrCells.remove(.msg)
        }
        
        btnInvite.setTitle(data.isInvited ? "Invited" : "Invite", for: .normal)
    }
    
    private func getHeight(_ cellType: BookingRequestDetailCellType) -> CGFloat {
//        return UITableView.automaticDimension
        var height: CGFloat = 16 * _widthRatio
        let addressMinHeight: CGFloat = 30 * _widthRatio
        switch cellType {
        case .trip :
            return UITableView.automaticDimension
            let from = data.fromLoc.heightWithConstrainedWidth(width: _screenSize.width - (96 * _widthRatio), font: AppFont.fontWithName(.regular, size: 14 * _fontRatio)) + (12 * _widthRatio)
            let to = data.toLoc.heightWithConstrainedWidth(width: _screenSize.width - (96 * _widthRatio), font: AppFont.fontWithName(.regular, size: 14 * _fontRatio)) + (12 * _widthRatio)
            height += from > addressMinHeight ? from : addressMinHeight
            height += to > addressMinHeight ? to : addressMinHeight
            height += 68 * _widthRatio
//            height += 32 * _widthRatio
        case .seat:
            height += (51 * _widthRatio)
        case .msg:
            if data.msg.isEmpty {
                height = 0
            } else {
                height += (51 * _widthRatio)
                height += data.msg.heightWithConstrainedWidth(width: _screenSize.width - (72 * _widthRatio), font: AppFont.fontWithName(.regular, size: 12 * _fontRatio)) + (16 * _widthRatio)
            }
        case .driver: return 88 * _widthRatio
        case .transaction: return 110 * _widthRatio
        case .reject, .cancel:
            return UITableView.automaticDimension
            var hight : CGFloat = 0
            if !data.rejectMessage.isEmpty {
                hight += data.rejectMessage.heightWithConstrainedWidth(width: _screenSize.width - (72 * _widthRatio), font: AppFont.fontWithName(.regular, size: 13 * _fontRatio)) + (16 * _widthRatio) + 24 * _widthRatio
            }
            if !data.rejectReason.isEmpty {
                hight += data.rejectReason.heightWithConstrainedWidth(width: _screenSize.width - (72 * _widthRatio), font: AppFont.fontWithName(.regular, size: 13 * _fontRatio)) + (16 * _widthRatio) + 24 * _widthRatio
            }
            return hight + ((data.rejectMessage.isEmpty || data.rejectReason.isEmpty) ? 40 * _widthRatio : 0)
        case .review :
            return UITableView.automaticDimension
            if data.review!.review.isEmpty {
                return (74 + 36) * _widthRatio
            } else {
                return data.review!.review.heightWithConstrainedWidth(width: _screenSize.width - (64 * _widthRatio), font: AppFont.fontWithName(.regular, size: 14 * _fontRatio)) + (8 * _widthRatio) + (74 + 36) * _widthRatio
            }
        }
        return height
    }
}

// MARK: - Actions
extension BookingRequestDetailVC {
    
    @IBAction func button_accept_req(_ sender: UIButton) {
        acceptRideRrequest()
    }
    
    @IBAction func button_reject_req(_ sender: UIButton) {
        showConfirmationPopUpView("Confirmation!", "Are you sure you want to reject this booking request?", btns: [.cancel, .yes]) { btn in
            if btn == .yes {
                let vc = CancellationVC.instantiate(from: .Home)
                vc.screenType = .rejectRequest
                vc.rideId = self.rideId
                vc.bookingId = self.bookRideId
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    @IBAction func button_invite(_ sender: UIButton) {
        self.inviteOnRide()
    }
    
    @IBAction func button_start_ride(_ sender: UIButton) {
        let vc = StartBookingVC.instantiate(from: .Home)
        vc.data = data
        vc.rideId = rideId
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func button_end_ride(_ sender: UIButton) {
        endRide()
    }
    
    @IBAction func button_rate_and_review(_ sender: UIButton) {
        self.openReviewRider()
    }
    
    func openReviewRider() {
        let vc = RateAndReviewVC.instantiate(from: .Home)
        let data = RatingModel()
        data.toUserId = self.data.userId
        data.toBookingId = self.data.bookRideId
        data.toUserImage = self.data.image
        data.toUserName = self.data.fullName
        
        vc.rideId = self.rideId
        vc.data = data
        vc.isForDriver = false
        vc.review_given_success = { [weak self] in
            guard let self = self else { return }
            self.getBookingReqDetail()
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func openChatScreen() {
        let chat = ChatHistory(data)
        openChat(chat)
    }
    
    func openSupport() {
        let vc = AddSupportTicketVC.instantiate(from: .Profile)
        vc.isFromRideDetail = true
        vc.data.bookDetails = self.data
        vc.data.rideDetails = self.rideDetails
        vc.data.bookRideId = self.bookRideId
        vc.data.type = 1
        vc.data.toUserId = data.userId
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - TableView Methods
extension BookingRequestDetailVC : UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data == nil ? 0 : arrCells.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return getHeight(arrCells[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellType = arrCells[indexPath.row]
        if cellType == .review {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellType.cellId, for: indexPath) as! RideReviewTVC
            if let review = data.review {
                cell.prepareUI(review)
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellType.cellId, for: indexPath) as! RequestDetailCell
            cell.delegate = self
            cell.prepareUI(arrCells[indexPath.row])
            
            cell.action_message_user = { [weak self ] in
                guard let self = self else { return }
                self.openChatScreen()
            }
            
            cell.action_support_center = { [weak self ] in
                guard let self = self else { return }
                self.openSupport()
            }
            return cell
        }
    }
    
//    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        if let cell = cell as? RequestDetailCell {
//            cell.delegate = self
//            cell.prepareUI(arrCells[indexPath.row])
//            
//            cell.action_message_user = { [weak self ] in
//                guard let self = self else { return }
//                self.openChatScreen()
//            }
//            
//            cell.action_support_center = { [weak self ] in
//                guard let self = self else { return }
//                self.openSupport()
//            }
//        } else if let cell = cell as? RideReviewTVC {
//            if let review = data.review {
//                cell.prepareUI(review)
//            }
//        }
//    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellType = arrCells[indexPath.row]
        if cellType == .driver {
            let vc = UserDetailVC.instantiate(from: .Home)
            vc.userId = data.userId
            vc.isDriver = false
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// MARK: - API Call
extension BookingRequestDetailVC {
    
    /// Get Booking Detail
    func getBookingReqDetail() {
        showCentralSpinner()
        WebCall.call.getBookingDetail(bookRideId) { [weak self] (json, status) in
            guard let self = self else { return }
            self.hideCentralSpinner()
            if status == 200, let dict = json as? NSDictionary, let data = dict["data"] as? NSDictionary {
                self.data = BookingRequestDetailModel(data)
                self.updateUI()
                self.tableView.reloadData()
            } else {
                self.showError(data: json, yCord: _navigationHeight)
            }
        }
    }
    
    /// Get Booking Request Detail
    func getRequestDetail() {
        var param: [String: Any] = [:]
        param["ride_id"] = rideId
        param["request_id"] = bookRideId
        
        showCentralSpinner()
        WebCall.call.getRequestDetails(param) { [weak self] (json, status) in
            guard let self = self else { return }
            self.hideCentralSpinner()
            if status == 200, let dict = json as? NSDictionary, let data = dict["data"] as? NSDictionary {
                self.data = BookingRequestDetailModel(invite: data)
                self.updateInviteButton()
                self.tableView.reloadData()
            } else {
                self.showError(data: json, yCord: _navigationHeight)
            }
        }
    }
    
    /// Send Invitation
    func inviteOnRide() {
        var param: [String: Any] = [:]
        param["ride_id"] = rideId
        param["request_id"] = bookRideId
        
        showCentralSpinner()
        WebCall.call.inviteForRide(param) { [weak self] (json, status) in
            guard let self = self else { return }
            self.hideCentralSpinner()
            if status == 200 {
                self.showSuccessMsg(data: json, yCord: _navigationHeight)
                _defaultCenter.post(name: Notification.Name.rideDetailsUpdate, object: nil)
                self.navigationController?.popViewController(animated: true)
            } else {
                self.showError(data: json, yCord: _navigationHeight)
            }
        }
    }
    
    /// Accept Booking Request
    func acceptRideRrequest() {
        var param: [String: Any] = [:]
        param["ride_id"] = rideId
        param["book_ride_id"] = bookRideId
        param["ride_status"] = "accepted"
        
        showCentralSpinner()
        WebCall.call.updateRideStatus(param) { [weak self] (json, status) in
            guard let self = self else { return }
            self.hideCentralSpinner()
            if status == 200 {
                self.showSuccessMsg(data: json, yCord: _navigationHeight)
                _defaultCenter.post(name: Notification.Name.rideDetailsUpdate, object: nil)
                self.navigationController?.popViewController(animated: true)
            } else {
                self.showError(data: json, yCord: _navigationHeight)
            }
        }
    }
    
    /// End Booking of Corider
    func endRide() {
        var param: [String: Any] = [:]
        param["ride_id"] = rideId
        param["book_ride_id"] = bookRideId
        param["ride_status"] = "complete_booking"
        param["date_time"] = Date().converDisplayDateTimeFormet()
        
        showCentralSpinner()
        WebCall.call.updateRideStatus(param) { [weak self] (json, status) in
            guard let self = self else { return }
            self.hideCentralSpinner()
            if status == 200 {
//                self.showSuccessMsg(data: json, yCord: _navigationHeight)
                _defaultCenter.post(name: Notification.Name.rideDetailsUpdate, object: nil)
                self.getBookingReqDetail()
                self.openReviewRider()
            } else {
                self.showError(data: json, yCord: _navigationHeight)
            }
        }
    }
}
