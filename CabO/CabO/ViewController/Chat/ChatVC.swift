//
//  ChatVC.swift
//  CabO
//
//  Created by Octos.
//

import UIKit
import Photos
import Turf
import Mantis

class ChatSendImg {
    var img: UIImage!
    var croppedImg: UIImage?
    var transformation: Mantis.Transformation?
    var cropInfo: Mantis.CropInfo?
    
    var image: UIImage {
        if let croppedImg = croppedImg {
            return croppedImg
        }
        return img
    }
    
    init(_ img: UIImage) {
        self.img = img
    }
}

// MARK: - ChatOptButons
enum ChatOptButons {
    case userInfo, clear, block, unblock, delete
    
    var title: String {
        switch self {
        case .userInfo: return "User info"
        case .clear: return "Clear chat"
        case .block: return "Block user"
        case .unblock: return "Unblock user"
        case .delete: return "Delete chat"
        }
    }
}

// MARK: - ChatVC
class ChatVC: ParentVC {
    
    /// Outlets
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblChatDisable: UILabel!
    @IBOutlet weak var btnOptions: UIButton!
    @IBOutlet weak var vwChatDisable: UIView!
    @IBOutlet weak var viewInput: UIView!
    @IBOutlet weak var inputBottomContraint: NSLayoutConstraint!
    @IBOutlet weak var btnUserProfile: UIButton!
    
    ///Variables
    var imagePicker: UIImagePickerController!
    var loadMore = LoadMore()
    var chatHistory: ChatHistory!
    var msgs:[ChatMessage] = []
    var secMsgs: [ChatMsgSection]!
    var count: Int = 0
    var tableDidScroll: Bool = false
    var isNewMsgReceive = false
    var isChatEnable: Bool = true
    var isChatBlock: Bool = false
    var callBack: (() -> ())?
    var autoMsgID: Int = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        joiningChat()
        getMessages(showSpinner: true, force: true)
        addSocketNotificationObserver()
        addKeyboardObserver()
    }
    
    lazy var messageInputBar: MessageInputBar = {
        return MessageInputBar.loadMessageInputBar(delegate: self)
    }()
    
    deinit {
        _defaultCenter.removeObserver(self)
        leaveChatRoom()
    }
    
    //Leave Chat Channel Call
    func leaveChatRoom() {
        KSocketManager.shared.leaveChat(id: chatHistory.roomId ?? "")
        KSocketManager.disconnect()
    }
}

extension Date {
    func startOfDay() -> Date {
        return Calendar.current.startOfDay(for: self)
    }
}

// MARK: - UI Methods
extension ChatVC {
    
    func prepareUI() {
        tableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0)
        lblUserName.text = chatHistory.userName
        imgProfile.loadFromUrlString(chatHistory.profileImage, placeholder: _userPlaceImage)
        
        viewInput.addSubview(messageInputBar)
        messageInputBar.addConstraintToSuperView(lead: 0, trail: 0, top: 0, bottom: 0)
        
        registerCells()
        prepareOptionMenu()
    }
    
    func registerCells() {
        NoDataCell.prepareToRegisterCells(tableView)
        ChatMsgTblCell.prepareToRegisterCells(tableView)
    }
    
    func checkChatDisable() {
        vwChatDisable.isHidden = isChatEnable
        viewInput.isHidden = !isChatEnable
    }
    
    func prepareOptionMenu() {
        var menuElements: [UIAction] = []
        var buttons: [ChatOptButons] = []
        if !isChatBlock {
            buttons = [.block]
        } else {
            buttons = [.unblock]
        }
        buttons.forEach { btn in
            menuElements.append(UIAction(title: btn.title, image: nil, identifier: nil, discoverabilityTitle: nil, attributes: [], state: .off, handler: { [weak self] action in
                guard let `self` = self else { return }
                if btn == .block || btn == .unblock {
                    self.blockUnblockChat()
                }
            }))
        }
        btnOptions.menu = UIMenu(title: "", children: menuElements)
    }
    
    func scrollForPaginationData(lastCount: Int) {
        var section = 0
        var index = 0
        var total = lastCount
        for (idx,sec) in self.secMsgs.enumerated(){
            section = idx
            total -= sec.messages.count
            if total <= 0{
                index = sec.messages.count + total
                index = index != 0 ? index - 1 : index
                break
            }
        }
        self.scrollToIndexChat(section: section, index: index, animate: false)
    }
    
    func createSectionOfMessages() {
        let group: [Date: [ChatMessage]] = groupMessagesByUniqueDates(messages: msgs)
        
        secMsgs = group
            .sorted(by: { $0.key < $1.key }) // Sort groups by date
            .map { ChatMsgSection(date: $0.key, arr: $0.value) } // Transform into sections
        
        tableView.reloadData()
    }
    
    func action_sendImage(_ sender: UIButton) {
        PhotoLibraryManager.shared.setup(.images, in: self, source: sender)
    }
    
    func groupMessagesByUniqueDates(messages: [ChatMessage]) -> [Date: [ChatMessage]] {
        // Step 1: Extract unique dates (normalized to the start of the day)
        let uniqueDates = Array(Set(messages.map { $0.date.startOfDay() })).sorted()
        
        // Step 2: Create the grouped dictionary
        var groupedMessages: [Date: [ChatMessage]] = [:]
        
        for date in uniqueDates {
            // Filter messages for the current date
            let dayMessages = messages.filter { $0.date.startOfDay() == date }
            groupedMessages[date] = dayMessages
        }
        
        return groupedMessages
    }
}

// MARK: - Actions
extension ChatVC {
    
    @IBAction func btnBackTap(_ sender: UIButton) {
        self.view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
        
        KSocketManager.shared.leaveChat(id: chatHistory.roomId ?? "")
        KSocketManager.disconnect()
        
        self.callBack?()
    }
    
    @IBAction func btn_opne_user_profile(_ sender: UIButton) {
        guard _hostMode == .dev else { return }
        
        if isChatEnable {
            let vc = UserDetailVC.instantiate(from: .Home)
            vc.userId = chatHistory.id.integerValue
            vc.isDriver = false
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// MARK: MessageInputBar Delegate
extension ChatVC: MessageInputBarDelegate {

    func messageInputBar(didTap action: MessageInputBarAction) {
       
        switch action {
        case .send:
            if !messageInputBar.txtV.text!.trimmedString().isEmpty {
                sendMsg(messageInputBar.txtV.text!.trimmedString())
            }
        case .camera:
            view.endEditing(true)
            PhotoLibraryManager.shared.setup(.images, in: self, source: messageInputBar.btnSend)
            messageInputBar.dismissKeyboard()
        default:
            break
        }
    }
    
    private func sendMsg(_ txt: String) {
        sendChat(msg: txt, msgType: .text)
    }
    
    func sendImage(_ img: UIImage) {
        uploadImage(img)
    }
    
    func uploadImage(_ img: UIImage) {
        showCentralSpinner()
        AWSS3Manager.shared.uploadImage(image: img, progress: { (progress) in
            debugPrint("upload progress : \(Float(progress))")
        }) { [weak self] (uploadedFileUrl, error,presignedUrl) in
            guard let weakSelf = self else { return }
            weakSelf.hideCentralSpinner()
            
            if let url = uploadedFileUrl as? String, let fileName = URL(string: url)?.lastPathComponent {
                weakSelf.getS3Url(fileName) { [weak self] (url) in
                    guard let self = self else { return }
                    if let url = url, !url.isEmpty {
                        self.sendChat(msg: url, media_name: fileName, msgType: .media)
                    }
                }
            }
        }
    }
    
    func getS3Url(_ filename: String, completion: @escaping (String?) -> ()) {
        showCentralSpinner()
        WebCall.call.getS3ImageUrl(filename) { [weak self] (json, status) in
            guard let self = self else { return }
            self.hideCentralSpinner()
            if status == 200, let dict = json as? NSDictionary, let data = dict["data"] as? NSDictionary {
                let url = data.getStringValue(key: "image")
                completion(url)
            } else {
                self.showError(data: json, yCord: _navigationHeight)
                completion(nil)
            }
        }
    }
    
    func confirmSendImage(_ img: UIImage) {
        let vc = KPImagePreview(objs: [ChatSendImg(img)], sourceRace: nil, selectedIndex: nil, type: .send)
        vc.callBack = { [weak self] (cImg) in
            guard let self = self else { return }
            guard let cImg = cImg else { return }
            self.sendImage(cImg.image)
        }
        vc.modalPresentationStyle = .fullScreen
        DispatchQueue.main.async {
            self.present(vc, animated: true)
        }
    }
    
    func openMsgImagePreview(_ img: String) {
        let vc = KPImagePreview(objs: [img], sourceRace: nil, selectedIndex: nil, type: .preview)
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .crossDissolve
        DispatchQueue.main.async {
            self.present(vc, animated: true)
        }
    }
}

//MARK: - PhotoLibraryDelegate
extension ChatVC: PhotoLibraryDelegate {
    
    func cameraMedia(_ image: UIImage) {
        confirmSendImage(image)
    }
    
    func photoLibrary(didFinishedPicking media: [PHAsset]) {
        if let imageAsset = media.first {
            if imageAsset.mediaType == .image {
                let image = PhotoLibraryManager.shared.getImage(from: imageAsset)
                self.confirmSendImage(image)
            } else {
                nprint(items: "video is selected")
            }
        }
    }
    
    func didCancelPicking() {
        nprint(items: "Media pick canceled")
    }
}

// MARK: - Tableview methode
extension ChatVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if secMsgs == nil {
            return 0
        } else {
            return secMsgs.isEmpty ? 1 : secMsgs.count
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if secMsgs.isEmpty {
            return 1
        } else {
            return secMsgs[section].messages.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if secMsgs.isEmpty {
            return _isLandScape ? tableView.frame.width : tableView.frame.height
        } else {
            let msg = secMsgs[indexPath.section].messages[indexPath.row]
            if msg.msgType == .text {
                if indexPath.row + 1 < secMsgs[indexPath.section].messages.count && msg.isSentByMe == secMsgs[indexPath.section].messages[indexPath.row + 1].isSentByMe {
                    return msg.message.heightWithConstrainedWidth(width: _screenSize.width - ((70 + 24) * _widthRatio), font: AppFont.fontWithName(.regular, size: 12 * _fontRatio)) + ((27) * _widthRatio) + (18 * _widthRatio)
                } else {
                    return msg.message.heightWithConstrainedWidth(width: _screenSize.width - ((70 + 24) * _widthRatio), font: AppFont.fontWithName(.regular, size: 12 * _fontRatio)) + ((41 + 24) * _widthRatio)
                }
            } else { 
                if indexPath.row + 1 < secMsgs[indexPath.section].messages.count && msg.isSentByMe == secMsgs[indexPath.section].messages[indexPath.row + 1].isSentByMe {
                    return (166 * _widthRatio) + (16 * _widthRatio)
                } else {
                    return (166 + 24) * _widthRatio
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return secMsgs.isEmpty ? CGFloat.leastNonzeroMagnitude : 34 * _widthRatio
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return CGFloat.leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if secMsgs.isEmpty {
            return nil
        }
        let view = tableView.dequeueReusableCell(withIdentifier: "headerChatCell") as! ChatMsgTblCell
        view.lblMsg.text = secMsgs[section].date.getChatSectionHeader()
        return view
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 && indexPath.section == 0 && loadMore.canFetch {
            getMessages()
            return showLoadMoreCell()
        }
        var cellID = ""
        if secMsgs.isEmpty {
            cellID = NoDataCell.identifier
        } else {
            let msg = secMsgs[indexPath.section].messages[indexPath.row]
            cellID = msg.isSentByMe ? msg.msgType == .text ? "sendMsgCell" : "sendImgCell" : msg.msgType == .text ? "receiveMsgCell" : "receiveImgCell"
        }
       return tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let noDataCell = cell as? NoDataCell {
            noDataCell.prepareUI(img: UIImage(systemName: "message.circle.fill")!.withTintColor(AppColor.primaryText, renderingMode: .alwaysTemplate), title: "No messsages yet", subTitle: "")
        } else if let contentCell = cell as? ChatMsgTblCell {
            let msg = secMsgs[indexPath.section].messages[indexPath.row]
            
            contentCell.lblTime.isHidden = false
            if indexPath.row + 1 < secMsgs[indexPath.section].messages.count {
//                contentCell.lblTime.isHidden = msg.isSentByMe == secMsgs[indexPath.section].messages[indexPath.row + 1].isSentByMe
                contentCell.tailImg.isHidden = msg.isSentByMe == secMsgs[indexPath.section].messages[indexPath.row + 1].isSentByMe
            } else {
                contentCell.tailImg.isHidden = false
            }
            
            contentCell.lblTime.text = msg.timeStr
            
            if msg.msgType == .text {
                contentCell.lblMsg.text = msg.message
            } else {
                if let img = msg.tempImage {
                    contentCell.imgView.image = img
                } else {
                    contentCell.imgView.loadFromUrlString(msg.image, placeholder: _dummyPlaceImage)
                }
                
                contentCell.action_image_preview = { [weak self] in
                    guard let self = self else { return }
                    self.openMsgImagePreview(msg.message)
                }
            }
            
            let tail = UIImage(named: "chat_tail")?.withTintColor(msg.isSentByMe ? AppColor.headerBg : AppColor.vwBgColor)
            contentCell.tailImg.image = msg.isSentByMe ? tail : tail!.withHorizontallyFlippedOrientation()
            
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !secMsgs.isEmpty {
            let msg = secMsgs[indexPath.section].messages[indexPath.row]
            if msg.msgType == .media, let cell = tableViewCell(index: indexPath.row, section: indexPath.section) as? ChatMsgTblCell {
                
                let imgRect = cell.convert(cell.imgView.frame, to: self.view)
                let msgs = Array(secMsgs.map({$0.messages.filter({$0.msgType == .media})}).joined())
                let urls = msgs.map({$0.image})
                let vc = KPImagePreview.init(objs: urls as [AnyObject], sourceRace: imgRect, selectedIndex: msgs.firstIndex(of: msg), placeImg: _dummyPlaceImage)
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
}

//MARK: - Scroll TableView Methods
extension ChatVC {

    //TableView ScrollView Method
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        checkForDownArrow()
    }
    
    func scrollTo(atIndex index: Int, section: Int = 0, animate: Bool = false, scrollPosition: UITableView.ScrollPosition = .top) {
        if index >= 0 , !msgs.isEmpty {
            let indexPath = IndexPath(item: index, section: section)
            self.tableView.scrollToRow(at: indexPath, at: scrollPosition, animated: animate)
        }
    }
    
    func scrollsToBottom(_ animated: Bool = false)  {
        count = 0
        self.tableView.scrollToRow(at: IndexPath(row: secMsgs[secMsgs.count - 1].messages.count - 1, section: secMsgs.count - 1), at: .bottom, animated: true)
    }
}

// MARK: - UIKeyboard Observer
extension ChatVC {
    
    func addKeyboardObserver() {
        _defaultCenter.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        _defaultCenter.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: NSNotification){
        if let userInfo = notification.userInfo {
            if let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                guard let _ = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {return}
                self.inputBottomContraint.constant = keyboardSize.height - _bottomAreaSpacing
                self.view.layoutIfNeeded()
                scrollToBottom()
            }
        }
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification){
        self.inputBottomContraint.constant = 0
        self.view.layoutIfNeeded()
        tableView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0)
    }
}

//MARK: - Socket Related API Methods
extension ChatVC {
    
    //Socket Notifiaction Observer Call
    func addSocketNotificationObserver() {
        _defaultCenter.addObserver(self, selector: #selector(self.socketConnectionStateChangeNotification(_:)), name: .observerSocketConnectionStateChange, object: nil)
        _defaultCenter.addObserver(self, selector: #selector(self.socketChatJoin(_:)), name: .observerSocketJoinChat, object: nil)
        _defaultCenter.addObserver(self, selector: #selector(self.socketSendMsg(_:)), name: .observerSocketSendMessage, object: nil)
        _defaultCenter.addObserver(self, selector: #selector(self.socketChatMsgWentWrong(_:)), name: .observerSocketWentWrong, object: nil)
        _defaultCenter.addObserver(self, selector: #selector(manageWillEnterForgorund(_:)), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    //Socket Connection State Change
    @objc func socketConnectionStateChangeNotification(_ sender: Notification) {
        if KSocketManager.shared.socket.status == .connected {
            // socket is connected
            self.joiningChat()
//            ValidationToast.showStatusMessage(message: "Connected...", withColor: AppColor.appBg)
        } else {
//            ValidationToast.showStatusMessage(message: "Connecting...", withColor: AppColor.appBg)
        }
    }
    
    @objc func manageWillEnterForgorund(_ sender: Notification) {
        loadMore = LoadMore()
        getMessages(showSpinner: true, force: true)
    }
    
    //Socket Chat Join
    @objc func socketChatJoin(_ sender: Notification) {
        nprint(items: "chat connected")
//        ValidationToast.showStatusMessage(message: "Chat Connected...", withColor: AppColor.appBg)
    }
    
    //Socket Chat Msg Went Wrong
    @objc func socketChatMsgWentWrong(_ sender: Notification) {
        if let arr = sender.object as? [[String: Any]], !arr.isEmpty, let dict = arr.first{
            nprint(items: "SOCKET Receive MSG : ", dict)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.retrySendMsg(to: self.chatHistory, dict)
            }
        }
//        ValidationToast.showStatusMessage(message: "kSomethingWentWrong".localizedString(), yCord: _navigationHeight)
    }
    
    //Sockt Send/Receive Msg
    @objc func socketSendMsg(_ sender: Notification) {
        if let arr = sender.object as? [[String: Any]], !arr.isEmpty, let dict = arr.first, let data = dict["data"] as? NSDictionary {
            if data.getStringValue(key: "chat_room") != chatHistory!.roomId { return }
            nprint(items: "SOCKET Receive MSG : ", data)
            readChatMsgCount(chatHistory!)
            let msg = ChatMessage(msg: data)
            if !msg.isSentByMe {
                self.addMsg(msg)
            }
        }
        //If count is zero then scroll the msg to bottom of table
        if count == 0 {
            self.scrollsToBottom()
        }
    }
    
    //Joining Chat Channel Call
    func joiningChat() {
        guard let bId = chatHistory?.id else { return }
        KSocketManager.shared.joinChat(id: bId)
    }
    
    //Send Chat Channel Call
    func sendChat(msg: String, media_name: String? = nil, msgType: ChatMsgType) {
        guard let to = chatHistory else { return }
        KSocketManager.shared.requestSendMessage(to.id, message: msg, media_name: media_name, messageType: msgType, roomID: to.roomId ?? "")
        let msg = ChatMessage(receiverId: to.id, msgType: msgType, message: msg)
        self.addMsg(msg)
    }
    
    func addMsg(_ msg: ChatMessage) {
        msgs.append(msg)
        count += 1
        self.createSectionOfMessages()
        if msg.msgType == .media {
            self.chatHistory.message = "Photo"
        } else {
            self.chatHistory.message = msg.message
        }
        self.chatHistory.messageType = msg.msgType
        self.chatHistory.date = msg.date
        
        _defaultCenter.post(name: Notification.Name.chatUpdate, object: msg)
        self.tableView.scrollToRow(at: IndexPath(row: secMsgs[secMsgs.count - 1].messages.count - 1, section: secMsgs.count - 1), at: .bottom, animated: true)
    }
}

//MARK: - API calls
extension ChatVC {
    
    func getMessages(showSpinner: Bool = false, force: Bool = false) {
        guard let toId = chatHistory?.id, (loadMore.canFetch && !force || force) else { return }
        if showSpinner {
            self.showCentralSpinner()
        }
        loadMore.isLoading = true
        
        var param: [String: Any] = ["from_id": _user!.id, "to_id": toId]
        param["offset"] = loadMore.offset
        param["limit"] = loadMore.limit
        
        WebCall.call.getChat(param: param) { [weak self] (json, status) in
            guard let weakSelf = self else { return }
            weakSelf.hideCentralSpinner()
            if status == 200 {
                var total: Int = 0
                if let metaData = (json as? NSDictionary)?["meta"] as? NSDictionary {
                    total = metaData.getIntValue(key: "total_message")
                    if weakSelf.chatHistory.roomId == nil {
                        weakSelf.chatHistory.roomId = metaData.getStringValue(key: "chat_room_id")
                    }
                    weakSelf.isChatEnable = !metaData.getBooleanValue(key: "chat_disable")
                    weakSelf.isChatBlock = metaData.getBooleanValue(key: "is_block")
                    weakSelf.vwChatDisable.isHidden = weakSelf.isChatEnable
                    weakSelf.viewInput.isHidden = !weakSelf.isChatEnable
                    weakSelf.prepareOptionMenu()
                }
                
                if !weakSelf.isChatEnable {
//                    weakSelf.lblChatDisable.text = "Chat is blocked."
                }
                
                if let arr = (json as? NSDictionary)?["data"] as? [NSDictionary] {
                    if weakSelf.loadMore.index == 0 {
                        weakSelf.msgs = []
                    }
                    for dict in arr {
                        let msg = ChatMessage(dict: dict)
                        weakSelf.msgs.append(msg)
                    }
                    
                    if arr.isEmpty || arr.count == total {
                        weakSelf.loadMore.isAllLoaded = true
                    }
                    weakSelf.loadMore.index += 1
                    weakSelf.createSectionOfMessages()
                    if weakSelf.loadMore.index == 1 { //} || weakSelf.loadMore.offset == 2 {
                        weakSelf.scrollToBottom()
                        weakSelf.loadMore.isLoading = false
                    } else {
                        weakSelf.scrollForPaginationData(lastCount: arr.count + 1)
                        weakSelf.loadMore.isLoading = false
                    }
                } else {
                    weakSelf.createSectionOfMessages()
                    weakSelf.loadMore.isAllLoaded = true
                }
            } else {
                weakSelf.loadMore.isLoading = false
                weakSelf.showError(data: json, view: weakSelf.view)
            }
            weakSelf.loadMore.isFirstTime = true
            weakSelf.loadMore.isLoading = false
        }
//        joiningChat()
    }
    
    func blockUnblockChat() {
        self.view.endEditing(true)
        let param: [String: Any] = ["to_id" : chatHistory.id]
        showCentralSpinner()
        WebCall.call.blockUnblockChat(param: param) { [weak self] (json, status) in
            guard let self = self else { return }
            self.hideCentralSpinner()
            if status == 200, let dict = json as? NSDictionary, let data = dict["data"] as? NSDictionary {
                self.isChatEnable = !data.getBooleanValue(key: "chat_disable")
                self.isChatBlock.toggle() // = data.getBooleanValue(key: "is_block")
                self.prepareOptionMenu()
                self.checkChatDisable()
            } else {
                self.showError(data: json, yCord: _navigationHeight)
            }
        }
    }
}
