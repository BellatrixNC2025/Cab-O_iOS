import UIKit
import NVActivityIndicatorView

/// This class will update the constant based on the screensize
extension NSLayoutConstraint {
    
    @IBInspectable public var isHeightResize: Bool {
        get {
            return false
        }
        set {
            if newValue == true {
                let v1 = self.constant
                self.constant = v1 * _widthRatio
            }
        }
    }
    
    @IBInspectable public var isWidthResize: Bool {
        get {
            return false
        }
        set {
            if newValue == true {
                let v1 = self.constant
                self.constant = v1 * _heightRatio
            }
        }
    }
}

//MARK: - Constained Classes for All device support
/// This View contains collection of Horizontal and Vertical constrains. Who's constant value varies by size of device screen size.
class ConstrainedControl: UIControl {
    
    // MARK: Outlets
    @IBOutlet var horizontalConstraints: [NSLayoutConstraint]?
    @IBOutlet var verticalConstraints: [NSLayoutConstraint]?
    
    // MARK: Awaken
    override func awakeFromNib() {
        super.awakeFromNib()
        constraintUpdate()
    }
    
    func constraintUpdate() {
        if let hConts = horizontalConstraints {
            for const in hConts {
                let v1 = const.constant
                let v2 = v1 * _widthRatio
                const.constant = v2
            }
        }
        if let vConst = verticalConstraints {
            for const in vConst {
                let v1 = const.constant
                let v2 = v1 * _heightRatio
                const.constant = v2
            }
        }
    }
}


class ConstrainedView: UIView {
    
    // MARK: Outlets
    @IBOutlet var horizontalConstraints: [NSLayoutConstraint]?
    @IBOutlet var verticalConstraints: [NSLayoutConstraint]?
    @IBOutlet var tableView: UITableView!
    var refresh = UIRefreshControl()
    
    // MARK: Awaken
    override func awakeFromNib() {
        super.awakeFromNib()
        constraintUpdate()
        addThemeObserver()
        refresh.tintColor = AppColor.themePrimary
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if _appTheme != .system {
            overrideUserInterfaceStyle = appTheme
        }
    }
    
    func constraintUpdate() {
        if let hConts = horizontalConstraints {
            for const in hConts {
                let v1 = const.constant
                let v2 = v1 * _widthRatio
                const.constant = v2
            }
        }
        if let vConst = verticalConstraints {
            for const in vConst {
                let v1 = const.constant
                let v2 = v1 * _heightRatio
                const.constant = v2
            }
        }
    }
    
    lazy internal var centralActivityIndicator : NVActivityIndicatorView = {
        let act = NVActivityIndicatorView(frame: CGRect.zero, type: NVActivityIndicatorType.lineScalePulseOut, color: AppColor.successToastColor, padding: nil)
        return act
    }()
    
    func showCentralSpinner() {
        self.addSubview(centralActivityIndicator)
        let xConstraint = NSLayoutConstraint(item: centralActivityIndicator, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0)
        let yConstraint = NSLayoutConstraint(item: centralActivityIndicator, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0)
        let hei = NSLayoutConstraint(item: centralActivityIndicator, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.height, multiplier: 1, constant: 40)
        let wid = NSLayoutConstraint(item: centralActivityIndicator, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: nil, attribute: NSLayoutConstraint.Attribute.width, multiplier: 1, constant: 40)
        centralActivityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([xConstraint, yConstraint, hei, wid])
        centralActivityIndicator.alpha = 0.0
        self.layoutIfNeeded()
//        self.isUserInteractionEnabled = false
        centralActivityIndicator.startAnimating()
        UIView.animate(withDuration: 0.2) { () -> Void in
            self.centralActivityIndicator.alpha = 1.0
        }
    }
    
    func hideCentralSpinner() {
        self.isUserInteractionEnabled = true
        centralActivityIndicator.stopAnimating()
        UIView.animate(withDuration: 0.2) { () -> Void in
            self.centralActivityIndicator.alpha = 0.0
        }
    }
}

extension ConstrainedView {
    
    func addThemeObserver() {
        _defaultCenter.addObserver(self, selector: #selector(self.themeUpdate(_:)), name: Notification.Name.themeUpdateNotification, object: nil)
    }
    
    @objc func themeUpdate(_ notification: NSNotification){
        DispatchQueue.main.async {
            if _appTheme != .system {
                self.overrideUserInterfaceStyle = appTheme
            }
        }
    }
}


class GenericTableViewCell: ConstrainedTableViewCell {
    
    @IBOutlet var lblTitle: NLinkLabel!
    @IBOutlet var lblSubtitle: UILabel!
    @IBOutlet var imgv: UIImageView!
    @IBOutlet var lblSeprator : UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}

/// This Collection view cell contains collection of Horizontal and Vertical constrains. Who's constant value varies by size of device screen size.
class ConstrainedCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var horizontalConstraints: [NSLayoutConstraint]?
    @IBOutlet var verticalConstraints: [NSLayoutConstraint]?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        constraintUpdate()
    }
    
    // This will update constaints and shrunk it as device screen goes lower.
    func constraintUpdate() {
        if let hConts = horizontalConstraints {
            for const in hConts {
                let v1 = const.constant
                let v2 = v1 * _widthRatio
                const.constant = v2
            }
        }
        if let vConst = verticalConstraints {
            for const in vConst {
                let v1 = const.constant
                let v2 = v1 * _heightRatio
                const.constant = v2
            }
        }
    }
    
    // MARK: Activity
    lazy internal var activityIndicator : CustomActivityIndicatorView = {
        let image : UIImage = UIImage(named: kActivityButtonImageName)!
        return CustomActivityIndicatorView(image: image)
    }()
    
    lazy internal var smallActivityIndicator : CustomActivityIndicatorView = {
        let image : UIImage = UIImage(named: kActivitySmallImageName)!
        return CustomActivityIndicatorView(image: image)
    }()
    
    func showSmallSpinnerIn(container: UIView, control: UIButton, isCenter: Bool) {
        container.addSubview(smallActivityIndicator)
        let xConstraint = NSLayoutConstraint(item: smallActivityIndicator, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: container, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: -8.5)
        let yConstraint = NSLayoutConstraint(item: smallActivityIndicator, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: container, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: -8.5)
        smallActivityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([xConstraint, yConstraint])
        smallActivityIndicator.alpha = 0.0
        layoutIfNeeded()
        isUserInteractionEnabled = false
        smallActivityIndicator.startAnimating()
        UIView.animate(withDuration: 0.2) { () -> Void in
            self.smallActivityIndicator.alpha = 1.0
            if isCenter{
                control.alpha = 0.0
            }
        }
    }
    
    func hideSmallSpinnerIn(container: UIView, control: UIButton) {
        isUserInteractionEnabled = true
        smallActivityIndicator.stopAnimating()
        UIView.animate(withDuration: 0.2) { () -> Void in
            self.smallActivityIndicator.alpha = 0.0
            control.alpha = 1.0
        }
    }
    
    // This will show and hide spinner. In middle of container View
    // You can pass any view here, Spinner will be placed there runtime and removed on hide.
    func showSpinnerIn(container: UIView, control: UIButton, isCenter: Bool) {
        container.addSubview(activityIndicator)
        activityIndicator.stopAnimating()
        let xPoint: CGFloat!
        if isCenter {
            xPoint = -10
        }else{
            let str = control.title(for: .selected)
            control.contentEdgeInsets = UIEdgeInsets.init(top: 0, left: -30, bottom: 0, right: 0)
            xPoint = (str!.WidthWithNoConstrainedHeight(font: (control.titleLabel?.font)!)/2) - 5
        }
        
        let xConstraint = NSLayoutConstraint(item: activityIndicator, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: container, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: xPoint)
        let yConstraint = NSLayoutConstraint(item: activityIndicator, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: container, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: -10)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([xConstraint, yConstraint])
        activityIndicator.alpha = 0.0
        layoutIfNeeded()
        isUserInteractionEnabled = false
        activityIndicator.startAnimating()
        UIView.animate(withDuration: 0.2) { () -> Void in
            self.activityIndicator.alpha = 1.0
            if isCenter{
                control.alpha = 0.0
            }
        }
    }
    
    
    func hideSpinnerIn(container: UIView, control: UIButton) {
        isUserInteractionEnabled = true
        activityIndicator.stopAnimating()
        control.contentEdgeInsets = UIEdgeInsets.zero
        UIView.animate(withDuration: 0.2) { () -> Void in
            self.activityIndicator.alpha = 0.0
            control.alpha = 1.0
        }
        
    }
}
class IntrinsicTableView: UITableView {
    override var contentSize:CGSize {
        didSet {
            self.invalidateIntrinsicContentSize()
        }
    }
    override var intrinsicContentSize: CGSize {
        self.layoutIfNeeded()
        return CGSize(width: UIView.noIntrinsicMetric, height: contentSize.height)
    }
}
/// This Header view cell contains tableview of Horizontal and Vertical constrains. Who's constant value varies by size of device screen size.
class ConstrainedHeaderTableView: UITableViewHeaderFooterView {
    
    @IBOutlet var horizontalConstraints: [NSLayoutConstraint]?
    @IBOutlet var verticalConstraints: [NSLayoutConstraint]?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        constraintUpdate()
    }
    
    // This will update constaints and shrunk it as device screen goes lower.
    func constraintUpdate() {
        if let hConts = horizontalConstraints {
            for const in hConts {
                let v1 = const.constant
                let v2 = v1 * _widthRatio
                const.constant = v2
            }
        }
        if let vConst = verticalConstraints {
            for const in vConst {
                let v1 = const.constant
                let v2 = v1 * _heightRatio
                const.constant = v2
            }
        }
    }
}

/// This Table view cell contains collection of Horizontal and Vertical constrains. Who's constant value varies by size of device screen size.
class ConstrainedTableViewCell: UITableViewCell {
    
    @IBOutlet var horizontalConstraints: [NSLayoutConstraint]?
    @IBOutlet var verticalConstraints: [NSLayoutConstraint]?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        constraintUpdate()
    }
    
    // This will update constaints and shrunk it as device screen goes lower.
    func constraintUpdate() {
        if let hConts = horizontalConstraints {
            for const in hConts {
                let v1 = const.constant
                let v2 = v1 * _widthRatio
                const.constant = v2
            }
        }
        if let vConst = verticalConstraints {
            for const in vConst {
                let v1 = const.constant
                let v2 = v1 * _heightRatio
                const.constant = v2
            }
        }
    }
    

    // MARK: Activity
    lazy internal var activityIndicator : UIActivityIndicatorView = {
        let act = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
        act.color = UIColor.white
        return act
    }()
    
    lazy internal var smallActivityIndicator : CustomActivityIndicatorView = {
        let image : UIImage = UIImage(named: kActivitySmallImageName)!
        return CustomActivityIndicatorView(image: image)
    }()
    
    func showSmallSpinnerIn(container: UIView, control: UIControl, isCenter: Bool) {
        container.addSubview(smallActivityIndicator)
        let xConstraint = NSLayoutConstraint(item: smallActivityIndicator, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: container, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: -8.5)
        let yConstraint = NSLayoutConstraint(item: smallActivityIndicator, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: container, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: -8.5)
        smallActivityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([xConstraint, yConstraint])
        smallActivityIndicator.alpha = 0.0
        layoutIfNeeded()
        isUserInteractionEnabled = false
        smallActivityIndicator.startAnimating()
        UIView.animate(withDuration: 0.2) { () -> Void in
            self.smallActivityIndicator.alpha = 1.0
            if isCenter{
                control.alpha = 0.0
            }
        }
    }
    
    func hideSmallSpinnerIn(container: UIView, control: UIControl) {
        isUserInteractionEnabled = true
        smallActivityIndicator.stopAnimating()
        UIView.animate(withDuration: 0.2) { () -> Void in
            self.smallActivityIndicator.alpha = 0.0
            control.alpha = 1.0
        }
    }
    
    // This will show and hide spinner. In middle of container View
    // You can pass any view here, Spinner will be placed there runtime and removed on hide.
    func showSpinnerIn(container: UIView, control: UIButton) {
        container.addSubview(activityIndicator)
        let trail = NSLayoutConstraint(item: activityIndicator, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: container, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1, constant: -15)
        let yConstraint = NSLayoutConstraint(item: activityIndicator, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: container, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([trail, yConstraint])
        activityIndicator.alpha = 0.0
        layoutIfNeeded()
        isUserInteractionEnabled = false
        control.isEnabled = false
        activityIndicator.startAnimating()
        UIView.animate(withDuration: 0.2) { () -> Void in
            self.activityIndicator.alpha = 1.0
        }
    }

    
    func hideSpinnerIn(container: UIView, control: UIButton) {
        isUserInteractionEnabled = true
        activityIndicator.stopAnimating()
        control.contentEdgeInsets = UIEdgeInsets.zero
        control.isEnabled = true
        UIView.animate(withDuration: 0.2) { () -> Void in
            self.activityIndicator.alpha = 0.0
        }
    }
    
    func showSpinnerIn(container: UIView, control: UIView, isCenter: Bool) {
        container.addSubview(activityIndicator)
        let xConstraint = NSLayoutConstraint(item: activityIndicator, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: container, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0)
        let yConstraint = NSLayoutConstraint(item: activityIndicator, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: container, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([xConstraint, yConstraint])
        activityIndicator.alpha = 0.0
        layoutIfNeeded()
        activityIndicator.startAnimating()
        UIView.animate(withDuration: 0.2) { () -> Void in
            self.activityIndicator.alpha = 1.0
            if isCenter{
                control.alpha = 0.0
            }
        }
    }
    
    func hideSpinnerIn(container: UIView, control: UIView) {
        activityIndicator.stopAnimating()
        UIView.animate(withDuration: 0.2) { () -> Void in
            self.activityIndicator.alpha = 0.0
            control.alpha = 1.0
        }
    }
}

/// Below all calssed reduces text of button and Lavel according to device screen size
class NFixButton: UIButton {
    override func awakeFromNib() {
        if let img = self.imageView{
            let btnsize = self.frame.size
            let imgsize = img.frame.size
            let verPad = ((btnsize.height - (imgsize.height * _widthRatio)) / 2)
            self.imageEdgeInsets = UIEdgeInsets.init(top: verPad, left: 0, bottom: verPad, right: 0)
            self.imageView?.contentMode = .scaleAspectFit
        }
        if let afont = titleLabel?.font {
            titleLabel?.font = afont.withSize(afont.pointSize * _fontRatio)
        }
    }
}

class NWidthButton: UIButton {
    override func awakeFromNib() {
        if let img = self.imageView{
            let btnsize = self.frame.size
            let imgsize = img.frame.size
            let verPad = (((btnsize.height * _widthRatio) - (imgsize.height * _widthRatio)) / 2)
            self.imageEdgeInsets = UIEdgeInsets.init(top: verPad, left: 0, bottom: verPad, right: 0)
            self.imageView?.contentMode = .scaleAspectFit
        }
        if let afont = titleLabel?.font {
            titleLabel?.font = afont.withSize(afont.pointSize * _fontRatio)
        }
    }
}

class NWidthTextField: UITextField {
    @IBInspectable var letterSpace : CGFloat = 0{
        didSet{
            letterSpace = letterSpace * _widthRatio
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        if let afont = font {
            font = afont.withSize(afont.pointSize * _fontRatio)
        }
        
        if let place = placeholder{
            self.addCharactersSpacingInPlaceHolder(spacing: letterSpace, text: place)
        }
        
        if let txt = text{
            self.addCharactersSpacingInTaxt(spacing: letterSpace, text: txt)
        }
    }
}

class NHeightTextField: UITextField {
    @IBInspectable var letterSpace : CGFloat = 0{
        didSet{
            letterSpace = letterSpace * _heightRatio
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        if let afont = font {
            font = afont.withSize(afont.pointSize * _fontRatio)
        }
        
        if let place = placeholder{
            self.addCharactersSpacingInPlaceHolder(spacing: letterSpace, text: place)
        }
        if let txt = text{
            self.addCharactersSpacingInTaxt(spacing: letterSpace, text: txt)
        }
    }
}


class NWidthTextView: UITextView {
    @IBInspectable var letterSpace : CGFloat = 0{
        didSet{
            letterSpace = letterSpace * _heightRatio
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        if let afont = font {
            font = afont.withSize(afont.pointSize * _fontRatio)
        }
        if let txt = text{
            self.addCharactersSpacingInTaxt(spacing: letterSpace, text: txt)
        }
    }
}

class NHeightTextView: UITextView {
    override func awakeFromNib() {
        super.awakeFromNib()
        if let afont = font {
            font = afont.withSize(afont.pointSize * _fontRatio)
        }
    }
}

class NHeightButton: UIButton {
    @IBInspectable var letterSpace : CGFloat = 0{
        didSet{
            letterSpace = letterSpace * _heightRatio
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        if let afont = titleLabel?.font {
            titleLabel?.font = afont.withSize(afont.pointSize * _fontRatio)
        }
        if let title = titleLabel?.text{
            titleLabel?.addCharactersSpacing(spacing: letterSpace, text: title)
        }
    }
}

class NWidthAttriLabel: UILabel {
    
    @IBInspectable var letterSpace : CGFloat = 0 {
        didSet{
            letterSpace = letterSpace * _widthRatio
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if let att = self.attributedText{
            let str = att.string as NSString
            let range = str.range(of: att.string)
            let newAttriString = NSMutableAttributedString(attributedString: att)
            att.enumerateAttributes(in: range, options: [], using: { (attri, range, pointer) in
                if let font = attri[NSAttributedString.Key.font] as? UIFont{
                    let newFont = font.withSize(font.pointSize * _fontRatio)
                    newAttriString.addAttributes([NSAttributedString.Key.font: newFont], range: range)
                }
            })
            self.attributedText = newAttriString
        }
        if let _ = text{
//            addCharactersSpacing(spacing: letterSpace, text: title)
        }
    }
}

class NWidthLabel: UILabel {
    @IBInspectable var letterSpace : CGFloat = 0 {
        didSet{
            letterSpace = letterSpace * _widthRatio
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        font = font.withSize(font.pointSize * _fontRatio)
        if let title = text{
            addCharactersSpacing(spacing: letterSpace, text: title)
        }
    }
}

class NHeightLabel: UILabel {
    @IBInspectable var letterSpace : CGFloat = 0{
        didSet{
            letterSpace = letterSpace * _heightRatio
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        font = font.withSize(font.pointSize * _fontRatio)
        if let title = text{
            addCharactersSpacing(spacing: letterSpace, text: title)
        }
    }
}

class NWidthAttriButton: NWidthButton {
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if let att = self.currentAttributedTitle{
            let str = att.string as NSString
            let range = str.range(of: att.string)
            let newAttriString = NSMutableAttributedString(attributedString: att)
            att.enumerateAttributes(in: range, options: [], using: { (attri, range, pointer) in
                if let font = attri[NSAttributedString.Key.font] as? UIFont{
                    let newFont = font.withSize(font.pointSize * _widthRatio)
                    newAttriString.addAttributes([NSAttributedString.Key.font: newFont], range: range)
                }
            })
            self.setAttributedTitle(newAttriString, for: UIControl.State.normal)
        }
        
        if let afont = titleLabel?.font {
            titleLabel?.font = afont.withSize(afont.pointSize * _widthRatio)
        }
    }
}
