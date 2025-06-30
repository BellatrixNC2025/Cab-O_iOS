import UIKit

infix operator |: AdditionPrecedence

// MARK: - UIColor Extensions
extension UIColor {
    
    static func | (lightMode: UIColor, darkMode: UIColor) -> UIColor {
        guard #available(iOS 13.0, *) else { return lightMode }
        
        return UIColor { (traitCollection) -> UIColor in
            return appTheme == .light ? lightMode : darkMode
        }
    }
    
    class func colorWithGray(gray: Int) -> UIColor {
      return UIColor(red: CGFloat(gray) / 255.0, green: CGFloat(gray) / 255.0, blue: CGFloat(gray) / 255.0, alpha: 1.0)
    }
    
    class func colorWithRGB(r: Int, g: Int, b: Int) -> UIColor {
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: 1.0)
    }

    class func colorWithHexa(hex:Int) -> UIColor{
        let components = (
            R: CGFloat((hex >> 16) & 0xff) / 255,
            G: CGFloat((hex >> 08) & 0xff) / 255,
            B: CGFloat((hex >> 00) & 0xff) / 255
        )
        return UIColor(red: components.R, green: components.G, blue: components.B, alpha: 1.0)
    }
    
    @objc class func colourWith(red: Int, green: Int, blue: Int, alpha: CGFloat) -> UIColor {
        return UIColor(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: alpha)
    }
        
    class func hexStringToUIColor (hexStr: String) -> UIColor {
        var cString:String = hexStr.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
    
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor (
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    static func getColorFormName(_ name: String) -> UIColor {
        return UIColor(named: name, in: Bundle.main, compatibleWith: nil)!
    }
    
    
}

// MARK: - AppColor
struct AppColor {
    static var successToastColor                : UIColor { return UIColor.hexStringToUIColor(hexStr: "#1CA959") }
    static var errorToastColor                  : UIColor { return UIColor.hexStringToUIColor(hexStr: "#F85252") }
    
    static var appBg                            : UIColor { return UIColor.getColorFormName("appBg") }
    static var headerBg                         : UIColor { return UIColor.getColorFormName("headerBG") }
    static var textfieldBgDark                  : UIColor { return UIColor.getColorFormName("textfieldBg_Dark") }
    static var textfieldBorder                  : UIColor { return UIColor.getColorFormName("textfield_border") }
    static var themePrimary                     : UIColor { return UIColor.getColorFormName("theme_primary") }
    static var primaryText                      : UIColor { return UIColor.getColorFormName("primaryText") }
    static var primaryTextDark                  : UIColor { return UIColor.getColorFormName("primaryText_Dark") }
    static var placeholderText                  : UIColor { return UIColor.getColorFormName("placeholderText") }
    static var themeGray                        : UIColor { return UIColor.getColorFormName("theme_gray") }
    static var themeGreen                       : UIColor { return UIColor.getColorFormName("theme_green") }
    static var themeBlue                        : UIColor { return UIColor.getColorFormName("theme_blue") }
    static var vwBgColor                        : UIColor {return UIColor.getColorFormName("vwBgColor")}
    static var roleBgGreen                        : UIColor {return UIColor.getColorFormName("roleBgGreen")}
    
}
