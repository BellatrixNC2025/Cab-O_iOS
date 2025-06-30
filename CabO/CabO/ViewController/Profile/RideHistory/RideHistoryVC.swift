//
//  RideHistoryVC.swift
//  CabO
//
//  Created by Octos.
//

import UIKit
import ViewAnimator

// MARK: - RideHistoryScreenType
enum RideHistoryScreenType: Int {
    case created = 0, booked, requests, history
    
    var title: String {
        switch self {
        case .created: return "Created rides"
        case .booked: return "Booked rides"
        case .requests: return "Requests"
        case .history: return "Ride history"
        }
    }
    
    var showTabs: Bool {
        switch self {
        case .requests, .history: return true
        default: return false
        }
    }
    
    var tabTitle: (String, String) {
        switch self {
        case .requests: return ("Carpool requests","My requests")
        case .history: return ("Created rides","Booked rides")
        default: return ("","")
        }
    }
    
    var detailScreenType: RideDetailScreenType {
        switch self {
        case .created: return .created
        case .booked: return .book
        default: return .created
        }
    }
}

// MARK: - RideHistoryVC
class RideHistoryVC: ParentVC {
    
    /// Outlets
    @IBOutlet weak var viewTabSelection: UIView!
    @IBOutlet var tabButtonGradientBg: [UIView]!
    @IBOutlet var tabButtons: [UIButton]!
    @IBOutlet weak var viewCreateRide: UIView!
    @IBOutlet weak var btnCreateRide: UIButton!
    @IBOutlet weak var vwFilterRedDot: UIView!
    
    /// Variables
    var scrennType: RideHistoryScreenType! = .created
    var selectedTab: Int = 0 {
        didSet {
            prepareTabSelectionUI()
        }
    }
    var loadMore = LoadMore()
    var arrRideHistory: [RideHistoryData]!
    var filter = RideHistoryFilterModel()
    var redirect_ride_id: String?
    var redirect_request_id: String?

    override func viewDidLoad() {
        super.viewDidLoad()
//        selectedTab = 0
        
        checkForPushRedirect()
        prepareUI()
        getRidesList()
    }
    
    func checkForPushRedirect() {
        if let redirect_ride_id {
            let vc = RideDetailVC.instantiate(from: .Home)
            if scrennType == .history {
                vc.isPastData = true
                vc.screenType = selectedTab == 0 ? .created : .book
            } else {
                vc.screenType = scrennType.detailScreenType
                
                vc.remove_fromList_callback = { [weak self] in
                    guard let self = self else { return }
                    self.loadMore = LoadMore()
                    self.getRidesList()
                    self.tableView.reloadData()
                }
            }
            vc.rideId = redirect_ride_id.integerValue
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if let redirect_request_id {
            let vc = BookingRequestListVC.instantiate(from: .Home)
            vc.screenType = .invitations
            vc.rideId = redirect_request_id.integerValue
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// MARK: - UI Methods
extension RideHistoryVC {
    
    func getRidesList() {
        if scrennType == .created {
            getMyRides()
        } else if scrennType == .requests {
            getRequestedRides()
        } else if scrennType == .booked {
            getBookedRides()
        } else if scrennType == .history {
            if selectedTab == 0 {
                getMyRides()
            } else {
                getBookedRides()
            }
        }
    }
    
    func prepareUI() {
        prepareTabSelectionUI()
        lblTitle?.text = scrennType.title
        viewTabSelection.isHidden = !scrennType.showTabs
        tabButtons[0].setTitle(scrennType.tabTitle.0, for: .normal)
        tabButtons[1].setTitle(scrennType.tabTitle.1, for: .normal)
        viewCreateRide.isHidden = true
        vwFilterRedDot.isHidden = !filter.isFilterApplied
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 50, right: 0)
        registerCells()
        addRefresh()
        addObservers()
    }
    
    func registerCells() {
        NoDataCell.prepareToRegisterCells(tableView)
        RideHistoryCell.prepareToRegisterCells(tableView)
    }
    
    func addRefresh() {
        refresh.addTarget(self, action: #selector(self.refreshing(_:)), for: .valueChanged)
        self.tableView.refreshControl = refresh
    }
    
    @objc private func refreshing(_ sender: UIRefreshControl) {
        loadMore = LoadMore()
        getRidesList()
    }
    
    func prepareTabSelectionUI() {
        tabButtonGradientBg?.forEach({$0.isHidden = selectedTab != $0.tag})
        tabButtons?.forEach({$0.setTitleColor(selectedTab == $0.tag ? UIColor.white : AppColor.primaryText, for: .normal)})
        tableView?.reloadSections(IndexSet(integer: 0), with: .automatic)
    }
    
    private func getCellHeight(_ data: RideHistoryData) -> CGFloat {
        var height: CGFloat = 0
        let addressMinHeight: CGFloat = 30 * _widthRatio
        let from = data.fromLocation.heightWithConstrainedWidth(width: _screenSize.width - (100 * _widthRatio), font: AppFont.fontWithName(.regular, size: 14 * _fontRatio)) + (16 * _widthRatio)
        let to = data.toLocation.heightWithConstrainedWidth(width: _screenSize.width - (100 * _widthRatio), font: AppFont.fontWithName(.regular, size: 14 * _fontRatio)) + (16 * _widthRatio)
        height += from > addressMinHeight ? from : addressMinHeight
        height += to > addressMinHeight ? to : addressMinHeight
        height += 26 * _widthRatio
        height += 74 * _widthRatio
        if scrennType == .booked  || (scrennType == .history && selectedTab == 1){
            height += 28 * _widthRatio
        }
        return height + (32 * _widthRatio)
    }
}


// MARK: - Actions
extension RideHistoryVC {
    
    @IBAction func buttonTabSelection(_ sender: UIButton) {
        if selectedTab != sender.tag {
            selectedTab = sender.tag
            self.viewCreateRide.isHidden = true
            self.arrRideHistory = nil
            
            self.tableView.reloadData()
            self.filter.reset()
            self.vwFilterRedDot.isHidden = !self.filter.isFilterApplied
            
            loadMore = LoadMore()
            getRidesList()
        } else {
//            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
    
    @IBAction func btn_createRide(_ sender: UIButton) {
        let vc = self.navigationController?.viewControllers.last(where: {$0.isKind(of: NTabBarVC.self)})
        if let tab = vc! as? NTabBarVC {
            tab.setSelectedIndex(0)
        }
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func action_filter(_ sender: UIButton) {
        let vc = RideHistoryFilterVC.instantiate(from: .Profile)
        vc.data = filter
        vc.isPast = scrennType == .history
        vc.screenType = self.scrennType == .history ? (selectedTab == 0 ? .created : .booked) : self.scrennType
        vc.filterCallBack = { [weak self] (filtr) in
            guard let self = self else { return }
            self.filter = filtr
            self.vwFilterRedDot.isHidden = !self.filter.isFilterApplied
            self.loadMore = LoadMore()
            self.getRidesList()
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - TableView Methods
extension RideHistoryVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrRideHistory == nil ? 0 : (arrRideHistory.isEmpty ? 1 : arrRideHistory.count)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if arrRideHistory.isEmpty {
            return _isLandScape ? tableView.frame.width : tableView.frame.height
        } else {
            return getCellHeight(arrRideHistory[indexPath.row])
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == arrRideHistory.count - 1 && !loadMore.isLoading && !loadMore.isAllLoaded {
            getRidesList()
            return showLoadMoreCell()
        }
        if arrRideHistory.isEmpty {
            return tableView.dequeueReusableCell(withIdentifier: NoDataCell.identifier, for: indexPath)
        } else {
            return tableView.dequeueReusableCell(withIdentifier: RideHistoryCell.identifier, for: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? NoDataCell {
            if scrennType == .requests {
                cell.prepareUI(title: "No requests found")
            } else {
                var msg : String = ""
                if scrennType == .created {
                    msg = "No created ride found"
                } else if scrennType == .booked {
                    msg = "No booked ride found"
                } else if scrennType == .history {
                    msg = "No \(selectedTab == 0 ? "created" : "booked") ride found"
                }
                cell.prepareUI(title: msg)
            }
        }
        else if let cell = cell as? RideHistoryCell {
            let data = arrRideHistory[indexPath.row]
            if scrennType == .created {
                cell.prepareMyRideListUI(data)
            } else if scrennType == .requests {
                if selectedTab == 0 {
                    cell.prepareCarpoolPostRequestListUI(data)
                } else {
                    cell.prepareMyPostRequestListUI(data)
                }
            } else if scrennType == .booked {
                cell.prepareBookRideListUI(data)
            } else if scrennType == .history {
                if selectedTab == 0 {
                    cell.prepareMyRideListUI(data)
                } else {
                    cell.prepareBookRideListUI(data)
                }
            }
            cell.action_invitations = { [weak self] in
                guard let self = self else { return }
                let vc = BookingRequestListVC.instantiate(from: .Home)
                vc.screenType = .invitations
                vc.rideId = data.requestId
                self.navigationController?.pushViewController(vc, animated: true)
            }
            cell.action_invite_rider = { [weak self] in
                guard let self = self else { return }
                let vc = BookingRequestListVC.instantiate(from: .Home)
                vc.screenType = .invites
                vc.rideId = data.rideId
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if scrennType == .requests {
            if !arrRideHistory.isEmpty {
                let vc = RequestDetailVC.instantiate(from: .Home)
                vc.reqId = arrRideHistory[indexPath.row].requestId
                vc.screenType = selectedTab == 1 ? .my : .carpool
                self.navigationController?.pushViewController(vc, animated: true)
            }
        } else if !arrRideHistory.isEmpty {
            let vc = RideDetailVC.instantiate(from: .Home)
            let data = arrRideHistory[indexPath.row]
            if scrennType == .history {
                vc.isPastData = true
                vc.screenType = selectedTab == 0 ? .created : .book
            } else {
                vc.screenType = scrennType.detailScreenType
                
                vc.remove_fromList_callback = { [weak self] in
                    guard let self = self else { return }
                    self.loadMore = LoadMore()
                    self.getRidesList()
                    self.tableView.reloadData()
                }
            }
            vc.rideId = (scrennType == .booked || (scrennType == .history && selectedTab == 1)) ? data.bookRideId : data.rideId
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

//MARK: - Notification Observers
extension RideHistoryVC {
    
    func addObservers() {
        _defaultCenter.addObserver(self, selector: #selector(requestListUpdated(_:)), name: Notification.Name.rideListUpdate, object: nil)
        _defaultCenter.addObserver(self, selector: #selector(requestListUpdated(_:)), name: Notification.Name.requestListUpdate, object: nil)
    }
    
    @objc func requestListUpdated(_ notification: NSNotification){
        loadMore = LoadMore()
        getRidesList()
    }
    
}

// MARK: - API Calls
extension RideHistoryVC {
    
    func getMyRides() {
        var param: [String: Any] = [:]
        param["type"] = scrennType == .created ? "upcoming" : "past"
        param["offset"] = loadMore.offset
        param["limit"] = loadMore.limit
        param.merge(with: filter.param)
        
        if !refresh.isRefreshing && loadMore.index == 0 {
            showCentralSpinner()
        }
        WebCall.call.getMyRides(param) { [weak self] (json, status) in
            guard let self = self else { return }
            self.hideCentralSpinner()
            self.refresh.endRefreshing()
            
            if status == 200, let data = json as? NSDictionary {
                let count = data.getIntValue(key: "total_ride")
                if let dict = data["data"] as? [NSDictionary] {
                    if self.loadMore.index == 0 {
                        self.arrRideHistory = []
                    }
                    for data in dict {
                        self.arrRideHistory.append(RideHistoryData(data))
                    }
                    if dict.isEmpty || count == self.arrRideHistory.count {
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
    
    func getBookedRides() {
        var param: [String: Any] = [:]
        param["type"] = scrennType == .booked ? "upcoming" : "past"
        param["offset"] = loadMore.offset
        param["limit"] = loadMore.limit
        param.merge(with: filter.param)
        
        if !refresh.isRefreshing && loadMore.index == 0 {
            showCentralSpinner()
        }
        WebCall.call.getBookedRides(param) { [weak self] (json, status) in
            guard let self = self else { return }
            self.hideCentralSpinner()
            self.refresh.endRefreshing()
            
            if status == 200, let data = json as? NSDictionary {
                let count = data.getIntValue(key: "total_ride")
                if let dict = data["data"] as? [NSDictionary] {
                    if self.loadMore.index == 0 {
                        self.arrRideHistory = []
                    }
                    for data in dict {
                        self.arrRideHistory.append(RideHistoryData(booked: data))
                    }
                    if dict.isEmpty || count == self.arrRideHistory.count {
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
    
    func getRequestedRides() {
        var param: [String: Any] = [:]
        param["request_type"] = selectedTab == 1 ? "my" : "carpool"
        param["offset"] = loadMore.offset
        param["limit"] = loadMore.limit
        param.merge(with: filter.param)
        
        if !refresh.isRefreshing && loadMore.index == 0 {
            showCentralSpinner()
        }
        
        WebCall.call.getPostReqRides(param) { [weak self] (json, status) in
            guard let self = self else { return }
            self.hideCentralSpinner()
            self.refresh.endRefreshing()
            
            if status == 200, let data = json as? NSDictionary {
                let count = data.getIntValue(key: "total_ride")
                if let dict = data["data"] as? [NSDictionary] {
                    if self.loadMore.index == 0 {
                        self.arrRideHistory = []
                    }
                    for data in dict {
                        self.arrRideHistory.append(RideHistoryData(data, isRequest: true))
                    }
                    if dict.isEmpty  || count == self.arrRideHistory.count {
                        self.loadMore.isAllLoaded = true
                    } else {
                        self.loadMore.index += 1
                    }
                    self.viewCreateRide.isHidden = !(self.scrennType == .requests && self.selectedTab == 0 && !arrRideHistory.isEmpty)
                    
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
}
