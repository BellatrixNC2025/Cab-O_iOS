//
//  BookingRequestListVC.swift
//  CabO
//
//  Created by Octos.
//

import UIKit

// MARK: - BookingRequestList ScreenType
enum BookingRequestListScreenType {
    case booked, bookingReq, invites, invitations
    
    var title: String {
        switch self {
        case .booked: return "Booked details"
        case .bookingReq: return "Booking requests"
        case .invites: return "Invite riders"
        case .invitations: return "Invitations"
        }
    }
    
    var detailTitle: String {
        switch self {
        case .booked, .invitations, .invites: return "Details"
        case .bookingReq: return "Request details"
        }
    }
}

// MARK: - BookingRequestListVC
class BookingRequestListVC: ParentVC {
    
    /// Outlets
    @IBOutlet weak var viewTabs: NBottomRoundCornerView!
    @IBOutlet var tabButtonGradientBg: [UIView]!
    @IBOutlet var tabButtons: [UIButton]!
    @IBOutlet weak var btnInfo: UIButton!
    
    /// Variables
    var rideDetails: RideDetails!
    var driverDetails: DriverModel?
    var isDriverReviewGiven: Bool = true
    var isRider: Bool = false
    
    var screenType: BookingRequestListScreenType = .bookingReq
    var selectedTab: Int! = 0 {
        didSet {
            prepareTabSelectionUI()
        }
    }
    var rideId: Int!
    var loadMore = LoadMore()
    var arrData: [Any]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedTab = 0
        prepareUI()
        getApiData()
        addObservers()
    }
}

// MARK: - UI Methods
extension BookingRequestListVC {
    
    func prepareUI() {
        lblTitle?.text = isRider ? "Co-riders" : screenType.title
        
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 50, right: 0)
        viewTabs.isHidden = screenType != .bookingReq
        btnInfo.isHidden = screenType != .booked || isRider || EnumHelper.checkCases(rideDetails.status, cases: [.completed, .cancelled, .autoCancelled])
        
        addRefresh()
        RideListCell.prepareToRegisterCells(tableView)
        NoDataCell.prepareToRegisterCells(tableView)
    }
    
    func addRefresh() {
        refresh.addTarget(self, action: #selector(self.refreshing(_:)), for: .valueChanged)
        self.tableView.refreshControl = refresh
    }
    
    @objc private func refreshing(_ sender: UIRefreshControl) {
        loadMore = LoadMore()
        self.getApiData()
    }
    
    func prepareTabSelectionUI() {
        tabButtonGradientBg?.forEach({$0.isHidden = selectedTab != $0.tag})
        tabButtons?.forEach({$0.setTitleColor(selectedTab == $0.tag ? UIColor.white : AppColor.primaryText, for: .normal)})
    }
}

// MARK: - Actions
extension BookingRequestListVC {
    
    @IBAction func buttonTabSelection(_ sender: UIButton) {
        if selectedTab != sender.tag {
            selectedTab = sender.tag
            self.arrData = nil
            self.tableView.reloadData()
            
            loadMore = LoadMore()
            getApiData()
        } else {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
    
    @IBAction func showInfoPopUp(_ sender: UIButton) {
        self.openPopOver(view: btnInfo, msg: "If a rider does not show up, to end the ride kindly create a support ticket against that ride.")
    }
    
    func reviewDriver() {
        let vc = RateAndReviewVC.instantiate(from: .Home)
        let data = RatingModel()
        data.toBookingId = self.rideDetails.book_ride_id
        data.toUserId = self.driverDetails?.id
        data.toUserImage = self.driverDetails?.img
        data.toUserName = self.driverDetails?.fullName
        
        vc.rideId = self.rideId
        vc.data = data
        vc.isForDriver = true
        
        vc.review_given_success = { [weak self] in
            guard let self = self else { return }
            self.isDriverReviewGiven = true
            self.tableView.reloadData()
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func btnStartTap(_ index: Int) {
        let data = arrData[index] as! BookingReqListModel
        let vc = StartBookingVC.instantiate(from: .Home)
        vc.data = BookingRequestDetailModel(data)
        vc.rideId = self.rideId
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func endRideTap(_ index: Int) {
        showConfirmationPopUpView("Confirmation!", "Are you sure you want to end this user's ride?", btns: [.cancel, .yes]) { btn in
            if btn == .yes {
                self.endRide(index)
            }
        }
    }
    
    func msgDriverTap() {
        self.openChat(ChatHistory(driverDetails!))
    }
}

// MARK: - TableView Methods
extension BookingRequestListVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if arrData == nil {
            return 0
        } else if isRider {
            return arrData.count + 1
        } else {
            return arrData.isEmpty ? 1 : arrData.count
        }
//        return arrData == nil ? 0 : (arrData.isEmpty ? 1 : (arrData.count + ((screenType == .booked && isRider) ? 1 : 0)))
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if arrData.isEmpty && !isRider {
            return tableView.frame.height
        } else {
            if screenType == .invitations {
                return UITableView.automaticDimension
            } else {
                if screenType == .booked && isRider && indexPath.row == 0{
                    return isDriverReviewGiven ? 86 * _widthRatio : 124 * _widthRatio
                }
                return 86 * _widthRatio
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == arrData.count - 1 && !loadMore.isLoading && !loadMore.isAllLoaded {
            getApiData()
            return showLoadMoreCell()
        }
        if arrData.isEmpty && !isRider  {
            return tableView.dequeueReusableCell(withIdentifier: NoDataCell.identifier, for: indexPath)
        } else {
            return tableView.dequeueReusableCell(withIdentifier: screenType == .invitations ? RideListCell.identifier : "riderCell", for: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? NoDataCell {
            if screenType == .bookingReq {
                cell.prepareUI(title: "No request found")
            } else {
                cell.prepareUI(title: screenType == .invitations ? "No invitations found " : "Not found")
            }
        }
        else if let cell = cell as? BookingReqListCell {
            if screenType == .booked && isRider && indexPath.row == 0{
                cell.prepareDriverUI(driverDetails!, reviewGiven: isDriverReviewGiven)
            } else {
                let data = (screenType == .booked && isRider) ? arrData[indexPath.row - 1] : arrData[indexPath.row]
                cell.prepareUI(data as! BookingReqListModel, screenType, isRider: isRider)
            }
            if (indexPath.row + (screenType == .booked && isRider ? 1 : 0)) == arrData.count - 1 && !loadMore.isLoading && !loadMore.isAllLoaded {
                getApiData()
            }
            
            cell.action_review_driver = { [weak self] in
                guard let self = self else { return }
                self.reviewDriver()
            }
            
            cell.action_start_ride = { [weak self] in
                guard let self = self else { return }
                self.btnStartTap(indexPath.row)
            }
            
            cell.action_end_ride = { [weak self] in
                guard let self = self else { return }
                self.endRideTap(indexPath.row)
            }
            
            cell.action_msg_driver = { [weak self] in
                guard let self = self else { return }
                self.msgDriverTap()
            }
        }
        else if let cell = cell as? RideListCell {
            cell.prepareUI(arrData[indexPath.row] as! FindRideListModel)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !arrData.isEmpty {
            if screenType == .invitations {
                if !arrData.isEmpty {
                    let vc = RideDetailVC.instantiate(from: .Home)
                    vc.screenType = .find
                    let data = arrData[indexPath.row] as! FindRideListModel
                    vc.rideId = data.rideId
                    vc.findRide = data
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            } else {
                if screenType == .booked && isRider{
                    let vc = UserDetailVC.instantiate(from: .Home)
                    vc.isDriver = indexPath.row == 0
                    vc.userId = indexPath.row == 0 ? driverDetails!.id : (arrData[indexPath.row - 1] as! BookingReqListModel).userId
                    self.navigationController?.pushViewController(vc, animated: true)
                } else {
                    if !arrData.isEmpty {
                        let vc = BookingRequestDetailVC.instantiate(from: .Home)
                        vc.screenType = self.screenType
                        vc.rideDetails = self.rideDetails
                        vc.isRider = self.isRider
                        let data = ((screenType == .booked && isRider) ? arrData[indexPath.row - 1] : arrData[indexPath.row]) as! BookingReqListModel
                        vc.rideId = self.rideId
                        vc.bookRideId = screenType == .invites ? data.requestId : data.bookRideId
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }
        }
    }
}

//MARK: - Notification Observers
extension BookingRequestListVC {
    
    func addObservers() {
        _defaultCenter.addObserver(self, selector: #selector(requestListUpdated(_:)), name: Notification.Name.requestListUpdate, object: nil)
        _defaultCenter.addObserver(self, selector: #selector(requestListUpdated(_:)), name: Notification.Name.rideDetailsUpdate, object: nil)
    }
    
    @objc func requestListUpdated(_ notification: NSNotification){
        loadMore = LoadMore()
        getApiData()
    }
    
}

// MARK: - API Calls
extension BookingRequestListVC {
    
    func getApiData() {
        if screenType == .invites {
            getInviteRiders()
        }
        else if screenType == .invitations {
            getInvitationsList()
        }
        else {
            getRiderList()
        }
    }
    
    func getRiderList() {
        var param: [String: Any] = [:]
        param["ride_id"] = rideId
        param["type"] = screenType == .booked ? (isRider ? "rider_booking" : "booked") : selectedTab == 0 ? "requested" : "rejected"
        param["offset"] = loadMore.offset
        param["limit"] = loadMore.limit
        
        if !refresh.isRefreshing && loadMore.index == 0 {
            showCentralSpinner()
        }
        
        WebCall.call.getBookingList(param) { [weak self] (json, status) in
            guard let self = self else { return }
            self.hideCentralSpinner()
            self.refresh.endRefreshing()
            
            if status == 200 , let data = json as? NSDictionary {
                let count = data.getIntValue(key: "total_data")
                if let dict = data["data"] as? [NSDictionary] {
                    if self.loadMore.index == 0 {
                        self.arrData = []
                    }
                    for data in dict {
                        self.arrData.append(BookingReqListModel(data))
                    }
                    if dict.isEmpty || count == self.arrData.count {
                        self.loadMore.isAllLoaded = true
                    } else {
                        self.loadMore.index += 1
                    }
                    if self.screenType == .booked && !self.isRider{
                        self.arrData.sort(by: {($0 as! BookingReqListModel).status!.order < ($1 as! BookingReqListModel).status!.order})
                    }
                    self.tableView.reloadData()
                    
                    if self.loadMore.index < 2 {
                        let cells = self.tableView.visibleCells(in: 0)
                        UIView.animate(views: cells, animations: [self.tableLoadAnimation])
                    }
                }
            } else {
                self.showError(data: json, yCord: _navigationHeight)
                self.tableView.reloadData()
            }
        }
    }
    
    func getInviteRiders() {
        var param: [String: Any] = [:]
        param["ride_id"] = rideId
        param["offset"] = loadMore.offset
        param["limit"] = loadMore.limit
        
        if !refresh.isRefreshing && loadMore.index == 0 {
            showCentralSpinner()
        }
        
        WebCall.call.getInviteRiders(param) { [weak self] (json, status) in
            guard let self = self else { return }
            self.hideCentralSpinner()
            self.refresh.endRefreshing()
            
            if status == 200 , let data = json as? NSDictionary {
                let count = data.getIntValue(key: "total_riders")
                if let dict = data["data"] as? [NSDictionary] {
                    if self.loadMore.index == 0 {
                        self.arrData = []
                    }
                    for data in dict {
                        self.arrData.append(BookingReqListModel(invite: data))
                    }
                    if dict.isEmpty || count == self.arrData.count {
                        self.loadMore.isAllLoaded = true
                    } else {
                        self.loadMore.index += 1
                    }
                    self.tableView.reloadData()
                    
                    if self.loadMore.index < 2 {
                        let cells = self.tableView.visibleCells(in: 0)
                        UIView.animate(views: cells, animations: [self.tableLoadAnimation])
                    }
                }
            } else {
                self.showError(data: json, yCord: _navigationHeight)
            }
        }
    }
    
    func getInvitationsList() {
        var param: [String: Any] = [:]
        param["request_id"] = rideId
        param["offset"] = loadMore.offset
        param["limit"] = loadMore.limit
        
        if !refresh.isRefreshing && loadMore.index == 0 {
            showCentralSpinner()
        }
        
        WebCall.call.getInvitationsList(param) { [weak self] (json, status) in
            guard let self = self else { return }
            self.hideCentralSpinner()
            self.refresh.endRefreshing()
            
            if status == 200, let dict = json as? NSDictionary {
                let count = dict.getIntValue(key: "total_ride")
                if let data = dict["data"] as? [NSDictionary] {
                    if self.loadMore.index == 0 {
                        self.arrData = []
                    }
                    for dict in data {
                        self.arrData.append(FindRideListModel(dict))
                    }
                    if data.isEmpty || count == self.arrData.count  {
                        self.loadMore.isAllLoaded = true
                    } else {
                        self.loadMore.index += 1
                    }
                    self.tableView.reloadData()
                    
                    if self.loadMore.index < 2 {
                        let cells = self.tableView.visibleCells(in: 0)
                        UIView.animate(views: cells, animations: [self.tableLoadAnimation])
                    }
                }
            } else {
                self.showError(data: json, yCord: _navigationHeight)
            }
        }
    }
    
    func endRide(_ indx: Int) {
        var param: [String: Any] = [:]
        param["ride_id"] = rideId
        param["book_ride_id"] = (arrData[indx] as! BookingReqListModel).bookRideId
        param["ride_status"] = "complete_booking"
        param["date_time"] = Date().converDisplayDateTimeFormet()
        
        showCentralSpinner()
        WebCall.call.updateRideStatus(param) { [weak self] (json, status) in
            guard let self = self else { return }
            self.hideCentralSpinner()
            if status == 200 {
                self.showSuccessMsg(data: json, yCord: _navigationHeight)
                _defaultCenter.post(name: Notification.Name.rideDetailsUpdate, object: nil)
                self.getApiData()
                self.giverRiderRating(indx)
            } else {
                self.showError(data: json, yCord: _navigationHeight)
            }
        }
    }
    
    func giverRiderRating(_ indx: Int) {
        let vc = RateAndReviewVC.instantiate(from: .Home)
        let booking = (arrData[indx] as! BookingReqListModel)
        let data = RatingModel()
        data.toUserId = booking.userId
        data.toBookingId = booking.bookRideId
        data.toUserImage = booking.img
        data.toUserName = booking.name
        
        vc.rideId = self.rideId
        vc.data = data
        vc.isForDriver = false
        vc.review_given_success = { [weak self] in
            guard let self = self else { return }
            self.getApiData()
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
