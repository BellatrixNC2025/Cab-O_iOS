//
//  SupportTicketListVC.swift
//  CabO
//
//  Created by Octos.
//

import UIKit

// MARK: - SupportTicketListCell
class SupportTicketListCell: ConstrainedTableViewCell {
    
    /// Outlets
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblTicketNo: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func prepareUI(_ ticket: TicketListData) {
        lblDate.text = Date.localDateString(from: ticket.createdAt, format: "MMM dd, yyyy hh:mm a")
        lblTicketNo.text = ticket.ticketNo
        lblStatus.text = ticket.status.title
        lblStatus.textColor = ticket.status.color
    }
}

// MARK: - SupportTicketListVC
class SupportTicketListVC: ParentVC {
    
    /// Outlets
    @IBOutlet var tabButtonGradientBg: [UIView]!
    @IBOutlet var tabButtons: [UIButton]!
    
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
        selectedTab = 0
        prepareUI()
        getTicketList()
    }
}

// MARK: - UI Methods
extension SupportTicketListVC {
    
    func prepareUI() {
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 50, right: 0)
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
        self.getTicketList()
    }
    
    func prepareTabSelectionUI() {
        tabButtonGradientBg.forEach({$0.isHidden = selectedTab != $0.tag})
        tabButtons?.forEach({$0.setTitleColor(selectedTab == $0.tag ? UIColor.white : AppColor.primaryText, for: .normal)})
    }
}

// MARK: - Actions
extension SupportTicketListVC {
    
    @IBAction func buttonTabSelection(_ sender: UIButton) {
        if selectedTab != sender.tag {
            selectedTab = sender.tag
            
            loadMore = LoadMore()
            getTicketList()
        } else {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
    
    @IBAction func buttonAddTicketTap(_ sender: UIButton) {
        let vc = AddSupportTicketVC.instantiate(from: .Profile)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - TableView Methods
extension SupportTicketListVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrTicket == nil ? 0 : arrTicket.isEmpty ? 1 : arrTicket.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if arrTicket.isEmpty {
            return _isLandScape ? tableView.frame.width : tableView.frame.height
        } else {
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == arrTicket.count - 1 && !loadMore.isLoading && !loadMore.isAllLoaded {
            getTicketList()
            return showLoadMoreCell()
        }
        if arrTicket.isEmpty {
            return tableView.dequeueReusableCell(withIdentifier: NoDataCell.identifier, for: indexPath)
        } else {
            return tableView.dequeueReusableCell(withIdentifier: "ticketListCell", for: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? NoDataCell {
            cell.prepareUI(title: "No ticket found")
        }
        else if let cell = cell as? SupportTicketListCell {
            cell.prepareUI(arrTicket[indexPath.row])
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
extension SupportTicketListVC {
    
    func addObservers() {
        _defaultCenter.addObserver(self, selector: #selector(supportTicketListUpdate(_:)), name: Notification.Name.supportTicketListUpdate, object: nil)
    }
    
    @objc func supportTicketListUpdate(_ notification: NSNotification){
        loadMore = LoadMore()
        getTicketList()
    }
}


// MARK: - WebCall
extension SupportTicketListVC {
    
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
