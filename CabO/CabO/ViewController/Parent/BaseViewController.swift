import UIKit
import Turf
import NVActivityIndicatorView
import AVKit
import Photos
import RSKImageCropper
import ViewAnimator

@objc protocol RefreshProtocol: NSObjectProtocol{
    @objc optional func refreshController()
    @objc optional func refreshNotification(noti: Notification)
}

/// App Theme
var _appTheme: AppThemeType! {
    get {
        if let darkMode = _userDefault.value(forKey: _CabOAppTheme) as? Int {
            if let theme = AppThemeType(rawValue: darkMode) {
                return theme
            } else {
                return .system
            }
        } else {
            return .system
        }
    }
    set {
        nprint(items: newValue as Any)
    }
}

class ParentVC: UIViewController {
    
    /// Outlets
    @IBOutlet var tableView: UITableView!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var lblTitle: UILabel?
    @IBOutlet var viewNavigation: UIView?
    @IBOutlet var horizontalConstraints: [NSLayoutConstraint]?
    @IBOutlet var verticalConstraints: [NSLayoutConstraint]?
    
    // MARK: - Actions
    /// It will perform pop navigation without animation
    /// - Parameter sender: sender for the event
    @IBAction func parentBackAction(_ sender: UIButton!) {
        _ = self.navigationController?.popViewController(animated: false)
    }
    
    /// It will perform pop navigation with animation
    /// - Parameter sender: sender for the event
    @IBAction func parentBackActionAnim(_ sender: UIButton!) {
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    /// It will dismiss he presened conroller
    /// - Parameter sender: sender for the event
    @IBAction func parentDismissAction(_ sender: UIButton!) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Variables for Pull to Referesh
    let refresh = UIRefreshControl()
    
    // MARK: - Table Data Load Animation
    let tableLoadAnimation = AnimationType.from(direction: .bottom, offset: 30.0)
    
    // MARK: - iOS Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        constraintUpdate()
        setDefaultUI()
        setLoaderUI()
        addThemeObserver()
        nprint(items: "Allocated: \(self.classForCoder)")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if _appTheme != .system {
            self.overrideUserInterfaceStyle = appTheme
        } else {
            _ = self.overrideUserInterfaceStyle
        }
    }
    
    deinit{
        _defaultCenter.removeObserver(self)
        nprint(items: "Deallocated: \(self.classForCoder)")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if _appTheme != .system {
            return _appTheme == .light ? .darkContent : .lightContent
        } else {
            return UITraitCollection.current.userInterfaceStyle == .light ? .darkContent : .lightContent
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if DeviceType.iPad {
            tableView?.reloadData()
        }
    }
    
    // Set Default UI
    func setDefaultUI() {
        refresh.tintColor = AppColor.themePrimary
        tableView?.showsVerticalScrollIndicator = false
        tableView?.showsHorizontalScrollIndicator = false
        tableView?.scrollsToTop = true;
    }
    
    func setLoaderUI() {
        activityIndicator.hidesWhenStopped = false
        activityIndicator.isHidden = false
    }
    
    // This will update constaints and shrunk it as device screen goes lower.
    func constraintUpdate() {
        if let hConts = horizontalConstraints {
            for const in hConts {
                let v1 = const.constant
                let v2 = v1 * _widthRatio
                const.constant = v2
            }
        }
        if let vConst = verticalConstraints {
            for const in vConst {
                let v1 = const.constant
                let v2 = v1 * _heightRatio
                const.constant = v2
            }
        }
    }
    
    // MARK: - Lazy Variables
    lazy internal var activityIndicator : UIActivityIndicatorView = {
        let act = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
        act.color = UIColor.white
        return act
    }()
    
    lazy internal var smallActivityIndicator : CustomActivityIndicatorView = {
        let image : UIImage = UIImage(named: kActivitySmallImageName)!
        return CustomActivityIndicatorView(image: image)
    }()
    
    lazy internal var customActivityIndicator : CustomActivityIndicatorView = {
        let image : UIImage = UIImage(named: kActivitySmallImageName)!
        return CustomActivityIndicatorView(image: image)
    }()
    
    lazy internal var centralActivityIndicator : NVActivityIndicatorView = {
        let act = NVActivityIndicatorView(frame: CGRect.zero, type: NVActivityIndicatorType.ballPulse, color: UIColor.hexStringToUIColor(hexStr: "#394675") | UIColor.hexStringToUIColor(hexStr: "#FFFEFF"), padding: nil)
        return act
    }()
}

// MARK: - App Theme Observer
extension ParentVC {
    
    func addThemeObserver() {
        _defaultCenter.addObserver(self, selector: #selector(self.themeUpdate), name: Notification.Name.themeUpdateNotification, object: nil)
    }
    
    @objc func themeUpdate(){
        self.tableView?.reloadData()
        if let tab = self.tabBarController as? NTabBarVC {
            tab.viewControllers?.forEach({ vc in
                (vc as! ParentVC).updateTheme()
            })
        }
        self.view.setNeedsLayout()
        self.view.layoutSubviews()
    }
    
    func updateTheme() {
        if _appTheme != .system {
            self.overrideUserInterfaceStyle = appTheme
        }
        self.view.setNeedsLayout()
        self.view.layoutSubviews()
    }
}

// MARK: - LoadMore Cell
extension ParentVC {
    
    /// It will show load more cell with activity indicator
    /// - Returns: UITableViewCell
    func showLoadMoreCell() -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "loadMoreCell")
        let activityindicator = UIActivityIndicatorView(style: .medium)
        activityindicator.color = UIColor.hexStringToUIColor(hexStr: "#394675") | UIColor.hexStringToUIColor(hexStr: "#FFFEFF")
        activityindicator.translatesAutoresizingMaskIntoConstraints = false
        cell.contentView.addSubview(activityindicator)
        NSLayoutConstraint.activate([
            activityindicator.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor),
            activityindicator.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 12),
        ])
        activityindicator.startAnimating()
        cell.backgroundColor = .clear
        return cell
    }
}

// MARK: - Uitility Methods
extension ParentVC {
    
    // MARK: - Get Textfiled Cell
    func tableViewCell(index: Int , section : Int = 0) -> UITableViewCell? {
        let cell = tableView.cellForRow(at: IndexPath(row: index, section: section))
        return cell
    }
    
    func scrollToIndex(index: Int, animate: Bool = false, _ at: UITableView.ScrollPosition = .none){
        if index >= 0{
            tableView.scrollToRow(at: IndexPath(row: index, section: 0), at: UITableView.ScrollPosition.none, animated: animate)
        }
    }
    
    func scrollToIndexChat(section: Int, index: Int, animate: Bool = false){
        if index >= 0{
            tableView.scrollToRow(at: IndexPath(row: index, section: section), at: UITableView.ScrollPosition.top, animated: animate)
        }
    }
    
    func scrollToTop(animate: Bool = false) {
        let point = CGPoint(x: 0, y: -tableView.contentInset.top)
        tableView.setContentOffset(point, animated: animate)
    }
    
    func scrollToBottom(animate: Bool = false)  {
        let point = CGPoint(x: 0, y: tableView.contentSize.height + tableView.contentInset.bottom - tableView.frame.height)
        if point.y >= 0{
            tableView.setContentOffset(point, animated: animate)
        }
    }
    
    func customPresentationTransition() {
        let transition = CATransition()
        transition.duration = _vcTransitionTime
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.fade
        view.window?.layer.add(transition, forKey: kCATransition)
    }
}

//MARK: - Activity Indicator
extension ParentVC{
    
    // This will show and hide spinner. In middle of container View
    // You can pass any view here, Spinner will be placed there runtime and removed on hide.
    func showSpinnerIn(container: UIView, control: UIButton, isCenter: Bool) {
        container.addSubview(activityIndicator)
        let xConstraint = NSLayoutConstraint(item: activityIndicator, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: container, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0)
        let yConstraint = NSLayoutConstraint(item: activityIndicator, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: container, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([xConstraint, yConstraint])
        activityIndicator.alpha = 0.0
        view.layoutIfNeeded()
        self.view.isUserInteractionEnabled = false
        activityIndicator.startAnimating()
        UIView.animate(withDuration: 0.2) { () -> Void in
            self.activityIndicator.alpha = 1.0
            if isCenter{
                control.alpha = 0.0
            }
        }
    }
    
    func hideSpinnerIn(container: UIView, control: UIButton) {
        self.view.isUserInteractionEnabled = true
        activityIndicator.stopAnimating()
        control.isSelected = false
        UIView.animate(withDuration: 0.2) { () -> Void in
            self.activityIndicator.alpha = 0.0
            control.alpha = 1.0
        }
    }
    
    func showSmallSpinnerIn(container: UIView, control: UIControl, isCenter: Bool) {
        container.addSubview(smallActivityIndicator)
        let xConstraint = NSLayoutConstraint(item: smallActivityIndicator, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: container, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: -8.5)
        let yConstraint = NSLayoutConstraint(item: smallActivityIndicator, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: container, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: -8.5)
        smallActivityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([xConstraint, yConstraint])
        smallActivityIndicator.alpha = 0.0
        view.layoutIfNeeded()
        self.view.isUserInteractionEnabled = false
        smallActivityIndicator.startAnimating()
        UIView.animate(withDuration: 0.2) { () -> Void in
            self.smallActivityIndicator.alpha = 1.0
            if isCenter{
                control.alpha = 0.0
            }
        }
    }
    
    func hideSmallSpinnerIn(container: UIView, control: UIControl) {
        self.view.isUserInteractionEnabled = true
        smallActivityIndicator.stopAnimating()
        control.isSelected = false
        UIView.animate(withDuration: 0.2) { () -> Void in
            self.smallActivityIndicator.alpha = 0.0
            control.alpha = 1.0
        }
    }
    
    func showSpinnerIn(container: UIView, control: UIView, isCenter: Bool) {
        container.addSubview(activityIndicator)
        let xConstraint = NSLayoutConstraint(item: activityIndicator, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: container, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0)
        let yConstraint = NSLayoutConstraint(item: activityIndicator, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: container, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([xConstraint, yConstraint])
        activityIndicator.alpha = 0.0
        view.layoutIfNeeded()
        activityIndicator.startAnimating()
        UIView.animate(withDuration: 0.2) { () -> Void in
            self.activityIndicator.alpha = 1.0
            if isCenter{
                control.alpha = 0.0
            }
        }
    }
    
    func hideSpinnerIn(container: UIView, control: UIView) {
        activityIndicator.stopAnimating()
        UIView.animate(withDuration: 0.2) { () -> Void in
            self.activityIndicator.alpha = 0.0
            control.alpha = 1.0
        }
    }
    
    func showCentralSpinner() {
        self.view.addSubview(centralActivityIndicator)
        let xConstraint = NSLayoutConstraint(item: centralActivityIndicator, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0)
        let yConstraint = NSLayoutConstraint(item: centralActivityIndicator, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.view, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0)
        let hei = NSLayoutConstraint(item: centralActivityIndicator, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.height, multiplier: 1, constant: 40)
        let wid = NSLayoutConstraint(item: centralActivityIndicator, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.width, multiplier: 1, constant: 40)
        centralActivityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([xConstraint, yConstraint, hei, wid])
        centralActivityIndicator.alpha = 0.0
        self.view.layoutIfNeeded()
        self.view.isUserInteractionEnabled = false
        centralActivityIndicator.startAnimating()
        UIView.animate(withDuration: 0.2) { () -> Void in
            self.centralActivityIndicator.alpha = 1.0
        }
    }
    
    func hideCentralSpinner() {
        self.view.isUserInteractionEnabled = true
        centralActivityIndicator.stopAnimating()
        UIView.animate(withDuration: 0.2) { () -> Void in
            self.centralActivityIndicator.alpha = 0.0
        }
    }
}


// MARK: - Validation Message.
extension ParentVC {
    
    /// Present totast view for some seconds if error occured in api call.
    ///
    /// - Parameters:
    ///   - data: Json error responce
    ///   - view: view in which you want to display error, if nil then toast displayed in window.
    ///   - yCord: YCordinate of totast view, if not passed then display after navigation bar.
    func showError(data: Any?, view: UIView? = nil, yCord: CGFloat = _statusBarHeight) {
        if let dict = data as? NSDictionary{
            if let msg = dict["message"] as? String{
                _ = ValidationToast.showStatusMessage(message: msg, yCord: yCord, inView: view)
            } else if let msg = dict["messages"] as? String{
                _ = ValidationToast.showStatusMessage(message: msg, yCord: yCord, inView: view)
            } else if let msg = dict["error"] as? String{
                _ = ValidationToast.showStatusMessage(message: msg, yCord: yCord, inView: view)
            } else if let msg = dict["_appName".localizedString()] as? String {
                if msg != "kInternetDown".localizedString() {
                    _ = ValidationToast.showStatusMessage(message: msg, yCord: yCord, inView: view)
                }
            } else {
                _ = ValidationToast.showStatusMessage(message: "kInternalError".localizedString(), yCord: yCord, inView: view)
            }
        } else {
            _ = ValidationToast.showStatusMessage(message: "kInternalError".localizedString(), yCord: yCord, inView: view)
        }
    }
    
    /// Present totast view for some seconds if any success message available in api call.
    ///
    /// - Parameters:
    ///   - data: Json error responce
    ///   - view: view in which you want to display error, if nil then toast displayed in window.
    ///   - yCord: YCordinate of totast view, if not passed then display after navigation bar.
    func showSuccessMsg(data: Any?, view: UIView? = nil, yCord: CGFloat = _statusBarHeight) {
        if let dict = data as? NSDictionary{
            if let msg = dict["message"] as? String{
                _ = ValidationToast.showStatusMessage(message: msg,yCord: yCord, inView: view, withColor: AppColor.successToastColor)
            }else if let msg = dict["error"] as? String{
                _ = ValidationToast.showStatusMessage(message: msg, yCord: yCord, inView: view, withColor: AppColor.successToastColor)
            }else if let msg = dict["success"] as? String{
                _ = ValidationToast.showStatusMessage(message: msg, yCord: yCord, inView: view, withColor: AppColor.successToastColor)
            }else if let msg = dict["_appName".localizedString()] as? String {
                if msg != "kInternetDown".localizedString() {
                    _ = ValidationToast.showStatusMessage(message: msg, yCord: yCord, inView: view, withColor: AppColor.successToastColor)
                }
            }else{
                _ = ValidationToast.showStatusMessage(message: "kInternalError".localizedString(), yCord: yCord, inView: view, withColor: AppColor.successToastColor)
            }
        }else{
            _ = ValidationToast.showStatusMessage(message: "kInternalError".localizedString(), yCord: yCord, inView: view, withColor: AppColor.successToastColor)
        }
    }
}

// MARK: - Native confirmation popup
extension ParentVC {
    
    func showConfirmationPopUpView(_ title: String, _ msg: String, btns: [ButtonType], completion: ((ButtonType) -> ())?) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        if _appTheme != .system {
            alert.overrideUserInterfaceStyle = appTheme
        }
        
        for (_, btn) in btns.enumerated() {
            alert.addAction(UIAlertAction(title: btn.title, style: .default, handler: { _ in
                completion?(btn)
            }))
        }
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: - UIPopoverPresentationControllerDelegate
extension ParentVC: UIPopoverPresentationControllerDelegate {
    
    func openPopOver(view: AnyObject, msg: String, arrowDir: UIPopoverArrowDirection = DeviceType.iPad ? [.any] : [.up, .down]) {
        let srRect = view.convert(view.bounds, to: self.view)
        let vc = InfoPopoverVC.instantiate(from: .CMS)
        vc.modalPresentationStyle = .popover
        vc.message = msg
        
        let totalWidth = vc.message.WidthWithNoConstrainedHeight(font: AppFont.fontWithName(FontType.regular, size: 12 * _fontRatio)) + 22 * _widthRatio
        let width: CGFloat = min(300, totalWidth)
        let height = vc.message.heightWithConstrainedWidth(width: width - 20, font: AppFont.fontWithName(FontType.regular, size: 12 * _fontRatio)) + 14 * _widthRatio
        
        vc.preferredContentSize = CGSize(width: width, height: height)
        if let popoverPresentationController = vc.popoverPresentationController {
            popoverPresentationController.permittedArrowDirections = arrowDir
            popoverPresentationController.sourceView = self.view
            popoverPresentationController.sourceRect = srRect
            popoverPresentationController.delegate = self
            popoverPresentationController.backgroundColor = .clear
            popoverPresentationController.popoverLayoutMargins = UIEdgeInsets.zero
        }
        self.present(vc, animated: true) {
            vc.view.superview?.layer.cornerRadius = 6
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        return true
    }
}

// MARK: - Chat
extension ParentVC {
    
    func openChat(_ chat:  ChatHistory) {
        KSocketManager.shared.joinChat(id: chat.id)
        DispatchQueue.main.async {
            self.readChatMsgCount(chat)
            
            let vc = ChatVC.instantiate(from: .Chat)
            vc.chatHistory = chat
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func readChatMsgCount(_ chat: ChatHistory) {
        let param: [String: Any] = ["to_id": chat.id, "from_id": _user!.id]
        
        WebCall.call.readChatMsg(param) { [weak self] (json, status) in
            guard let _ = self else { return }
            if status == 200 {
                _appDelegator.getTabBarVc()?.unreadCount -= chat.unReadCount
                chat.unReadCount = 0
            }
        }
    }
    
    func retrySendMsg(to: ChatHistory, _ dict: [String: Any]) {
        let msg = ChatMessage(dict: dict as NSDictionary)
        KSocketManager.shared.requestSendMessage(to.id, message: msg.message, messageType: msg.msgType, roomID: to.roomId ?? "")
    }
}
