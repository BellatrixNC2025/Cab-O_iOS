//
//  AppDelegate.swift
//  CabO
//
//  Created by Octos.
//

import UIKit
import CoreData
import Kingfisher
import UserNotifications
import Firebase
import FirebaseMessaging
import RSKImageCropper
import StripeCore
import GoogleMaps
import GooglePlaces
import AWSCore

import BackgroundTasks
import WidgetKit
import IQKeyboardManagerSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var tabScreenLoaded:(() -> ())?
    var config: Config = Config()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        for family in UIFont.familyNames.sorted() {
            for name in UIFont.fontNames(forFamilyName: family) {
                print("Font: \(name)")
            }
        }
        checkForAppUpdate()
        IQKeyboardManager.shared.isEnabled = false
//        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        GMSPlacesClient.provideAPIKey(googleKey)
        GMSServices.provideAPIKey("AIzaSyDlcNgnMyVQGI6pNOsv8vUA_madpVrLeMg")  //("AIzaSyBL0xEwJ1ucx_VL-00l-ZavkTD2boexj9M")
        
        return true
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CabO")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
//        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
//            if let error = error as NSError? {
//                fatalError("Unresolved error \(error), \(error.userInfo)")
//            }
//        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    var managedObjectContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        KSocketManager.disconnect()
    }
    
}

let ecAuthTokenKey = "ECAuthTokenKey"

// MARK: - Authorization token
extension AppDelegate {
    
    func storeAuthorizationToken(_ strToken: String) {
        WebCall.call.setAccesTokenToHeader(token: strToken)
        _userDefault.set(strToken, forKey: ecAuthTokenKey)
        _userDefault.synchronize()
    }
    
    func getAuthorizationToken() -> String? {
        return _userDefault.value(forKey: ecAuthTokenKey) as? String
    }
}

// MARK: - App Update
extension AppDelegate {
    
    func checkForAppUpdate() {
        WebCall.call.getLatestVersion() { [weak self] (json, status) in
            guard let weakSelf = self else { return }
            if let dict = json as? NSDictionary, let dataDict = dict["data"] as? NSDictionary {
                let update = UpdateModel(dict: dataDict)
                weakSelf.checkVersion(update)
            }
        }
    }
    
    func checkVersion(_ update: UpdateModel) {
        if getAppversion() < update.minVersion {
            presentAlertForUpdate(.force, update)
        }
        else if update.maxVersion > getAppversion(){
            presentAlertForUpdate(update.updateType, update)
        }
    }
    
    func presentAlertForUpdate(_ updateType: UpdateType, _ update: UpdateModel) {
        let alert = UIAlertController(title: "New version available", message: update.message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Update", style: .default, handler: { (action) in
            if let url = URL(string: _app_iTunes_URL), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }))
        if updateType == .optional {
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        }
        self.window?.rootViewController?.present(alert, animated: true, completion: nil)
    }
}

// MARK: - AWS Configuration
extension AppDelegate {
    
    func configureAWS(){
        let credentialsProvider = AWSStaticCredentialsProvider(accessKey: _appDelegator.config.aws_key , secretKey: _appDelegator.config.aws_secret)
        let configuration = AWSServiceConfiguration(region: getAWSRegionPointFromName(_appDelegator.config.aws_region) , credentialsProvider: credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
    }
    
    func getAWSRegionPointFromName(_ name : String) -> AWSRegionType {
        
        if name == "USWest1" || name == "us-west-1"{
            return .USWest1
        }else if name == "USWest2" || name == "us-west-2"{
            return .USWest2
        }else if name == "USEast1" || name == "us-east-1"{
            return .USEast1
        }else if name == "USEast2"  || name == "us-east-2"{
            return .USEast2
        }else{
            return .USWest1
        }
    }
}

//MARK: - Navigation
extension AppDelegate {
    
    func getAppCnfig() {
        WebCall.call.getConfig { [weak self] (json, status) in
            guard let self = self else { return }
            if status == 200, let dict = json as? NSDictionary, let dData = dict["data"] as? [NSDictionary] {
                var param: [String: Any] = [:]
                dData.forEach { data in
                    let key = data.getStringValue(key: "alias_name")
                    let value = data.getStringValue(key: "setting_value")
                    param[key] = value
                }
                self.config = Config(param as NSDictionary)
                self.configureAWS()
                StripeAPI.defaultPublishableKey = config.stripe_key
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.getAppCnfig()
                }
            }
        }
    }
    
    /// It will get user profile
    /// - Parameter block: Complition block
    func getUserProfile(updateToken: Bool = true , block: ((Bool, Any?) -> ())?) {
        WebCall.call.getUserProfile { (json, status) in
            if status == 200, let dict = json as? NSDictionary, let dData = dict["data"] as? NSDictionary, let data = dData["profile_information"] as? NSDictionary {
                _user = User.addUpdateEntity(key: "id", value: data.getStringValue(key: "id"))
                _user?.initWith(data)
                
                if updateToken {
                    if !Setting.fcmToken.isEmpty && _user != nil{
                        WebCall.call.updatePushToken(param: ["user_id": _user!.id]) { (json, status) in
                            nprint(items: "Device Token Updated")
                        }
                    }
                }
                _appDelegator.saveContext()
                block?(true, json)
            } else {
                block?(false, json)
            }
        }
    }
    
    func isUserLoggedIn() -> Bool{
        let users = User.fetchDataFromEntity(predicate: nil, sortDescs: nil)
        if getAuthorizationToken() != nil && !users.isEmpty {
            _user = users.first
            return true
        } else {
            return false
        }
    }
    
    func isAppOpenForFirstTime() {
        if let nav = _appDelegator.window?.rootViewController as? KPNavigationViewController {
            if let isFirstTime = _userDefault.object(forKey: "firstOpen") as? Bool, !isFirstTime {
                let loginVC = LoginVC.instantiate(from: .Auth)
                nav.viewControllers = [loginVC]
            } else {
               
                
                let walkThroughVC = WalkthroughVC.instantiate(from: .Auth)
                nav.viewControllers = [walkThroughVC]
            }
        }
    }
    
    /// It will navigate to home
    /// - Parameter isNewUser: is navigating from signup then user is new
    func navigateUserToHome() {
        let nav = _appDelegator.window?.rootViewController as! KPNavigationViewController
        _ = UIStoryboard.init(name: "Auth", bundle: nil).instantiateViewController(withIdentifier: "LoginVC")
        let homeVC = UIStoryboard.init(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "HomeVC")
        nav.viewControllers = [homeVC]
        _appDelegator.window?.rootViewController = nav
    }
    
    func prepareForLogout(block: @escaping ((Bool, Any?) -> ())) {
        WebCall.call.logoutUser { (json, status) in
            if status == 200 {
                block(true, json)
                _userDefault.removeObject(forKey: _locationSearchHistory)
                self.removeUserInfoAndNavToLogin()
            } else {
                block(false, json)
            }
        }
    }
    
    func removeUserInfoAndNavToLogin() {
        _userDefault.removeObject(forKey: ecAuthTokenKey)
        _userDefault.synchronize()
        WebCall.call.removeAccessTokenFromHeader()
        deleteUserObject()
        DispatchQueue.main.async {
            self.redirectToLoginScreen()
        }
    }
    
    func deleteUserObject() {
        _user = nil
        let users = User.fetchDataFromEntity(predicate: nil, sortDescs: nil)
        for user in users {
            _appDelegator.managedObjectContext.delete(user)
        }
        _appDelegator.saveContext()
    }
    
    func redirectToLoginScreen() {
        let nav = _appDelegator.window?.rootViewController as! KPNavigationViewController
        let entVC = UIStoryboard.init(name: "Auth", bundle: nil).instantiateViewController(withIdentifier: "LoginVC")
        nav.viewControllers = [entVC]
        _appDelegator.window?.rootViewController = nav
    }
}

// MARK: - Firebase Notification
extension AppDelegate: UNUserNotificationCenterDelegate, MessagingDelegate {
    
    func registerDeviceForPushNotification() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.badge, .alert, .sound]) { [weak self] (granted, error) in
            guard let weakSelf = self else { return }
            guard granted else { return }
            weakSelf.getNotificationSetting()
        }
    }
    
    func getNotificationSetting() {
        UNUserNotificationCenter.current().getNotificationSettings { (setting) in
            nprint(items: setting)
            guard setting.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        nprint(items: ["Did Receive", userInfo])
        if let push = PushNotification(dict: userInfo as NSDictionary) {
            self.redirectionFromPush(push)
        }
        completionHandler(.noData)
        return
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if let info = response.notification.request.content.userInfo as? [String: Any] {
            nprint(items: ["Did Receive in Notification", info])
            if let push = PushNotification(dict: info as NSDictionary) {
                self.navigateUserForPush(push)
            }
        }
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if let dict = notification.request.content.userInfo as? [String: Any] {
            if let push = PushNotification(dict: dict as NSDictionary) {
                if push.type == .chat_message {
                    getTabBarVc()?.increaseCounter()
                    _defaultCenter.post(name: Notification.Name.chatUpdate, object: ChatMessage(push))
                }
            }
        }
        completionHandler([.badge, .banner, .list, .sound])
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        if let fcmToken {
            nprint(items: ["This is fcm token",fcmToken])
            Setting.deviceToken = fcmToken
            Setting.fcmToken = fcmToken
            
            if let usr = _user {
                delay(3) {
                    WebCall.call.updatePushToken(param: ["user_id": usr.id]) { (json, status) in
                        nprint(items: "Device Token Updated")
                    }
                }
            }
        }
    }
    
    func getUnreadCount() {
        WebCall.call.getUnReadCount { [weak self] (json, status) in
            guard let self = self else { return }
            if status == 200, let dict = json as? NSDictionary {
                getTabBarVc()?.updateUnreadCount(dict.getIntValue(key: "unread_message"))
            }
        }
    }
}

// MARK: - Notificatoin Rediraction
extension AppDelegate {
    
    func redirectionFromPush(_ noti: PushNotification)  {
        self.tabScreenLoaded = { () -> () in
            self.tabScreenLoaded = nil
            self.navigateUserForPush(noti)
        }
    }
    
    func navigateUserForPush(_ noti: PushNotification)  {
        if let tab = self.getTabBarVc() {
            tab.navigationController?.popToViewController(ofClass: NTabBarVC.self)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                switch noti.type.screenType {
                case .chat_list:
                    tab.setSelectedIndex(1)
//                    if let navVC = tab.viewControllers?[1] as? ChatHistoryVC {
//                        if let nav = navVC.navigationController as? KPNavigationViewController {
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
//                                let vc = ChatVC.instantiate(from: .Chat)
//                                vc.chatHistory = ChatHistory(noti)
//                                nav.pushViewController(vc, animated: true)
//                            })
//                        }
//                    }
                    
                case .support_list:
                    tab.setSelectedIndex(2)
                    if let navVC = tab.viewControllers?[2] as? ProfileVC {
                        if let nav = navVC.navigationController as? KPNavigationViewController {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                                let vc = SupportTicketListVC.instantiate(from: .Profile)
                                nav.pushViewController(vc, animated: true)
                            })
                        }
                    }
                    
                case .id_verification:
                    tab.setSelectedIndex(2)
                    if let navVC = tab.viewControllers?[2] as? ProfileVC {
                        if let nav = navVC.navigationController as? KPNavigationViewController {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                                let vc = IdVerificationVC.instantiate(from: .Profile)
                                nav.pushViewController(vc, animated: true)
                            })
                        }
                    }
                    
                case .car_detail:
                    if let navVC = tab.viewControllers?[2] as? ProfileVC {
                        tab.setSelectedIndex(2)
                        if let nav = navVC.navigationController as? KPNavigationViewController {
                            nav.popToViewController(ofClass: ProfileVC.self)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                                let vc = CarListVC.instantiate(from: .Profile)
                                vc.redirect_car_id = noti.id
                                nav.pushViewController(vc, animated: true)
                            })
                        }
                    }
                    
                case .ride_create_details:
                    tab.setSelectedIndex(2)
                    if let navVC = tab.viewControllers?[2] as? ProfileVC {
                        if let nav = navVC.navigationController as? KPNavigationViewController {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                                let vc = RideHistoryVC.instantiate(from: .Profile)
                                vc.scrennType = noti.type.isPastRideDetails ? .history : .created
                                vc.selectedTab = 0
                                vc.redirect_ride_id = noti.id
                                nav.pushViewController(vc, animated: true)
                            })
                        }
                    }
                    
                case .ride_book_details:
                    tab.setSelectedIndex(2)
                    if let navVC = tab.viewControllers?[2] as? ProfileVC {
                        if let nav = navVC.navigationController as? KPNavigationViewController {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                                let vc = RideHistoryVC.instantiate(from: .Profile)
                                vc.scrennType = noti.type.isPastRideDetails ? .history : .booked
                                vc.selectedTab = noti.type.isPastRideDetails ? 1 : 0
                                vc.redirect_ride_id = noti.id
                                nav.pushViewController(vc, animated: true)
                            })
                        }
                    }
                    
                case .ride_history_list:
                    tab.setSelectedIndex(2)
                    if let navVC = tab.viewControllers?[2] as? ProfileVC {
                        if let nav = navVC.navigationController as? KPNavigationViewController {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                                let vc = RideHistoryVC.instantiate(from: .Profile)
                                vc.scrennType = .history
                                vc.selectedTab = 1
                                nav.pushViewController(vc, animated: true)
                            })
                        }
                    }
                    
                case .request_carpool:
                    tab.setSelectedIndex(2)
                    if let navVC = tab.viewControllers?[2] as? ProfileVC {
                        if let nav = navVC.navigationController as? KPNavigationViewController {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                                let vc = RideHistoryVC.instantiate(from: .Profile)
                                vc.scrennType = .requests
                                nav.pushViewController(vc, animated: true)
                            })
                        }
                    }
                    
                case .card_list:
                    tab.setSelectedIndex(2)
                    if let navVC = tab.viewControllers?[2] as? ProfileVC {
                        if let nav = navVC.navigationController as? KPNavigationViewController {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                                let vc = CardListVC.instantiate(from: .Profile)
                                vc.screenType = .list
                                nav.pushViewController(vc, animated: true)
                            })
                        }
                    }
                    
                case .invitation_list:
                    tab.setSelectedIndex(2)
                    if let navVC = tab.viewControllers?[2] as? ProfileVC {
                        if let nav = navVC.navigationController as? KPNavigationViewController {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                                let vc = RideHistoryVC.instantiate(from: .Profile)
                                vc.scrennType = .requests
                                vc.selectedTab = 1
                                vc.redirect_request_id = noti.id
                                nav.pushViewController(vc, animated: true)
                            })
                        }
                    }
                    
                case .bank_details:
                    tab.setSelectedIndex(2)
                    if let navVC = tab.viewControllers?[2] as? ProfileVC {
                        if let nav = navVC.navigationController as? KPNavigationViewController {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                                let vc = BankDetailsVC.instantiate(from: .Profile)
                                nav.pushViewController(vc, animated: true)
                            })
                        }
                    }
                    
                case .none:
                    tab.setSelectedIndex(0)
                    if let navVC = tab.viewControllers?[0] as? HomeVC {
                        if let nav = navVC.navigationController as? KPNavigationViewController {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                                let vc = NotificationListVC.instantiate(from: .Home)
                                nav.pushViewController(vc, animated: true)
                            })
                        }
                    }
                }
            })
        }
    }
    
    func getTabBarVc() -> NTabBarVC? {
        var tabBar: NTabBarVC? = nil
        let nav = _appDelegator.window?.rootViewController as! KPNavigationViewController
        for vc in nav.viewControllers {
            if let tab = vc as? NTabBarVC {
                if tab.isViewLoaded {
                    tabBar = tab
                }
                break
            }
        }
        return tabBar
    }
    
    func getNavVC()-> KPNavigationViewController? {
        return _appDelegator.window?.rootViewController as? KPNavigationViewController
    }
}
