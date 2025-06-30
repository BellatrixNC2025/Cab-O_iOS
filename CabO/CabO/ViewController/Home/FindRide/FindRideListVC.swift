//
//  FindRideListVC.swift
//  CabO
//
//  Created by Octos.
//

import UIKit

class FindRideListVC: ParentVC {
    
    /// Outlets
    @IBOutlet weak var lblSearchDate: UILabel!
    @IBOutlet weak var vwFilterRedDot: UIView!
    
    /// Variables
    var data: FindRideModel!
    var loadMore = LoadMore()
    var arrRidesList: [FindRideListModel]!

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        getRideListing()
    }
    
    deinit {
        data.seatReq = nil
        data.arrPrefs.removeAll()
        data.isNonStopRide = nil
    }
}

// MARK: - UI Methods
extension FindRideListVC {
    
    func prepareUI() {
        lblTitle?.text = "Searching..."
        lblSearchDate.text = Date.localDateString(from: data.rideDate, format: DateFormat.format_MMMMddyyyy)
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 50, right: 0)
        vwFilterRedDot.isHidden = !data.isFilterApplied
        registerCells()
        addRefresh()
    }
    
    func addRefresh() {
        refresh.addTarget(self, action: #selector(self.refreshing(_:)), for: .valueChanged)
        self.tableView.refreshControl = refresh
    }
    
    @objc private func refreshing(_ sender: UIRefreshControl) {
        loadMore = LoadMore()
        self.getRideListing()
    }
    
    func registerCells() {
        NoDataCell.prepareToRegisterCells(tableView)
        RideListCell.prepareToRegisterCells(tableView)
    }
}

// MARK: - Actions
extension FindRideListVC {
    
    @IBAction func btn_back_action(_ sender: UIButton) {
        data.seatReq = nil
        data.arrPrefs.removeAll()
        data.isNonStopRide = nil
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnFilterTap(_ sender: UIButton) {
        let vc = RideFilterVC.instantiate(from: .Home)
        
        vc.data.rideDate = self.data.rideDate
        vc.data.seatReq = self.data.seatReq
        vc.data.arrPrefs = self.data.arrPrefs
        vc.data.isNonStopRide = self.data.isNonStopRide
        vc.data.range = self.data.range
        
        vc.filterCallBack = { [weak self] (filter) in
            guard let self = self else { return }
            self.data.rideDate = filter.rideDate
            self.data.seatReq = filter.seatReq
            self.data.arrPrefs = filter.arrPrefs
            self.data.isNonStopRide = filter.isNonStopRide
            self.data.range = filter.range
            self.lblSearchDate.text = Date.localDateString(from: self.data.rideDate, format: DateFormat.format_MMMddyyyy)
            self.vwFilterRedDot.isHidden = !self.data.isFilterApplied
            
            self.loadMore = LoadMore()
            self.getRideListing()
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnEditTap(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnPostRequqestTap(_ sender: UIButton) {
        let vc = PostRequestVC.instantiate(from: .Home)
        vc.data = PostRequestModel(data)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - TableView Methods
extension FindRideListVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrRidesList == nil ? 0 : (arrRidesList.isEmpty ? 1 : arrRidesList.count)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if arrRidesList.isEmpty {
            return _isLandScape ? tableView.frame.width : tableView.frame.height
        } else {
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == arrRidesList.count - 1 && !loadMore.isLoading && !loadMore.isAllLoaded {
            getRideListing()
            return showLoadMoreCell()
        }
        if arrRidesList.isEmpty {
            return tableView.dequeueReusableCell(withIdentifier: NoDataCell.identifier, for: indexPath)
        } else {
            return tableView.dequeueReusableCell(withIdentifier: RideListCell.identifier, for: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? NoDataCell {
            cell.prepareUI(title: "No results found")
        }
        else if let cell = cell as? RideListCell {
            cell.prepareUI(arrRidesList[indexPath.row])
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !arrRidesList.isEmpty {
            let vc = RideDetailVC.instantiate(from: .Home)
            vc.screenType = .find
            vc.rideId = arrRidesList[indexPath.row].rideId
            vc.findRide = arrRidesList[indexPath.row]
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// MARK: - API Calls
extension FindRideListVC {
    
    func getRideListing() {
        var param: [String: Any] = [:]
        param["offset"] = loadMore.offset
        param["limit"] = loadMore.limit
        
        param.merge(with: data.findRideParam)
        if !refresh.isRefreshing && loadMore.index == 0 {
            showCentralSpinner()
        }
        lblTitle?.text = "Searching..."
        WebCall.call.getFindRideList(param) { [weak self] (json, status) in
            guard let self = self else { return }
            self.hideCentralSpinner()
            self.refresh.endRefreshing()
            
            if status == 200, let dict = json as? NSDictionary {
                let count = dict.getIntValue(key: "total_ride")
                self.lblTitle?.text = "\(count) \(count == 1 ? "result" : "results") found"
                if let data = dict["data"] as? [NSDictionary] {
                    if self.loadMore.index == 0 {
                        self.arrRidesList = []
                    }
                    for dict in data {
                        self.arrRidesList.append(FindRideListModel(dict))
                    }
                    if data.isEmpty || count == self.arrRidesList.count  {
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
                self.lblTitle?.text = "0 results found"
                self.showError(data: json, yCord: _navigationHeight)
            }
        }
    }
}
