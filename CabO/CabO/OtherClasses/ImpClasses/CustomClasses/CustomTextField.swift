import Foundation
import UIKit

//MARK: - Custom UITextField
class NResizeTextField: UITextField {
    
    @IBInspectable var isRationAppliedOnText: Bool = true {
        didSet{
            if isRationAppliedOnText {
                font = font?.withSize((font?.pointSize)! * _fontRatio)
            }
        }
    }
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
}

class NResizeTextView: UITextView {
    
    @IBInspectable var isRationAppliedOnText: Bool = true {
        didSet{
            if isRationAppliedOnText {
                font = font?.withSize((font?.pointSize)! * _fontRatio)
            }
        }
    }
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
}

/// This is custom class for rounded text fields
class NRoundTextField: NResizeTextField {
    
    @IBInspectable var isRatioAppliedOnSize: Bool = false
        
    @IBInspectable var borderColor: UIColor = UIColor.clear{
        didSet{
            layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0{
        didSet{
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var cornerRadious: CGFloat = 0{
        didSet{
            if cornerRadious == 0{
                layer.cornerRadius = self.frame.height / 2
            }else{
                layer.cornerRadius = cornerRadious * _widthRatio
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.masksToBounds = true
    }
}

/// This class will create SkyFloatingLabelTextField with our custom theme
class NTextFieldConfiguration: SkyFloatingLabelTextField {
    
    override var placeholder: String? {
        didSet {
            if (placeholder != nil) {
                title = placeholder
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        #warning("Customize TextField here")
        
        self.tintColor = AppColor.primaryText
        textColor = AppColor.primaryText
//        placeholderColor = AppColor.textSwatch_3
//        titleColor = AppColor.textSwatch_3
//        selectedTitleColor = AppColor.themeSecondaryDarkSwatch_1

        
        titleFont = AppFont.fontWithName(.mediumFont, size: 12 * _fontRatio)
        font = AppFont.fontWithName(.bold, size: 14 * _fontRatio)
        placeholderFont = AppFont.fontWithName(.mediumFont, size: 14 * _fontRatio)
        
        lineColor = .clear
        lineHeight = 0
        selectedLineColor = .clear
        selectedLineHeight = 0
        errorColor = .clear
    }
    
    //    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {}
    
    override func leftViewRect(forBounds bounds: CGRect) -> CGRect {
        if let lbl = self.leftView as? UILabel {
            if lbl.tag == 1010 {
                let point = CGPoint(x: 0, y: 17)
                let width = lbl.text!.WidthWithNoConstrainedHeight(font: lbl.font) + 5
                let size = CGSize(width: width, height: lbl.frame.height)
                return CGRect(origin: point, size: size)
            } else if leftViewMode == .always {
                let point = CGPoint(x: 0, y: 20)
                let width = lbl.text!.WidthWithNoConstrainedHeight(font: lbl.font) + 5
                let size = CGSize(width: width, height: lbl.frame.height)
                return CGRect(origin: point, size: size)
            }
        }
        return bounds
    }
}

