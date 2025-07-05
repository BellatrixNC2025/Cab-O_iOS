//
//  DriverListVC.swift
//  CabO
//
//  Created by OctosMac on 03/07/25.
//

import UIKit

class DriverListVC: ParentVC {
    /// Outlets
    @IBOutlet var tabButtonGradientBg: [GradientView]!
    @IBOutlet var tabButtons: [UIButton]!
    @IBOutlet weak var btnAddDriver: NRoundButton!
    @IBOutlet weak var btnView: UIView!
    
    /// Variables
    var selectedTab: Int! = 0 {
        didSet {
            prepareTabSelectionUI()
        }
    }
    var loadMore = LoadMore()
    var arrTicket: [TicketListData]!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        selectedTab = 0
        prepareUI()
//        getTicketList()
    }


}
// MARK: - UI Methods
extension DriverListVC{
    func prepareUI() {
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 0
                                              , right: 0)
        addRefresh()
        addObservers()
        NoDataCell.prepareToRegisterCells(tableView)
    }
    
    func addRefresh() {
        refresh.addTarget(self, action: #selector(self.refreshing(_:)), for: .valueChanged)
        self.tableView.refreshControl = refresh
    }
    
    @objc private func refreshing(_ sender: UIRefreshControl) {
        loadMore = LoadMore()
//        self.getTicketList()
    }
    
    func prepareTabSelectionUI() {
        tabButtonGradientBg.forEach({$0.isHidden = selectedTab != $0.tag})
        tabButtons?.forEach({$0.setTitleColor(selectedTab == $0.tag ? UIColor.white : AppColor.primaryTextDark, for: .normal)})
        tabButtons?.forEach({$0.backgroundColor = (selectedTab == $0.tag ? AppColor.themeGreen : .white)})
    }
}
// MARK: - Actions
extension DriverListVC{
    @IBAction func buttonTabSelection(_ sender: UIButton) {
        if selectedTab != sender.tag {
            selectedTab = sender.tag
            
            loadMore = LoadMore()
//            getTicketList()
        } else {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
    
    @IBAction func buttonAddDriverTap(_ sender: UIButton) {
        let vc = AddDriverVC.instantiate(from: .Profile)
        vc.modalPresentationStyle = .overCurrentContext
        self.present(vc, animated: true, completion: nil)
    }
}

// MARK: - TableView Methods
extension DriverListVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5 //arrTicket == nil ? 0 : arrTicket.isEmpty ? 1 : arrTicket.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if arrTicket.isEmpty {
//            return _isLandScape ? tableView.frame.width : tableView.frame.height
//        } else {
            return UITableView.automaticDimension
//        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if indexPath.row == arrTicket.count - 1 && !loadMore.isLoading && !loadMore.isAllLoaded {
//            getTicketList()
//            return showLoadMoreCell()
//        }
//        if arrTicket.isEmpty {
//            return tableView.dequeueReusableCell(withIdentifier: NoDataCell.identifier, for: indexPath)
//        } else {
            return tableView.dequeueReusableCell(withIdentifier: "driverListCell", for: indexPath)
//        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? NoDataCell {
            cell.prepareUI(title: "No ticket found")
        }
        else if let cell = cell as? DriverListCell {
//            cell.prepareUI(arrTicket[indexPath.row])
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !arrTicket.isEmpty {
            let vc = SupportTicketDetailsVC.instantiate(from: .Profile)
            vc.ticketId = arrTicket[indexPath.row].ticketId
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
//MARK: - Notification Observers
extension DriverListVC{
    
    func addObservers() {
        _defaultCenter.addObserver(self, selector: #selector(supportTicketListUpdate(_:)), name: Notification.Name.supportTicketListUpdate, object: nil)
    }
    
    @objc func supportTicketListUpdate(_ notification: NSNotification){
        loadMore = LoadMore()
        getTicketList()
    }
}
// MARK: - WebCall
extension DriverListVC{
    func getTicketList() {
        var param: [String: Any] = [:]
        param["ticket_status"] = selectedTab == 0 ? "Open" : "Close"
        param["offset"] = loadMore.offset
        param["limit"] = loadMore.limit
        
        if !refresh.isRefreshing {
            showCentralSpinner()
        }
        
        WebCall.call.getSupportTicketList(param: param) { [weak self] (json, status) in
            guard let self = self else { return }
            self.hideCentralSpinner()
            self.refresh.endRefreshing()
            
            if status == 200, let data = json as? NSDictionary{
                let count = data.getIntValue(key: "total_ticket")
                if let dict = data["data"] as? [NSDictionary] {
                    if self.loadMore.index == 0 {
                        self.arrTicket = []
                    }
                    for data in dict {
                        self.arrTicket.append(TicketListData(data))
                    }
                    if dict.isEmpty || count == self.arrTicket.count {
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
    
}
extension DriverListVC{
    
}
