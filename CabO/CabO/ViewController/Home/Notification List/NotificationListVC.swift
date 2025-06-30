//
//  NotificationListVC.swift
//  CabO
//
//  Created by Octos.
//

import UIKit

// MARK: - NotificationListVC
class NotificationListVC: ParentVC {
    
    /// Variables
    var arrNotification: [NotificationListModel]!
    var loadMore = LoadMore()

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        getNotificationList()
    }
}

// MARK: - UI Methods
extension NotificationListVC {

    func prepareUI() {
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        tableView.register(NotificationListCell.self, forCellReuseIdentifier: "customCell")
        NoDataCell.prepareToRegisterCells(tableView)
        addRefresh()
    }

    func addRefresh() {
        refresh.addTarget(self, action: #selector(self.refreshing(_:)), for: .valueChanged)
        tableView.refreshControl = refresh
    }

    @objc private func refreshing(_ sender: UIRefreshControl) {
        loadMore = LoadMore()
        self.getNotificationList()
    }
}

// MARK: - TableView Methods
extension NotificationListVC: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return arrNotification == nil ? 0 : 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrNotification.isEmpty ? 1 : arrNotification.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if arrNotification.isEmpty {
            return tableView.frame.height
        } else {
            return UITableView.automaticDimension
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == arrNotification.count - 1 && !loadMore.isLoading && !loadMore.isAllLoaded {
            getNotificationList()
            return showLoadMoreCell()
        } 
        else if arrNotification.isEmpty {
            let cell = tableView.dequeueReusableCell(withIdentifier: NoDataCell.identifier, for: indexPath) as! NoDataCell
            cell.prepareUI(img: UIImage(named: "ic_no_notification")!, title: "No notification found", subTitle: "")
            return cell
        } 
        else {
            let not = arrNotification[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "notificationCell", for: indexPath) as! NotificationListCell
            if !not.image.isEmpty {
                cell.imgView.loadFromUrlString(not.image, placeholder: UIImage(named: "ic_app_icon"))
            } else {
                cell.imgView.image = UIImage(named: "ic_app_icon")
            }
            cell.txtDesc?.text = not.desc
            cell.lblDesc?.text = not.desc
            cell.lblDate.text = Date.localDateString(from: not.date, format: "MMM dd, yyyy hh:mm a")
            return cell
        }
    }
}

// MARK: - API Calls
extension NotificationListVC {

    func getNotificationList() {
        var parameters = [String: Any]()
        parameters["limit"] = loadMore.limit
        parameters["offset"] = loadMore.offset

        if !refresh.isRefreshing && loadMore.index == 0 {
            showCentralSpinner()
        }
        WebCall.call.getNotificationList(param: parameters) { [weak self] (json, status) in
            guard let self = self else { return }
            self.hideCentralSpinner()
            self.refresh.endRefreshing()

            if status == 200, let data = json as? NSDictionary {
                let count = data.getIntValue(key: "total_count")
                if let dict = data["data"] as? [NSDictionary] {
                    if self.loadMore.index == 0 {
                        self.arrNotification = []
                    }
                    for data in dict {
                        self.arrNotification.append(NotificationListModel(data))
                    }
                    if dict.isEmpty || count == self.arrNotification.count {
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
