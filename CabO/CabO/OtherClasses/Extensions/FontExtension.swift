import UIKit

// MARK: - Font Extension
enum FontType: String {
    case bold = "Satoshi-Bold"
    case light = "Satoshi-Light"
    case regular = "Satoshi-Regular"
    case mediumFont = "Satoshi-Medium"
}

struct AppFont {
    
    static func fontWithName(_ name: FontType, size: CGFloat) -> UIFont {
        return UIFont(name: name.rawValue, size: size * _fontRatio)!
    }
}
