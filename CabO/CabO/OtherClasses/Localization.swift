import Foundation

/// This is Language enumeration
enum Language: String {
    case english = "en"
    
    var localIdent: String {
        switch self {
        case .english:
            return "en_US"
        }
    }
    
    var title: String {
        switch self {
        case .english:
            return "English"
        }
    }
}

private var kBundleKey: UInt8 = 0

class BundleEx: Bundle {

    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        if let bundle = objc_getAssociatedObject(self, &kBundleKey) as? Bundle {
            return bundle.localizedString(forKey: key, value: value, table: tableName)
        }
        return super.localizedString(forKey: key, value: value, table: tableName)
    }

}

extension Bundle {

    static let once: Void = {
        object_setClass(Bundle.main, type(of: BundleEx()))
    }()
    
    /// It will change selected language
    /// - Parameter language: Selected lanhuages rawValue
    class func setLanguage(_ language: String) {
        _userDefault.setValue(language, forKey: _languagePref)
        _userDefault.synchronize()
        Bundle.once
        var bundle: Bundle? = nil
        if let path = Bundle.main.path(forResource: language, ofType: "lproj"), let bund = Bundle.init(path: path) {
            bundle = bund
        }
        let lan = Language(rawValue: language)!
        Setting.selectedLanguage = lan
        _deviceFormatter.locale = Locale(identifier: lan.localIdent)
        objc_setAssociatedObject(Bundle.main, &kBundleKey, bundle, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    /// It will return currently selected language
    /// - Returns: Currently selected language
    class func selectedLanguage() -> Language {
        if let lan = _userDefault.value(forKey: _languagePref) as? String {
            return Language(rawValue: lan) ?? .english
        }
        return .english
    }
    
    class func prepareLanguageSelectionOnLoad() {
        Bundle.setLanguage(Setting.selectedLanguage.rawValue)
    }
}
