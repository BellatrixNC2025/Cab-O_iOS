import Foundation
import UIKit

//MARK: - Custom UIView
/// This is custom class for rounded views
class NRoundView: ConstrainedView {
    
    @IBInspectable var cornerRadious: CGFloat = 0 {
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

/// This is custom class for single sided rounded views
class NTopRoundCornerView: ConstrainedView {
    
    @IBInspectable var radious: CGFloat = 0
    @IBInspectable var bgColor: UIColor = UIColor.white
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.clear
        let mask = CAShapeLayer()
        mask.lineWidth = 0
        mask.strokeColor = UIColor.clear.cgColor
        mask.fillColor = bgColor.cgColor
        self.layer.addSublayer(mask)
        for view in self.subviews{
            self.bringSubviewToFront(view)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let layers = self.layer.sublayers {
            for layr in layers {
                if let newLay =  layr as? CAShapeLayer {
                    let rect = CGRect(origin: self.bounds.origin, size: CGSize(width: self.frame.width, height: self.frame.height))
                    let corner:UIRectCorner = [UIRectCorner.topLeft, UIRectCorner.topRight]
                    let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corner, cornerRadii: CGSize(width: radious, height: radious))
                    newLay.path = path.cgPath
                    newLay.fillColor = bgColor.cgColor
                    break
                }
            }
        }
    }
}

/// This is custom class for single sided rounded views
class NBottomRoundCornerView: ConstrainedView {
    
    @IBInspectable var radious: CGFloat = 0
    @IBInspectable var bgColor: UIColor = UIColor.white
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.clear
        let mask = CAShapeLayer()
        mask.lineWidth = 0
        mask.strokeColor = UIColor.clear.cgColor
        mask.fillColor = bgColor.cgColor
        self.layer.addSublayer(mask)
        for view in self.subviews{
            self.bringSubviewToFront(view)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let layers = self.layer.sublayers {
            for layr in layers {
                if let newLay =  layr as? CAShapeLayer {
                    let rect = CGRect(origin: self.bounds.origin, size: CGSize(width: self.frame.width, height: self.frame.height))
                    let corner:UIRectCorner = [UIRectCorner.bottomLeft, UIRectCorner.bottomRight]
                    let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corner, cornerRadii: CGSize(width: radious, height: radious))
                    newLay.path = path.cgPath
                    newLay.fillColor = bgColor.cgColor
                    break
                }
            }
        }
    }
}

/// This is custom rounded view with shadow
class NRoundShadowView: NRoundView {
    
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
        changeFrame()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        changeFrame()
    }
    
    func changeFrame() {
        let shadowRect = CGRect(origin: CGPoint.zero, size: CGSize(width: self.frame.width, height: self.frame.height))
        let corRad = self.cornerRadious == 0 ? self.frame.height / 2 : self.cornerRadious
        let path = UIBezierPath(roundedRect: shadowRect, byRoundingCorners: [.allCorners], cornerRadii: CGSize(width: corRad, height: corRad))
        layer.cornerRadius = cornerRadious
        layer.shadowPath = path.cgPath
    }
}

/// This is rounded view with fixed shadow configurations
class NFixRoundShadowView: NRoundView {
    
    @IBInspectable var xPos: CGFloat = 0
    @IBInspectable var yPos: CGFloat = 0
    @IBInspectable var radious: CGFloat = 4
    @IBInspectable var opacity: CGFloat = 0.4
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let corner = cornerRadious == 0 ? (self.frame.height / 2) * (DeviceType.iPad ? _widthRatio : 1) : cornerRadious
        let shadowRect = CGRect(origin: CGPoint.zero, size: CGSize(width: self.frame.size.width, height: self.frame.size.height))
        let roundPath = UIBezierPath(roundedRect: shadowRect, byRoundingCorners: [.allCorners], cornerRadii: CGSize(width: corner, height: corner))
        layer.shadowPath = roundPath.cgPath
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        clipsToBounds = true
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = Float(opacity)
        layer.shadowOffset = CGSize(width: xPos, height: yPos)
        layer.shadowRadius = radious
    }
}

/// This is custom navigation view
class NNavigationView: ConstrainedView {
    
    @IBInspectable var height: CGFloat = 44
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.09
        layer.shadowOffset = CGSize(width: 0, height: 1)
        layer.shadowRadius = 2
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let shadowRect = CGRect(origin: CGPoint.zero, size: CGSize(width: self.frame.width, height: self.frame.height))
        let path = UIBezierPath(rect: shadowRect)
        layer.shadowPath = path.cgPath
    }
}

/// This is custom navigation view with gredient
class NGredientNavigationView : ConstrainedView {
    
    @IBInspectable var height: CGFloat = 44
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.applyGradient(colours: [AppColor.themePrimary,AppColor.themePrimary])
    }
    
    func applyGradient(colours: [UIColor]) -> Void {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.frame
        gradient.colors = colours.map { $0.cgColor }
        gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradient.opacity = 1
        self.layer.insertSublayer(gradient, at: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let layers = self.layer.sublayers {
            for layer in layers {
                if let gradLayer = layer as? CAGradientLayer {
                    gradLayer.frame = self.frame
                    break
                }
            }
        }
    }
}

/// This is custom simple dark blur view
class NSimpleDarkBlur: ConstrainedView {
    override func awakeFromNib() {
        self.backgroundColor = UIColor.clear
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        //always fill the view
        blurEffectView.frame = self.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(blurEffectView)
        self.sendSubviewToBack(blurEffectView)
    }
}

/// This is custom simple light blur view
class NSimpleLightBlur: UIView {
    override func awakeFromNib() {
        self.backgroundColor = self.backgroundColor
        var blurEffect: UIBlurEffect = UIBlurEffect(style: UIBlurEffect.Style.extraLight)
        if _appTheme == .light {
            blurEffect = UIBlurEffect(style: UIBlurEffect.Style.extraLight)
        } else if _appTheme == .dark {
            blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        } else {
            blurEffect = UITraitCollection.current.userInterfaceStyle == .light ? UIBlurEffect(style: UIBlurEffect.Style.extraLight) : UIBlurEffect(style: UIBlurEffect.Style.dark)
        }
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        //always fill the view
        blurEffectView.frame = self.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(blurEffectView)
        self.sendSubviewToBack(blurEffectView)
    }
}

/// This is custom simple light blur view
class NBlurPageViewControl: UIPageControl {
    
    @IBInspectable var cornerRadious: CGFloat = 0 {
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
        self.layer.masksToBounds = true
        
        self.backgroundColor = self.backgroundColor
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.systemThinMaterialDark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        //always fill the view
        blurEffectView.frame = self.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(blurEffectView)
        self.sendSubviewToBack(blurEffectView)
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

/// This class will create grediant view
class NGradientView: NRoundView {
    
    var colours: [UIColor] = [AppColor.themePrimary, AppColor.themePrimary] {
        didSet {
            addGradient()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.masksToBounds = true
        self.clipsToBounds = true
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
            gradient.masksToBounds = true
            self.layer.insertSublayer(gradient, at: 0)
        }
    }
}

/// This class will create normal grediant by mixing provided start and end colors
class NNormalGradientView: ConstrainedView {
    
    @IBInspectable var startColor: UIColor = UIColor.white {
        didSet {
            addGradient()
        }
    }
    
    @IBInspectable var endColor: UIColor = UIColor.black {
        didSet {
            addGradient()
        }
    }
    
    // 0 - Horizontal, 1 - Vertical, 2 - Cross (Top to buttom)
    @IBInspectable var style: Int = 0 {
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
            gradient.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
            setPoint(layer: gradient)
            gradient.colors = [startColor, endColor].map { $0.cgColor }
        } else {
            gradient = CAGradientLayer()
            gradient.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height)
            gradient.colors = [startColor, endColor].map { $0.cgColor }
            setPoint(layer: gradient)
            gradient.opacity = 1
            self.layer.insertSublayer(gradient, at: 0)
        }
    }
    
    func setPoint(layer: CAGradientLayer) {
        if style == 0 {
            layer.startPoint = CGPoint(x: 0.0, y: 0.5)
            layer.endPoint = CGPoint(x: 1.0, y: 0.5)
        } else if style == 1 {
            layer.startPoint = CGPoint(x: 0.5, y: 0.0)
            layer.endPoint = CGPoint(x: 0.5, y: 1.0)
        } else {
            layer.startPoint = CGPoint(x: 0.0, y: 0.0)
            layer.endPoint = CGPoint(x: 1.1, y: 1.0)
        }
    }
}

class GradientView: UIView {
        
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
            gradient.endPoint = CGPoint(x: 0.0, y: 0.8)
        } else {
            gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
            gradient.endPoint = CGPoint(x: 1.0, y: 0.0)
        }
    }
}

class RoundGradientView: GradientView {
    
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

class RoundDottedView: UIView {
    
    @IBInspectable var cornerRadious: CGFloat = 0 {
        didSet{
            if cornerRadious == 0{
                layer.cornerRadius = self.frame.height / 2
            }else{
                layer.cornerRadius = cornerRadious * _widthRatio
            }
        }
    }
    
    @IBInspectable var borderColor: UIColor = UIColor.clear
    
    @IBInspectable var borderWidth: CGFloat = 0
    
//    override func draw(_ rect: CGRect) {
//        super.draw(rect)
//        let corner = cornerRadious == 0 ? self.frame.height / 2 : cornerRadious
//        let shapeLayer = CAShapeLayer()
//        shapeLayer.strokeColor = borderColor.cgColor
//        shapeLayer.fillColor = self.backgroundColor?.cgColor
//        shapeLayer.lineWidth = borderWidth
//        shapeLayer.lineDashPattern = [6,6]
//        let path = CGMutablePath()
//        path.addRoundedRect(in: self.bounds, cornerWidth: corner, cornerHeight: corner)
//        shapeLayer.path = path
//        self.layer.addSublayer(shapeLayer)
//        for view in self.subviews{
//            self.bringSubviewToFront(view)
//        }
//    }
    
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
        updateBorders()
    }
    
    func updateBorders() {
        let corner = layer.cornerRadius
        let shapeLayer = CAShapeLayer()
        shapeLayer.strokeColor = borderColor.cgColor
        shapeLayer.fillColor = self.backgroundColor?.cgColor
        shapeLayer.lineWidth = borderWidth
        shapeLayer.lineDashPattern = [6,6]
        let path = CGMutablePath()
        path.addRoundedRect(in: self.bounds, cornerWidth: corner, cornerHeight: corner)
        shapeLayer.path = path
        self.layer.addSublayer(shapeLayer)
        for view in self.subviews{
            self.bringSubviewToFront(view)
        }
    }
}


class CircularProgressView: UIView {
    
    
    fileprivate var progressLayer = CAShapeLayer()
    fileprivate var trackLayer = CAShapeLayer()
    fileprivate var didConfigureLabel = false
    fileprivate var rounded: Bool
    fileprivate var filled: Bool
    
    
    fileprivate let lineWidth: CGFloat?
    
    
    
    var timeToFill = 3.43
    
    
    
    var progressColor = UIColor.white {
        didSet{
            progressLayer.strokeColor = progressColor.cgColor
        }
    }
    
    var trackColor = UIColor.white {
        didSet{
            trackLayer.strokeColor = trackColor.cgColor
        }
    }
    
    
    var progress: Float {
        didSet{
            var pathMoved = progress - oldValue
            if pathMoved < 0{
                pathMoved = 0 - pathMoved
            }
            
            setProgress(duration: timeToFill * Double(pathMoved), to: progress)
        }
    }
    
    
    
    
    fileprivate func createProgressView(){
        
        self.backgroundColor = .clear
        self.layer.cornerRadius = frame.size.width / 2
        let circularPath = UIBezierPath(arcCenter: center, radius: frame.width / 2, startAngle: CGFloat(-0.5 * .pi), endAngle: CGFloat(1.5 * .pi), clockwise: true)
        trackLayer.fillColor = UIColor.blue.cgColor
        
        
        trackLayer.path = circularPath.cgPath
        trackLayer.fillColor = .none
        trackLayer.strokeColor = trackColor.cgColor
        if filled {
            trackLayer.lineCap = .butt
            trackLayer.lineWidth = frame.width
        }else{
            trackLayer.lineWidth = lineWidth!
        }
        trackLayer.strokeEnd = 1
        layer.addSublayer(trackLayer)
        
        progressLayer.path = circularPath.cgPath
        progressLayer.fillColor = .none
        progressLayer.strokeColor = progressColor.cgColor
        if filled {
            progressLayer.lineCap = .butt
            progressLayer.lineWidth = frame.width
        }else{
            progressLayer.lineWidth = lineWidth!
        }
        progressLayer.strokeEnd = 0
        if rounded{
            progressLayer.lineCap = .round
        }
        
        
        layer.addSublayer(progressLayer)
        
    }
    
    
    
    
    
    func trackColorToProgressColor() -> Void{
        trackColor = progressColor
        trackColor = UIColor(red: progressColor.cgColor.components![0], green: progressColor.cgColor.components![1], blue: progressColor.cgColor.components![2], alpha: 0.2)
    }
    
    
    
    func setProgress(duration: TimeInterval = 3, to newProgress: Float) -> Void{
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.duration = duration
        
        animation.fromValue = progressLayer.strokeEnd
        animation.toValue = newProgress
        
        progressLayer.strokeEnd = CGFloat(newProgress)
        
        progressLayer.add(animation, forKey: "animationProgress")
        
    }
    
    
    
    override init(frame: CGRect){
        progress = 0
        rounded = true
        filled = false
        lineWidth = 2
        super.init(frame: frame)
        filled = false
        createProgressView()
    }
    
    required init?(coder: NSCoder) {
        progress = 0
        rounded = true
        filled = false
        lineWidth = 2
        super.init(coder: coder)
        createProgressView()
        
    }
    
    
    init(frame: CGRect, lineWidth: CGFloat?, rounded: Bool) {
        
        
        progress = 0
        
        if lineWidth == nil{
            self.filled = true
            self.rounded = false
        }else{
            if rounded{
                self.rounded = true
            }else{
                self.rounded = false
            }
            self.filled = false
        }
        self.lineWidth = lineWidth
        
        super.init(frame: frame)
        createProgressView()
        
    }
    
}
