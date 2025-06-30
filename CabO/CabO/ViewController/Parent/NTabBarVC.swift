import UIKit

class NTabBarVC: UITabBarController {
    
    /// Outlets
    @IBOutlet var btnTabs: [UIButton]!
    @IBOutlet weak var tabTopConst: NSLayoutConstraint!
    @IBOutlet weak var tabBarView: NTopRoundCornerView!
    @IBOutlet weak var imgTabChat: UIImageView!
    @IBOutlet weak var vwUnreadCount: UIView!
    @IBOutlet weak var lblUnreadCount: UILabel!
    @IBOutlet weak var unreadCountTop: NSLayoutConstraint!
    @IBOutlet weak var unreadCountBottom: NSLayoutConstraint!
    @IBOutlet weak var unreadCountTrailing: NSLayoutConstraint!
    @IBOutlet weak var unreadCountLeading: NSLayoutConstraint!
    
    /// Variables
    var viewTabs: UIView?
    var selectIndx: Int!
    var unreadCount: Int = 0 {
        didSet {
            updateUnreadCount(unreadCount)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        KSocketManager.connect()
        addCustomTabBar()
        addThemeObserver()
        _appDelegator.getUnreadCount()
        _appDelegator.tabScreenLoaded?()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if _appTheme != .system {
            self.overrideUserInterfaceStyle = appTheme
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if let tabBarView = viewTabs {
            let screenSize = UIScreen.main.bounds.size
            let tabBarHeight = (52 + _bottomBarHeight) * _heightRatio
            tabBarView.frame = CGRect(x: 0, y: screenSize.height - tabBarHeight, width: screenSize.width, height: tabBarHeight)
        }
    }
    
//    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//        if DeviceType.iPad {
//            addCustomTabBar()
//        }
//    }
    
    @IBAction func btnTabTap(_ sender: UIButton) {
        setSelectedIndex(sender.tag)
    }
}

// MARK: - UI & Utility methods
extension NTabBarVC {
    
    private func addCustomTabBar() {
        let homeVc = HomeVC.instantiate(from: .Home)
        let chatVc = ChatHistoryVC.instantiate(from: .Chat)
        let profileVc = ProfileVC.instantiate(from: .Profile)
        
        viewTabs?.removeFromSuperview()
        viewTabs = nil
        
        if DeviceType.iPad, #available(iOS 18.0, *) {
            self.traitOverrides.horizontalSizeClass = .compact
        }
        
        let tabBarView = Bundle.main.loadNibNamed("NTabBar", owner: self, options: nil)?.first as! UIView
        self.viewTabs = tabBarView
        self.viewControllers = [homeVc, chatVc, profileVc]
        tabBarView.frame = CGRect(x: 0, y: _screenSize.height - ((52 + _bottomBarHeight) * _heightRatio), width: _screenSize.width, height: (52 + _bottomBarHeight) * _heightRatio)
        if _appTheme != .system {
            self.tabBar.backgroundColor = _appTheme == .light ? AppColor.appBg : AppColor.appBg
        } else {
            self.tabBar.backgroundColor = AppColor.appBg
        }
        self.tabBar.alpha = 0
        self.updateUnreadCount(0)
        self.view.addSubview(tabBarView)
        setSelectedIndex(self.selectedIndex)
        self.tabBar.isTranslucent = true
    }
    
    func updateUnreadCount(_ count: Int) {
        if count > 0 {
            vwUnreadCount?.isHidden = false
            lblUnreadCount?.text = count > 99 ? "99+" : count.stringValue
            unreadCountTop.constant = 2 //unreadCount > 9 ? 4 : 2
            unreadCountBottom.constant = 2 //unreadCount > 9 ? 4 : 2
            unreadCountLeading.constant = (count > 9 ? 4 : 6) * _widthRatio
            unreadCountTrailing.constant = (count > 9 ? 4 : 6) * _widthRatio
        } else {
            vwUnreadCount?.isHidden = true
        }
    }
    
    func increaseCounter(_ count: Int = 1) {
        unreadCount += count
        self.updateUnreadCount(unreadCount)
    }
    
    func setSelectedIndex(_ indx: Int) {
        self.selectedIndex = indx
        selectIndx = indx
        for btn in btnTabs {
            btn.isSelected = btn.tag == indx
        }
        imgTabChat.image = UIImage(named: selectIndx == 1 ? "tab_chat_selected" : "tab_chat")
    }
}

// MARK: - Theme Observer
extension NTabBarVC {
    
    func addThemeObserver() {
        _defaultCenter.addObserver(self, selector: #selector(self.themeUpdate(_:)), name: Notification.Name.themeUpdateNotification, object: nil)
    }
    
    @objc func themeUpdate(_ notification: NSNotification){
        if DeviceType.iPad, #available(iOS 18.0, *) {
            self.traitOverrides.horizontalSizeClass = .compact
        }
        
        self.viewControllers?.removeAll()
        let homeVc = HomeVC.instantiate(from: .Home)
        let chatVc = ChatHistoryVC.instantiate(from: .Chat)
        let profileVc = ProfileVC.instantiate(from: .Profile)
        self.viewControllers = [homeVc, chatVc, profileVc]
        self.setSelectedIndex(selectIndx)
    }
}
