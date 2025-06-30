import Foundation
import UIKit

public extension UIResponder {
    
    private struct Static {
        static weak var responder: UIResponder?
    }
    
    static func currentFirst() -> UIResponder? {
        Static.responder = nil
        UIApplication.shared.sendAction(#selector(UIResponder._trap), to: nil, from: nil, for: nil)
        return Static.responder
    }
    
    @objc private func _trap() {
        Static.responder = self
    }
}

extension IndexPath {
    // Return IndexPath
    static func indexPathForCellContainingView(view: UIView, inTableView tableView:UITableView) -> IndexPath? {
        let viewCenterRelativeToTableview = tableView.convert(CGPoint(x: view.bounds.midX, y: view.bounds.midY), from:view)
        return tableView.indexPathForRow(at: viewCenterRelativeToTableview)
    }
    
    static func indexPathForCellContainingView(view: UIView, inCollectionView collView:UICollectionView) -> IndexPath? {
        let viewCenterRelativeToCollview = collView.convert(CGPoint(x: view.bounds.midX, y: view.bounds.midY), from:view)
        return collView.indexPathForItem(at: viewCenterRelativeToCollview)
    }
}

extension NSAttributedString {
    
    func lineHeight() -> CGFloat {
        let constraintRect = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: [NSStringDrawingOptions.usesLineFragmentOrigin], context: nil)
        return ceil(boundingBox.height)
    }
    
    func heightWithConstrainedWidth(width: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: [NSStringDrawingOptions.usesLineFragmentOrigin], context: nil)
        return ceil(boundingBox.height)
    }
}

// MARK: - Attributed
extension NSAttributedString {
    
    // This will give combined string with respective attributes
    class func attributedText(texts: [String], attributes: [[NSAttributedString.Key : Any]]) -> NSAttributedString {
        let attbStr = NSMutableAttributedString()
        for (index,element) in texts.enumerated() {
            attbStr.append(NSAttributedString(string: element, attributes: attributes[index]))
        }
        return attbStr
    }
    
    class func attributedTextLocalize(text: String, attributes: (normal: [NSAttributedString.Key : Any], highlight: [NSAttributedString.Key : Any]?, link: [NSAttributedString.Key : Any]?, other: [NSAttributedString.Key : Any]?)) -> NSAttributedString {
        // * = Highlight, ^ = Link, ~ = Other
        let chSet = CharacterSet(charactersIn: "*^~")
        let components = text.components(separatedBy: chSet)
        let sequence = components.enumerated()
        let attributedString = NSMutableAttributedString()
        return sequence.reduce(into: attributedString) { string, pair in
            let attribute: [NSAttributedString.Key : Any]
            if text.contains(find: "*\(pair.element)*") {
                attribute = attributes.highlight ?? attributes.normal
            } else if text.contains(find: "^\(pair.element)^") {
                attribute = attributes.link ?? attributes.normal
            } else if text.contains(find: "~\(pair.element)~") {
                attribute = attributes.other ?? attributes.normal
            } else {
                attribute = attributes.normal
            }
            string.append(NSAttributedString(
                string: pair.element,
                attributes: attribute
            ))
        }
    }
}

// MARK: - UILabel Extension
extension UILabel {
    
    func animateLabelAlpha( fromValue: NSNumber, toValue: NSNumber, duration: CFTimeInterval) {
        let titleAnimation: CABasicAnimation = CABasicAnimation(keyPath: "opacity")
        titleAnimation.duration = duration
        titleAnimation.fromValue = fromValue
        titleAnimation.toValue = toValue
        titleAnimation.isRemovedOnCompletion = true
        layer.add(titleAnimation, forKey: "opacity")
    }
    
    func setAttributedText(text: String, font: UIFont, color: UIColor) {
        let mutatingAttributedString = NSMutableAttributedString(string: text)
        mutatingAttributedString.addAttribute(NSAttributedString.Key.font, value: font, range: NSMakeRange(0, text.count))
        mutatingAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: NSMakeRange(0, text.count))
        attributedText = mutatingAttributedString
    }
    
    // This will give combined string with respective attributes
    func setAttributedText(texts: [String], attributes: [[NSAttributedString.Key : Any]]) {
        let attbStr = NSMutableAttributedString()
        for (index,element) in texts.enumerated() {
            attbStr.append(NSAttributedString(string: element, attributes: attributes[index]))
        }
        attributedText = attbStr
    }
    
    func addCharactersSpacing(spacing:CGFloat, text:String) {
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(NSAttributedString.Key.kern, value: spacing, range: NSMakeRange(0, text.count))
        self.attributedText = attributedString
    }
}

extension UIButton{
    // This will give combined string with respective attributes
    func setAttributedText(texts: [String], attributes: [[NSAttributedString.Key : Any]],state: UIControl.State) {
        let attbStr = NSMutableAttributedString()
        for (index,element) in texts.enumerated() {
            attbStr.append(NSAttributedString(string: element, attributes: attributes[index]))
        }
        setAttributedTitle(attbStr, for: state)
    }
}

extension UITextField{
    func setAttributedPlaceHolder(text: String, font: UIFont, color: UIColor, spacing: CGFloat) {
        let mutatingAttributedString = NSMutableAttributedString(string: text)
        mutatingAttributedString.addAttribute(NSAttributedString.Key.font, value: font, range: NSMakeRange(0, text.count))
        mutatingAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: NSMakeRange(0, text.count))
        attributedPlaceholder = mutatingAttributedString
    }
    
    func addCharactersSpacingInTaxt(spacing:CGFloat, text:String) {
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(NSAttributedString.Key.kern, value: spacing, range: NSMakeRange(0, text.count))
        self.attributedText = attributedString
    }
    
    func addCharactersSpacingInPlaceHolder(spacing:CGFloat, text:String) {
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(NSAttributedString.Key.kern, value: spacing, range: NSMakeRange(0, text.count))
        self.attributedPlaceholder = attributedString
    }
    
    func addCharactersSpacingWithFont(spacing:CGFloat, text:String, range: NSRange) {
        let attributedString = NSMutableAttributedString(attributedString: self.attributedText!)
        attributedString.addAttribute(NSAttributedString.Key.kern, value: spacing, range: range)
        self.attributedText = attributedString
    }
    
    func addCharactersSpacingForOTP(spacing:CGFloat, text:String, range: NSRange) {
        let rangePara = NSMakeRange(0, text.count)
        let para = NSMutableParagraphStyle()
        para.firstLineHeadIndent = (50.widthRatio - String(text.first!).WidthWithNoConstrainedHeight(font: AppFont.fontWithName(FontType.regular, size: 18 * _fontRatio))) / 2
        let attributedString = NSMutableAttributedString(attributedString: self.attributedText!)
        attributedString.addAttribute(NSAttributedString.Key.kern, value: spacing, range: range)
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value: para, range: rangePara)
        self.attributedText = attributedString
    }
}

extension UITextView {
    func addCharactersSpacingInTaxt(spacing:CGFloat, text:String) {
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(NSAttributedString.Key.kern, value: spacing, range: NSMakeRange(0, text.count))
        self.attributedText = attributedString
    }
}

extension UIPanGestureRecognizer {
    
    func shouldScrollVertical() -> Bool {
        let point = self.translation(in: self.view)
        let pointX = abs(point.x)
        let pointY = abs(point.y)
        if pointX < pointY {
            return true
        }else{
            return false
        }
    }
}

//Remove objects
extension Array where Element: Equatable {
    mutating func remove(_ itm: Element) {
        if let index = firstIndex(of: itm) {
            remove(at: index)
        }
    }
    mutating func removeItem(_ itm: Element) {
        if let index = firstIndex(of: itm) {
            remove(at: index)
        }
    }
    
    mutating func removeObjectsInArray(array: [Element]) {
        for object in array {
            removeItem(object)
        }
    }
}

// MARK: - TableView Cell Extension
extension UITableViewCell {
    
    var tableView: UITableView? {
        var view = superview
        while let v = view, v.isKind(of: UITableView.self) == false {
            view = v.superview
        }
        return view as? UITableView
    }
}
