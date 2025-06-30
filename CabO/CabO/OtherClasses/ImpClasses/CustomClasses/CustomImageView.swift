import Foundation
import UIKit

//MARK: - Custom Image View
/// This class will create tint enabled image view (source image's rendering mode will be set to alwaysTemplate) with round image view capabilities
class TintImageView: UIImageView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.tintAdjustmentMode = .normal
        if let image {
            self.image = image.withRenderingMode(.alwaysTemplate)
        }
    }
}

//MARK: - Custom Image View
/// This class will create tint enabled image view (source image's rendering mode will be set to alwaysTemplate) with round image view capabilities
class RoundTintImageView: NRoundImageView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.tintAdjustmentMode = .normal
        if let image {
            self.image = image.withRenderingMode(.alwaysTemplate)
        }
    }
}

/// This is custom class for ropunded image views
class NRoundImageView: UIImageView {
    
    @IBInspectable var isRatioAppliedOnSize: Bool = false
    
    @IBInspectable var cornerRadious: CGFloat = 0 {
        didSet{
            if cornerRadious == 0 {
                layer.cornerRadius = isRatioAppliedOnSize ? (self.frame.height * _widthRatio) / 2 : self.frame.height / 2
            }else{
                layer.cornerRadius = isRatioAppliedOnSize ? cornerRadious * _widthRatio : cornerRadious
            }
        }
    }
    
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
            layer.cornerRadius = isRatioAppliedOnSize ? (self.frame.height * _widthRatio) / 2 : self.frame.height / 2
        }else{
            layer.cornerRadius = isRatioAppliedOnSize ? cornerRadious * _widthRatio : cornerRadious
        }
    }
    
    func updateBorders() {
        layer.borderColor = borderColor.cgColor
        layer.borderWidth = borderWidth
    }
}


/// This class will create label as placeholder in imageview
class NLblPlaceImageView: NRoundImageView {
    
    var layerLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layerLbl = UILabel()
        layerLbl.textAlignment = .center
        layerLbl.textColor = .white
        layerLbl.font = AppFont.fontWithName(.mediumFont, size: 17 * _fontRatio)
        layerLbl.backgroundColor = AppColor.themePrimary.withAlphaComponent(0.8)
        self.addSubview(layerLbl)
        layerLbl.addConstraintToSuperView(lead: 0, trail: 0, top: 0, bottom: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let ft = layerLbl.font {
            let newFtSize = (self.frame.height * (ft.pointSize)) / 40
            if ft.pointSize != newFtSize {
                layerLbl.font = AppFont.fontWithName(.mediumFont, size: newFtSize)
            }
        }
    }
    
    func setImage(url: URL?, firstLetter: Character?, place: UIImage?) {
        if let imgUrl = url {
            layerLbl.isHidden = true
            loadFromUrlString(imgUrl, placeholder: place)
        } else if let fCh = firstLetter {
            image = nil
            layerLbl.isHidden = false
            layerLbl.text = String(fCh).uppercased()
        } else {
            image = nil
            layerLbl.isHidden = true
        }
    }
}

