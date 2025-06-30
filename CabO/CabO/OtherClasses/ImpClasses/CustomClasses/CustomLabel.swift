import Foundation
import UIKit

/// This class will update the constant based on the screensize
extension UILabel {
    
    @IBInspectable public var FontType: Int {
        get {
            return 0
        }
        set{
            let afont = self.font!
            if newValue == 0 {
                self.font = AppFont.fontWithName(.regular, size: afont.pointSize * _fontRatio)
            } else if newValue == 1 {
                self.font = AppFont.fontWithName(.mediumFont, size: afont.pointSize * _fontRatio)
            } else {
                self.font = AppFont.fontWithName(.bold, size: afont.pointSize * _fontRatio)
            }
        }
    }
}

//MARK: - Custom Label
/// This class will automatically manage the font size for different devices
class NResizeLabel: UILabel {
    
    @IBInspectable var isRationAppliedOnText: Bool = true {
        didSet{
            if isRationAppliedOnText {
                font = font.withSize(font.pointSize * _fontRatio)
            }
        }
    }
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
}

///This is custom class for rounded labels
class NRoundLabel: NResizeLabel {
    
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
    
    @IBInspectable var letterSpace : CGFloat = 0 {
        didSet{
            letterSpace = letterSpace * _widthRatio
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.masksToBounds = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateCornerRadius()
        updateBorders()
    }
    
    func updateCornerRadius() {
        if cornerRadious == 0{
            layer.cornerRadius = self.frame.height / 2
        }else{
            layer.cornerRadius = cornerRadious * _widthRatio
        }
    }
    
    func updateBorders() {
        layer.borderColor = borderColor.cgColor
        layer.borderWidth = borderWidth
    }
}

/// This class will create label with given character space between label's value
class NCharSpaceLabel: NResizeLabel {
    
    @IBInspectable var letterSpace : CGFloat = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if let title = text{
            addCharactersSpacing(spacing: letterSpace, text: title)
        }
    }
}

/// This class will create Label with shadow
class NShadowLable: NResizeLabel {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowRadius = 1.0
        layer.shadowOpacity = 0.4
        layer.shadowOffset = CGSize(width: 0, height: 0)
        layer.masksToBounds = false
    }
}


