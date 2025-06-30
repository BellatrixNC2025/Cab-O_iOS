//
//  ChatHistoryVC.swift
//  CabO
//
//  Created by Octos.
//

import UIKit
import Alamofire

// MARK: - ChatHistoryCell
class ChatHistoryCell: ConstrainedTableViewCell {
    
    /// Outlets
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var imgUserVerify: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblLastMsg: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var viewUnreadCount: UIView!
    @IBOutlet weak var lblUnreadCount: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imgView.image = nil
    }
    
    func prepareUI(_ chat: ChatHistory) {
        imgView.loadFromUrlString(chat.profileImage, placeholder: _userPlaceImage)
        lblUserName.text = chat.userName
        if chat.messageType == .text {
            lblLastMsg.text = chat.message
        } else {
            lblLastMsg.text = "Photo"
        }
        lblTime.text = chat.timeStr
        lblUnreadCount.text = chat.unReadCount.stringValue
        viewUnreadCount.isHidden = chat.unReadCount <= 0
    }
}

// MARK: - ChatHistoryVC
class ChatHistoryVC: ParentVC {
    
    /// Outlets
    @IBOutlet weak var btnSearch: UIButton!
    
    ///Variables
    var arrChatHistory: [ChatHistory]!
    var loadMore = LoadMore()
    var requestTask: DataRequest?
    var isSearchStart = false
    var isScreenReload = false

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        btnSearch.isHidden = true
        getChatHistory()
        addNotificationObserver()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if isScreenReload {
            loadMore = LoadMore()
            getChatHistory()
            isScreenReload = false
        } else {
            tableView.reloadData()
        }
    }
}

// MARK: - UI Methods
extension ChatHistoryVC {
    
    func prepareUI() {
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 50, right: 0)
        addRefresh()
        registerCells()
    }
    
    func addRefresh() {
        refresh.addTarget(self, action: #selector(self.refreshing(_:)), for: .valueChanged)
        self.tableView.refreshControl = refresh
    }
    
    @objc private func refreshing(_ sender: UIRefreshControl) {
        loadMore = LoadMore()
        getChatHistory()
    }
    
    func registerCells() {
        NoDataCell.prepareToRegisterCells(tableView)
    }
    
    private func updateChatCount(_ count: Int) {
        _appDelegator.getTabBarVc()?.unreadCount = count
    }
}

// MARK: - Actions
extension ChatHistoryVC {
    
    @IBAction func btn_searchTap(_ sender: UIButton) {
        let vc = SearchVC.instantiate(from: .Home)
        vc.screenType = .user
        vc.chatSelectBlock = { [weak self] (chat) in
            guard let self = self else { return }
            self.openChat(chat)
        }
        
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: true)
    }
}

// MARK: - TableView Methods
extension ChatHistoryVC : UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return arrChatHistory == nil ? 0 : 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrChatHistory.isEmpty ? 1 : arrChatHistory.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return arrChatHistory.isEmpty ? tableView.frame.height : 74 * _widthRatio
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == arrChatHistory.count - 1 && !loadMore.isLoading && !loadMore.isAllLoaded {
            getChatHistory()
            return showLoadMoreCell()
        }
        if arrChatHistory.isEmpty {
            return tableView.dequeueReusableCell(withIdentifier: NoDataCell.identifier, for: indexPath)
        } else {
            return tableView.dequeueReusableCell(withIdentifier: "chatListCell", for: indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cell = cell as? NoDataCell {
            cell.prepareUI(img: UIImage(named: "ic_no_messages")!, title: "No messages found", subTitle: "")
        }
        else if let cell = cell as? ChatHistoryCell {
            cell.prepareUI(arrChatHistory[indexPath.row])
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !arrChatHistory.isEmpty {
            self.openChat(arrChatHistory[indexPath.row])
        }
    }
}

// MARK: - Notification Observer
extension ChatHistoryVC {
    
    func addNotificationObserver() {
        _defaultCenter.addObserver(self, selector: #selector(chatListUpdated(_:)), name: Notification.Name.chatUpdate, object: nil)
    }
    
    @objc func chatListUpdated(_ notification: NSNotification){
        if let msg = notification.object as? ChatMessage {
            if let indx = msg.isSentByMe ? arrChatHistory.firstIndex(where: {$0.id == msg.receiverID}) : arrChatHistory.firstIndex(where: {$0.id == msg.senderID}) {
                
//                if self.navigationController!.viewControllers.last is ChatVC {
//                    self.arrChatHistory[indx].unReadCount = 0
//                } else {
//                    self.arrChatHistory[indx].unReadCount += 1
//                }
//                
                if let navController = self.navigationController,
                   let currentVC = navController.viewControllers.last as? ChatVC,
                   currentVC.chatHistory.id == msg.senderID || msg.isSentByMe {
                    // If we are currently in a chat with this user, reset unread count
                    self.arrChatHistory[indx].unReadCount = 0
                } else {
                    // Increment unread count for other users
                    self.arrChatHistory[indx].unReadCount += 1
                }
                
                let element = arrChatHistory.remove(at: indx)
                let msgStr = msg.message
                if msgStr.isValidUrlUsingComponents() {
                    element.message = "Photo"
                    element.messageType = .media
                } else {
                    element.message = msg.message
                    element.messageType = .text
                }
                element.date = msg.date
                
                arrChatHistory.insert(element, at: 0)
                self.tableView.reloadData()
            } else {
                loadMore = LoadMore()
                getChatHistory()
            }
        }
    }
}



//MARK: - API call
extension ChatHistoryVC {
    
    func getChatHistory() {
        if !WebCall.call.isInternetAvailable() {
            return
        }
        if !refresh.isRefreshing && loadMore.index == 0 {
            showCentralSpinner()
        }
        loadMore.isLoading = true
        requestTask?.cancel()
        
        var param: [String: Any] = [:]
        param["offset"] = loadMore.offset
        param["limit"] = loadMore.limit
        param["search"] = ""
        
        requestTask = WebCall.call.getChatHistory(param) { [weak self] (json, status) in
            guard let weakSelf = self else { return }
            weakSelf.loadMore.isLoading = false
            weakSelf.hideCentralSpinner()
            weakSelf.refresh.endRefreshing()
            
            if status == 200 {
                if let data = json as? NSDictionary, let meta = data["meta"] as? NSDictionary ,let dataDict = data["data"] as? [NSDictionary] {
                    let totalCount = meta.getIntValue(key: "total_user")
                    
                    let unreadCount = meta.getIntValue(key: "unread_message")
                    weakSelf.updateChatCount(unreadCount)
                    
                    if weakSelf.loadMore.index == 0 {
                        weakSelf.arrChatHistory = []
                    }
                    
                    dataDict.forEach { (dict) in
                        weakSelf.arrChatHistory.append(ChatHistory(dict: dict))
                    }
                    
                    if dataDict.isEmpty || weakSelf.arrChatHistory.count == totalCount {
                        weakSelf.loadMore.isAllLoaded = true
                    } else {
                        weakSelf.loadMore.index += 1
                    }
                    
                    weakSelf.btnSearch.isHidden = weakSelf.arrChatHistory.isEmpty
                    weakSelf.tableView.reloadData()
                    
                    if weakSelf.loadMore.index < 2 {
                        let cells = weakSelf.tableView.visibleCells(in: 0)
                        UIView.animate(views: cells, animations: [weakSelf.tableLoadAnimation])
                    }
                } else {
                    if weakSelf.loadMore.index == 0 {
                        weakSelf.arrChatHistory = []
                    }
                    weakSelf.btnSearch.isHidden = weakSelf.arrChatHistory.isEmpty
                    weakSelf.loadMore.isAllLoaded = true
                    weakSelf.tableView.reloadData()
                }
//                weakSelf.status = .completed
            }else if status != 15 {
//                weakSelf.status = .noResult
                weakSelf.showError(data: json)
            }
        }
    }
}
