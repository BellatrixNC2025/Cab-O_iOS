import Foundation
import UIKit

/// This class will update the constant based on the screensize
class Resizable: NSLayoutConstraint {
    
    @IBInspectable var heightConst: CGFloat = 0 {
        didSet {
            if self.heightConst != 0 {
                self.constant = self.heightConst * _heightRatio
            }
        }
    }
    
    @IBInspectable var widthConst: CGFloat = 0 {
        didSet {
            if self.widthConst != 0 {
                self.constant = self.widthConst * _widthRatio
            }
        }
    }
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
}

final class EnumHelper {
        
    static func checkCases<T: Equatable>(_ variable: T, cases: [T]) -> Bool {
        return cases.contains(variable)
    }
}
