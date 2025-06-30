import UIKit
import Foundation
import AdSupport

let _appName        = "Eco Carpool"
let _appShortName   = "Eco Carpool"

let _app_store_ID: String = { "123456789" }()
let _app_iTunes_URL: String =  {"https://apps.apple.com/us/app/CabO/id\(_app_store_ID)"}()
let _app_android_URL: String =  {"https://play.google.com/store/apps/details?id=com.app.ecp"}()

let googleKey = Setting.googleMapKey

/// If google key is empty than location fetch via goecode.
var isGooleKeyFound : Bool = {
    return !googleKey.isEmpty
}()

let _userPlaceImage = UIImage(named: "user_place")?.withTintColor(AppColor.primaryText)
let _carPlaceImage = UIImage(named: "ic_car_place")?.withTintColor(AppColor.primaryText)
let _dummyPlaceImage = UIImage(named: "ic_img_place")?.withTintColor(AppColor.primaryText)
var _isLandScape: Bool {
    return UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight
}

// MARK: - Setting
struct Setting {
    
    static let configKey: String = "9g[$ax6JSyc-RTPdFf|[FPP3WnTBr9K+-pbB]zH#"
    
    static let googleMapKey = "AIzaSyAGExQ6227uAgYqj4-6KGsdKy3FwT9-wq0"
    
    static let google_signin_key: String = "240035296569-1m74r055d44okbo10tl9c00cnuk4kh04.apps.googleusercontent.com"
    
    static var UDID : String {
        get {
            return UIDevice.current.identifierForVendor!.uuidString
        }
    }
    
    static var imageBaseUrl: String = {
        if let dict = _userDefault.value(forKey: "_baseUrlKey") as? NSDictionary {
            return dict.getStringValue(key: "media")
        }
        return ""
    }()
    
    static let platform         = "IOS"
    static let countryCode      = "+91"
    static let appStoreId       = ""
    static let appStoreUrl      = "https://apps.apple.com/app/id\(Setting.appStoreId)"
    static let websiteUrl       = ""
    static let supportEmail     = ""
    
    // Firebase Dynamic link
    static let deepLinkScheme = ""
    
    // Paymet Url
    static let paymentCompletionUrl = URL(string: "")
    
    static var selectedLanguage = Bundle.selectedLanguage()
    
    static let otpTimeSec: Int = 60
    
    static var deviceToken:String! = "123456789" // set default value of token.
    static var fcmToken : String = ""
    
    static var deviceInfo: [String: Any] {
        var param: [String: Any] = [:]
        param["uu_id"] = Setting.UDID
        param["device_type"] = platform
        param["device_model"] = "\(UIDevice.current.name) - \(UIDevice.current.systemVersion)"
        param["device_token"] = deviceToken
        return param
    }
    
    static var deviceAppInfo: [String: Any] {
        var param: [String: Any] = [:]
        param["device_name"] = UIDevice.current.name
        param["device_os"] = UIDevice.current.systemVersion
        param["app_version"] = Bundle.main.infoDictionary?["CFBundleShortVersionString"]
        return param
    }
}

/*---------------------------------------------------
 Date Formatter and number formatter
 ---------------------------------------------------*/
let _serverFormatter: DateFormatter = {
    let df = DateFormatter()
    df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    df.timeZone = TimeZone(secondsFromGMT: 0)
    df.locale = Locale(identifier: "en_US_POSIX")
    return df
}()

let _dateFormatter: DateFormatter = {
    let df = DateFormatter()
    df.timeZone = TimeZone(abbreviation: "UTC")
    df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
    return df
}()

let _deviceFormatter: DateFormatter = {
    let df = DateFormatter()
    df.timeZone = TimeZone.current
//    df.locale = Locale(identifier: "en_US_POSIX")
//    df.locale = Locale(identifier: Config.selectedLanguage.localIdent)
    df.dateFormat = "MM-dd-yyyy"
    return df
}()

let _currencyFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
//    formatter.locale = Locale.current
//    formatter.locale = Locale(identifier: Config.selectedLanguage.localIdent)
    formatter.numberStyle = .currency
    formatter.maximumFractionDigits = 2
    formatter.minimumFractionDigits = 2
    return formatter
}()


/*---------------------------------------------------
Screen Size
---------------------------------------------------*/
let _screenFrame    = UIScreen.main.bounds
let _screenSize     = _screenFrame.size

/*---------------------------------------------------
 Constants
 ---------------------------------------------------*/
let _defaultCenter  = NotificationCenter.default
let _userDefault    = UserDefaults.standard
let _appDelegator   = UIApplication.shared.delegate! as! AppDelegate
let _application    = UIApplication.shared

/*---------------------------------------------------
 Facebook
 ---------------------------------------------------*/
let _facebookPermission              = ["public_profile", "email"]
let _facebookMeUrl                   = "me"
let _facebookAlbumUrl                = "me/albums"
let _facebookUserField: [String:Any] = ["fields" : "id,first_name,last_name,email,picture.height(700)"]
let _facebookJobSchoolField          = ["fields" : "education,work"]
let _facebookAlbumField              = ["fields":"id,name,count,picture"]
let _facebookPhotoField              = ["fields":"id,picture"]

/*---------------------------------------------------
 MARK: Paging Structure
 ---------------------------------------------------*/
class LoadMore: NSObject {
    
    override var description: String {
        return "\nIndex: \(index)\nIsLoading: \(isLoading)\nLimit: \(limit)\nIsAllLoad: \(isAllLoaded)\nOffset: \(offset)"
    }
    
    var index: Int = 0
    var isLoading: Bool = false
    var limit: Int
    var isAllLoaded = false
    var isFirstTime: Bool = false
    var lastTime: String?
    
    init(lmt: Int = 10) {
        limit = lmt
        super.init()
    }
    
    var offset: Int {
        return index * limit
    }
    
    var allLoadedORLoading: Bool {
        return !isAllLoaded && !isLoading
    }
    var canFetch: Bool {
        return !isAllLoaded && !isLoading && isFirstTime
    }
}

struct LoadMorePage {
    var page: Int = 1
    var isLoading: Bool = false
    var isAllLoaded = false
}

/*---------------------------------------------------
 Current loggedIn User
 ---------------------------------------------------*/
var _user: User?

var appTheme : UIUserInterfaceStyle {
    if let darkMode = _userDefault.value(forKey: _CabOAppTheme) as? Int {
        if let theme = AppThemeType(rawValue: darkMode) {
            if theme == .system {
                return UITraitCollection.current.userInterfaceStyle
            } else {
                return theme.appTheme
            }
        } else {
            return UITraitCollection.current.userInterfaceStyle
        }
    } else {
        return UITraitCollection.current.userInterfaceStyle
    }
}

/*---------------------------------------------------
 Place Holder image
 ---------------------------------------------------*/
let kActivityButtonImageName = ""
let kActivitySmallImageName = "ic_splash"

/*---------------------------------------------------
 User Default and Notification keys
 ---------------------------------------------------*/
let _languagePref = "appPreferenceKay"
let _baseUrlKey = "appBaseURLKey"
let _userAuthToken = "AppUserAuthToken"
let _CabOAppTheme = "CabOAppTheme"
let _CabOConfig = "CabOConfig"
let _locationSearchHistory = "locationSearchHistory"

extension Notification.Name {
    static let loginStatusChange = Notification.Name("LoginStatusChangedNotification")
    static let userProfileUpdate = Notification.Name("UserProfileUpdate")
    static let rideListUpdate = Notification.Name("RideListUpdate")
    static let rideDetailsUpdate = Notification.Name("RideDetailsUpdate")
    static let carListUpdate = Notification.Name("CarListUpdate")
    static let carDetailsUpdate = Notification.Name("CarDetailsUpdate")
    static let cardListUpdate = Notification.Name("CardListUpdate")
    static let supportTicketListUpdate = Notification.Name("SupportTicketListUpdate")
    static let themeUpdateNotification = Notification.Name("UpdateThemeNotification")
    static let requestListUpdate = Notification.Name("RequestListUpdate")
    static let requestDetailsUpdate = Notification.Name("RequestDetailsUpdate")
    
    static let chatUpdate = Notification.Name("ChatUpdate")
}

/*---------------------------------------------------
 Custom print
 ---------------------------------------------------*/
func nprint(items: Any...) {
    #if DEBUG
        for item in items {
            print(item)
        }
    #endif
}

// MARK: - Settings Version Maintenance
func getAppVersionAndBuild() -> String {
    if let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String,
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
//        #if DEBUG
        return "Version - \(version) (\(build))"
//        #else
//        return "Version - \(version)"
//        #endif
    } else {
        return ""
    }
}

func getAppBuildVersionString() -> String {
    if let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String,
       let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
        return "\(version).\(build)"
    } else {
        return ""
    }
}

func getAppversion() -> String {
    Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
}

func setAppSettingsBundleInformation() {
    if let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String,
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
        _userDefault.set(build, forKey: "application_build")
        _userDefault.set(version, forKey: "application_version")
        _userDefault.synchronize()
    }
}

/*---------------------------------------------------
 Device Extention
 ---------------------------------------------------*/
extension UIDevice {
    var hasNotch: Bool {
        if #available(iOS 11.0, *) {
            let bottom = UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0
            return bottom > 0
        } else {
            return false
        }
    }
}

// MARK: - Constant
//-------------------------------------------------------------------------------------------
// Common
//-------------------------------------------------------------------------------------------
var _statusBarHeight: CGFloat = {
    if #available(iOS 11.0, *) {
        if UIDevice.current.hasNotch {
            return _appDelegator.window!.safeAreaInsets.top
        } else {
            return 20
        }
    } else {
        return 20
    }
}()

var _bottomBarHeight: CGFloat = {
    if #available(iOS 11.0, *) {
        if UIDevice.current.hasNotch {
            return _appDelegator.window!.safeAreaInsets.bottom
        } else {
            return 0
        }
    } else {
        return 0
    }
}()


let _navigationHeight          : CGFloat = _statusBarHeight + (60 * _widthRatio)
let _btmNavigationHeight       : CGFloat = _bottomAreaSpacing + 64
let _btmNavigationHeightSearch : CGFloat = _bottomAreaSpacing + 64 + 45
let _bottomAreaSpacing         : CGFloat = _bottomBarHeight
let _topAreaSpacing            : CGFloat = _statusBarHeight
let _vcTransitionTime                    = 0.3
let _imageFadeTransitionTime   : Double  = 0.3
let _maxImageSize              : CGSize  = CGSize(width: 1000, height: 1000)
let _minImageSize              : CGSize  = CGSize(width: 800, height: 800)
