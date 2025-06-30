import Foundation
import UIKit

extension CGSize {

  /// Operator convenience to add sizes with +
  static func +(left: CGSize, right: CGSize) -> CGSize {
    left.add(right)
  }

  /// Operator convenience to subtract sizes with -
  static func -(left: CGSize, right: CGSize) -> CGSize {
    left.subtract(right)
  }

  /// Operator convenience to multiply sizes with *
  static func *(left: CGSize, right: CGFloat) -> CGSize {
    CGSize(width: left.width * right, height: left.height * right)
  }

  /// Returns the scale float that will fit the receive inside of the given size.
  func scaleThatFits(_ size: CGSize) -> CGFloat {
    CGFloat.minimum(width / size.width, height / size.height)
  }

  /// Adds receiver size to give size.
  func add(_ size: CGSize) -> CGSize {
    CGSize(width: width + size.width, height: height + size.height)
  }

  /// Subtracts given size from receiver size.
  func subtract(_ size: CGSize) -> CGSize {
    CGSize(width: width - size.width, height: height - size.height)
  }

  /// Multiplies receiver size by the given size.
  func multiply(_ size: CGSize) -> CGSize {
    CGSize(width: width * size.width, height: height * size.height)
  }
}

// MARK: - Double Conversion
extension Double {
    
    func formatPoints() ->String {
        let thousandNum = self/1000
        let millionNum = self/1000000
        if self >= 1000 && self < 1000000{
            if(floor(thousandNum) == thousandNum){
                return("\(Int(thousandNum))k")
            }
            return("\(thousandNum.rounded(toPlaces: 2))k")
        }
        if self > 1000000{
            if(floor(millionNum) == millionNum){
                return("\(Int(thousandNum))k")
            }
            return ("\(millionNum.rounded(toPlaces: 2))M")
        }
        else{
            if(floor(self) == self){
                return ("\(Int(self))")
            }
            return ("\(self)")
        }

    }
    
    func getFormattedValue(str: String = "2", ignoreZero: Bool = true) -> String {
        let local = Locale(identifier: Setting.selectedLanguage.localIdent)
        if ignoreZero {
            let value = floor(self)
            if (self - value) > 0 {
                return String(format: "%.\(str)f", locale: local, self)
            } else {
                return String(format: "%.\(0)f", locale: local, self)
            }
        } else {
            return String(format: "%.\(str)f", locale: local, self)
        }
    }
    
    func getFormattedValueEng(str: String = "2", ignoreZero: Bool = true) -> String {
        if ignoreZero {
            let value = floor(self)
            if (self - value) > 0 {
                return String(format: "%.\(str)f", self)
            } else {
                return String(format: "%.\(0)f", self)
            }
        } else {
            return String(format: "%.\(str)f", self)
        }
    }
    
    var intValue: Int? {
        let val = Int(self)
        return val
    }
}

// MARK: - Int Conversions
extension Int {
    func getFormattedValue() -> String {
        let local = Locale(identifier: Setting.selectedLanguage.localIdent)
        return String(format: "%d", locale: local, self)
    }
}


extension Int {
    var stringValue: String {
        return "\(self)"
    }
}

extension Int16 {
    func getFormattedValue() -> String {
        let local = Locale(identifier: Setting.selectedLanguage.localIdent)
        return String(format: "%d", locale: local, self)
    }
}

extension Int32 {
    func getFormattedValue() -> String {
        let local = Locale(identifier: Setting.selectedLanguage.localIdent)
        return String(format: "%d", locale: local, self)
    }
}

extension CGFloat {
    
    var intValue: Int? {
        let val = Int(self)
        return val
    }
    
    func getFormattedValue(str: String) -> String {
        let local = Locale.current
        return String(format: "%.\(str)f", locale: local, self)
    }
}

// MARK: - String Conversions
extension String {
    
    var doubleValue: Double? {
        return Double(self)
    }
    
    var floatValue: Float? {
        return Float(self)
    }
    
    var integerValue: Int? {
        return Int(self)
    }
}
