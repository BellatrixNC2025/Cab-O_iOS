import Foundation
import UIKit

//MARK: - Custom Buttons

/// This class will update the constant based on the screensize
extension UIButton {
    
    @IBInspectable public var FontType: Int {
        get {
            return 0
        }
        set{
            let afont = self.titleLabel?.font!
            if newValue == 0 {
                self.titleLabel?.font! = AppFont.fontWithName(.regular, size: afont!.pointSize * _fontRatio)
            }  else if newValue == 1 {
                self.titleLabel?.font! = AppFont.fontWithName(.mediumFont, size: afont!.pointSize * _fontRatio)
            } else {
                self.titleLabel?.font! = AppFont.fontWithName(.bold, size: afont!.pointSize * _fontRatio)
            }
        }
    }
    
    open override func awakeFromNib() {
        super.awakeFromNib()
        if let img = self.image(for: .normal) {
            self.setImage(img.scaleImage(toSize: img.size * _widthRatio)?.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        if let selImg = self.image(for: .selected) {
            self.setImage(selImg.scaleImage(toSize: selImg.size * _widthRatio)?.withRenderingMode(.alwaysOriginal), for: .selected)
        }
    }
}

/// This class will autmatically increase the size of button title based on screen size
class NResizeButton: UIButton {
    
    @IBInspectable var isRationAppliedOnText: Bool = true {
        didSet{
            if isRationAppliedOnText, let afont = titleLabel?.font {
                titleLabel?.font = afont.withSize(afont.pointSize * _fontRatio)
            }
        }
    }
}
/// This is custom class for rounded buttons
class NRoundButtonWithoutTint: NResizeButton {
    
    @IBInspectable var isRatioAppliedOnSize: Bool = false
    
    @IBInspectable var cornerRadious: CGFloat = 0{
        didSet{
            if cornerRadious == 0{
                layer.cornerRadius = self.frame.height / 2
            }else{
                layer.cornerRadius = cornerRadious * _widthRatio
            }
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.clear{
        didSet{
            layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
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

/// This class will create tint enabled image button (source image's rendering mode will be set to alwaysTemplate)
class TintButton: NResizeButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.tintAdjustmentMode = .normal
        if let img = image(for: UIControl.State.normal) {
            self.setImage(img.withRenderingMode(.alwaysTemplate), for: .normal)
        }
        if let img = image(for: UIControl.State.selected) {
            self.setImage(img.withRenderingMode(.alwaysTemplate), for: .selected)
        }
        if let img = image(for: UIControl.State.disabled) {
            self.setImage(img.withRenderingMode(.alwaysTemplate), for: .disabled)
        }
    }
}

/// This is custom class for rounded buttons
class NRoundButton: TintButton {
    
    @IBInspectable var isRatioAppliedOnSize: Bool = false
    
    @IBInspectable var cornerRadious: CGFloat = 0{
        didSet{
            if cornerRadious == 0{
                layer.cornerRadius = self.frame.height / 2
            }else{
                layer.cornerRadius = cornerRadious * _widthRatio
            }
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.clear{
        didSet{
            layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
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

/// This is custom rounded view with shadow
class NRoundShadowButton: NRoundButton {
    
    @IBInspectable var xPos: CGFloat = 0
    @IBInspectable var yPos: CGFloat = 0
    @IBInspectable var radious: CGFloat = 0
    @IBInspectable var opacity: CGFloat = 0
    @IBInspectable var widthReduce: CGFloat = 0
    @IBInspectable var color: UIColor = UIColor.black
    
    override func awakeFromNib() {
        super.awakeFromNib()
        clipsToBounds = true
        layer.masksToBounds = false
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = Float(opacity)
        layer.shadowOffset = CGSize(width: xPos, height: yPos)
        layer.shadowRadius = radious
//        changeFrame()
    }
    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        changeFrame()
//    }
//
//    func changeFrame() {
//        let shadowRect = CGRect(origin: CGPoint.zero, size: CGSize(width: self.frame.width, height: self.frame.height))
//        let corRad = self.cornerRadious == 0 ? self.frame.height / 2 : self.cornerRadious
//        let path = UIBezierPath(roundedRect: shadowRect, byRoundingCorners: [.allCorners], cornerRadii: CGSize(width: corRad, height: corRad))
//        layer.cornerRadius = cornerRadious
//        layer.shadowPath = path.cgPath
//    }
}

/// This class will create custom button with gradient
@IBDesignable class NGradientButton: NRoundButton {
    
    @IBInspectable var widthToReduce: CGFloat = 0
    @IBInspectable var isPrimary: Bool = false
    
    @IBInspectable var primaryColor: UIColor = AppColor.themePrimary
    @IBInspectable var secondaryColor: UIColor = AppColor.themePrimary
    
    override var isEnabled: Bool {
        didSet {
            addGradient()
        }
    }
    
    var colours: [UIColor] {
        if isEnabled {
            if isPrimary {
                return [primaryColor, secondaryColor]
            } else {
                return [primaryColor, secondaryColor]
            }
        } else {
            return [AppColor.themePrimary, AppColor.themePrimary]
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addGradient()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        addGradient()
    }
    
    /// This method will add gradient layer
    func addGradient() {
        let gradient: CAGradientLayer
        if let grad = self.layer.sublayers?.first as? CAGradientLayer {
            gradient = grad
            gradient.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
            gradient.colors = colours.map { $0.cgColor }
        } else {
            gradient = CAGradientLayer()
            gradient.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
            gradient.colors = colours.map { $0.cgColor }
            gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
            gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
            gradient.opacity = 1
            self.layer.insertSublayer(gradient, at: 0)
        }
    }
}

/// This call will create state less button with Gradient
class NGradientButtonNoState: NResizeButton {
    
    var colours: [UIColor] {
        return [AppColor.themePrimary, AppColor.themePrimary]
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addGradient()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        addGradient()
    }
    
    func addGradient() {
        let gradient: CAGradientLayer
        if let grad = self.layer.sublayers?.first as? CAGradientLayer {
            gradient = grad
            gradient.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
            gradient.colors = colours.map { $0.cgColor }
        } else {
            gradient = CAGradientLayer()
            gradient.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
            gradient.colors = colours.map { $0.cgColor }
            gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
            gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
            gradient.opacity = 1
            self.layer.insertSublayer(gradient, at: 0)
        }
    }
}

/// This class will create button with Gradient borders
class NGradientBorderButton: NResizeButton {
    
    override var isSelected: Bool {
        didSet {
            addGradient()
        }
    }
    
    var borderColor: [UIColor] {
        if isSelected {
            //            return [UIColor.hexStringToUIColor(hexStr: "189EE1"), UIColor.hexStringToUIColor(hexStr: "84339C")]
            return [AppColor.themePrimary, AppColor.themePrimary]
        } else {
            return [AppColor.themePrimary, AppColor.themePrimary]
        }
    }
    
    var colours: [UIColor] {
        if isSelected {
            //            return [UIColor.hexStringToUIColor(hexStr: "189EE1"), UIColor.hexStringToUIColor(hexStr: "84339C")]
            return [AppColor.themePrimary, AppColor.themePrimary]
        } else {
            return [UIColor.white, UIColor.white]
        }
    }
    
    var borderGrad: CAGradientLayer!
    var bgGrad: CAGradientLayer!
    var maskLayer: CAShapeLayer!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = 4
        self.layer.masksToBounds = true
        addGradient()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        addGradient()
    }
    
    func addGradient() {
        if borderGrad != nil {
            borderGrad.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
            borderGrad.colors = borderColor.map { $0.cgColor }
            bgGrad.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
            bgGrad.colors = colours.map { $0.cgColor }
            maskLayer.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height), cornerRadius: 4).cgPath
        } else {
            borderGrad = CAGradientLayer()
            borderGrad.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
            borderGrad.colors = borderColor.map { $0.cgColor }
            borderGrad.startPoint = CGPoint(x: 0.0, y: 1.0)
            borderGrad.endPoint = CGPoint(x: 1.0, y: 1.0)
            
            bgGrad = CAGradientLayer()
            bgGrad.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
            bgGrad.colors = colours.map { $0.cgColor }
            bgGrad.startPoint = CGPoint(x: 0.0, y: 1.0)
            bgGrad.endPoint = CGPoint(x: 1.0, y: 1.0)
            bgGrad.opacity = 0.08
            
            maskLayer = CAShapeLayer()
            maskLayer.lineWidth = 2
            maskLayer.path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height), cornerRadius: 4).cgPath
            maskLayer.strokeColor = UIColor.black.cgColor
            maskLayer.fillColor = UIColor.clear.cgColor
            borderGrad.mask = maskLayer
            self.layer.insertSublayer(borderGrad, at: 0)
            self.layer.insertSublayer(bgGrad, at: 0)
        }
    }
}

class GradientButton: NResizeButton {
    
    @IBInspectable var startcolor: UIColor = AppColor.themeGreen {
        didSet {
            addGradient()
        }
    }
    
    @IBInspectable var endColor: UIColor = AppColor.themeGreen {
        didSet {
            addGradient()
        }
    }
    
    // 0 = Cross (left to right), 1 = Vertical, 2 = Horizontal
    @IBInspectable var type: Int = 0 {
        didSet {
            addGradient()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        addGradient()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        addGradient()
    }
    
    func addGradient() {
        let gradient: CAGradientLayer
        if let grad = self.layer.sublayers?.first as? CAGradientLayer {
            gradient = grad
        } else {
            gradient = CAGradientLayer()
            gradient.opacity = 1
            self.layer.insertSublayer(gradient, at: 0)
        }
        gradient.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
        gradient.colors = [startcolor, endColor].map { $0.cgColor }
        if type == 0 {
            gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
            gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        } else if type == 1 {
            gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
            gradient.endPoint = CGPoint(x: 0.0, y: 1.0)
        } else {
            gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
            gradient.endPoint = CGPoint(x: 1.0, y: 0.0)
        }
    }
}

class RoundGradientButton: GradientButton {
    
    @IBInspectable var isRatioAppliedOnSize: Bool = false
    
    @IBInspectable var cornerRadious: CGFloat = 0{
        didSet{
            if cornerRadious == 0{
                layer.cornerRadius = self.frame.height / 2
            }else{
                layer.cornerRadius = cornerRadious * _widthRatio
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
    }
    
    func updateCornerRadius() {
        if cornerRadious == 0{
            layer.cornerRadius = self.frame.height / 2
        }else{
            layer.cornerRadius = cornerRadious * _widthRatio
        }
    }
}


//MARK: - Swipe button
protocol SlideToActionButtonDelegate: AnyObject {
    func didFinish()
}

class SlideToActionButton: UIView {
    
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .soft)
    
    @IBInspectable var handleBgColor: UIColor = UIColor.white {
        didSet {
            handleView.backgroundColor = handleBgColor
        }
    }
    
    @IBInspectable var handleImage: UIImage = UIImage(systemName: "chevron.right.2")! {
        didSet {
            handleViewImage.image = handleImage
        }
    }
    
    @IBInspectable var handleImageTint: UIColor = UIColor.white {
        didSet {
            handleViewImage.tintColor = handleImageTint
            handleViewImage.image = handleViewImage.image?.withTintColor(handleImageTint)
        }
    }
    
    @IBInspectable var viewBgColor: UIColor = UIColor.white
    
    @IBInspectable var title: String = "" {
        didSet {
            titleLabel.text = title
        }
    }
    
    @IBInspectable var labelTitleColor: UIColor = UIColor.white {
        didSet {
            titleLabel.textColor = labelTitleColor
        }
    }
    
    @IBInspectable var draggedBgColor: UIColor = UIColor.white {
        didSet {
            draggedView.backgroundColor = draggedBgColor
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            if cornerRadius == 0 {
                draggedView.layer.cornerRadius = draggedView.frame.height / 2
                handleView.layer.cornerRadius = handleView.frame.height / 2
                self.layer.cornerRadius = self.frame.height / 2
            } else {
                draggedView.layer.cornerRadius = cornerRadius * _widthRatio
                handleView.layer.cornerRadius = cornerRadius * _widthRatio
                self.layer.cornerRadius = cornerRadius * _widthRatio
            }
        }
    }
    
    
    let handleView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 12 * _widthRatio
        view.layer.masksToBounds = true
        return view
    }()
    
    let handleViewImage: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.image = UIImage(systemName: "chevron.right.2", withConfiguration: UIImage.SymbolConfiguration(font: .systemFont(ofSize: 40, weight: .bold)))?.withRenderingMode(.alwaysTemplate)
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    let draggedView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 12 * _widthRatio
        return view
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = AppFont.fontWithName(.mediumFont, size: 16 * _fontRatio)
        label.text = "Slide me!"
        return label
    }()
    
    private var leadingThumbnailViewConstraint: NSLayoutConstraint?
    private var panGestureRecognizer: UIPanGestureRecognizer!

    weak var delegate: SlideToActionButtonDelegate?
    
    private var xEndingPoint: CGFloat {
        return (bounds.width - handleView.bounds.width)
    }
    
    private var isFinished = false
    
    init() {
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateCornerRadius()
    }
    
    private func updateCornerRadius() {
        if cornerRadius == 0 {
            draggedView.layer.cornerRadius = draggedView.frame.height / 2
            handleView.layer.cornerRadius = handleView.frame.height / 2
            self.layer.cornerRadius = self.frame.height / 2
        } else {
            draggedView.layer.cornerRadius = cornerRadius * _widthRatio
            handleView.layer.cornerRadius = cornerRadius * _widthRatio
            self.layer.cornerRadius = cornerRadius * _widthRatio
        }
    }
    
    func setup() {
        backgroundColor = self.backgroundColor
        layer.cornerRadius = 12 * _widthRatio
        addSubview(titleLabel)
        addSubview(draggedView)
        addSubview(handleView)
        handleView.addSubview(handleViewImage)
        
        //MARK: - Constraints
        
        leadingThumbnailViewConstraint = handleView.leadingAnchor.constraint(equalTo: leadingAnchor)
        
        NSLayoutConstraint.activate([
            leadingThumbnailViewConstraint!,
            handleView.topAnchor.constraint(equalTo: topAnchor),
            handleView.bottomAnchor.constraint(equalTo: bottomAnchor),
            handleView.widthAnchor.constraint(equalToConstant: 64 * _widthRatio),
            draggedView.topAnchor.constraint(equalTo: topAnchor),
            draggedView.bottomAnchor.constraint(equalTo: bottomAnchor),
            draggedView.leadingAnchor.constraint(equalTo: leadingAnchor),
            draggedView.trailingAnchor.constraint(equalTo: handleView.trailingAnchor),
            handleViewImage.topAnchor.constraint(equalTo: handleView.topAnchor, constant: 10),
            handleViewImage.bottomAnchor.constraint(equalTo: handleView.bottomAnchor, constant: -10),
            handleViewImage.centerXAnchor.constraint(equalTo: handleView.centerXAnchor),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 24 * _widthRatio),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.handlePanGesture(_:)))
        panGestureRecognizer.minimumNumberOfTouches = 1
        handleView.addGestureRecognizer(panGestureRecognizer)
    }
    
    @objc private func handlePanGesture(_ sender: UIPanGestureRecognizer) {
        if isFinished { return }
        let translatedPoint = sender.translation(in: self).x

        switch sender.state {
        case .changed:
            if translatedPoint <= 0 {
                updateHandleXPosition(0)
            } else if translatedPoint >= xEndingPoint {
                updateHandleXPosition(xEndingPoint)
            } else {
                updateHandleXPosition(translatedPoint)
            }
            
            let vibrationIntensity = CGFloat(translatedPoint / xEndingPoint) + 0.33
            feedbackGenerator.prepare()
            feedbackGenerator.impactOccurred(intensity: vibrationIntensity)
            
//            feedbackGenerator.impactOccurred()
            
        case .ended:
            if translatedPoint >= xEndingPoint {
                self.updateHandleXPosition(xEndingPoint)
                isFinished = true
                delegate?.didFinish()
            } else {
                UIView.animate(withDuration: 1) {
                    self.reset()
                }
            }
        default:
            break
        }
    }
    
    private func updateHandleXPosition(_ x: CGFloat) {
        UIView.animate(withDuration: 0.1) {
            self.leadingThumbnailViewConstraint?.constant = x
            self.layoutIfNeeded()
        }
    }

    func reset() {
        isFinished = false
        updateHandleXPosition(0)
    }
}

