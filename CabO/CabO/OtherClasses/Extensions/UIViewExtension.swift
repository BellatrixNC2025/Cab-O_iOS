import Foundation
import UIKit
import QuartzCore

//MARK: - Graphics
extension UIView {
    
    func makeRound() {
        layer.cornerRadius = (self.frame.height * _widthRatio) / 2
        clipsToBounds = true
    }
    
    func fadeAlpha(toAlpha: CGFloat, duration time: TimeInterval) {
        UIView.animate(withDuration: time) { () -> Void in
            self.alpha = toAlpha
        }
    }
    
    // Will add mask to given image
    func mask(maskImage: UIImage) {
        let mask: CALayer = CALayer()
        mask.frame = CGRect(x: 0, y: 0, width: maskImage.size.width, height: maskImage.size.height)//CGRectMake( 0, 0, maskImage.size.width, maskImage.size.height)
        mask.contents = maskImage.cgImage
        layer.mask = mask
        layer.masksToBounds = true
    }
    
    func shake() {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.04
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = CGPoint(x: self.center.x - 8, y: self.center.y)
        animation.toValue = CGPoint(x: self.center.x + 8, y: self.center.y)
        self.layer.add(animation, forKey: "position")
    }
}

// MARK: - Constraints
extension UIView {

    func addConstraintToSuperView(lead: CGFloat,
                                  leadRel: NSLayoutConstraint.Relation = .equal,
                                  trail: CGFloat,
                                  trailRel: NSLayoutConstraint.Relation = .equal,
                                  top: CGFloat,
                                  topRel: NSLayoutConstraint.Relation = .equal,
                                  bottom: CGFloat,
                                  bottomRel: NSLayoutConstraint.Relation = .equal) {
        guard self.superview != nil else {
            return
        }
        let top = NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.top, relatedBy: leadRel, toItem: self.superview!, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1.0, constant: top)
        let bottom = NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: bottomRel, toItem: self.superview!, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1.0, constant: bottom)
        let lead = NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.leading, relatedBy: leadRel, toItem: self.superview!, attribute: NSLayoutConstraint.Attribute.leading, multiplier: 1.0, constant: lead)
        let trail = NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: trailRel, toItem: self.superview!, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1.0, constant: trail)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.superview!.addConstraints([top,bottom,lead,trail])
    }
    
    func setViewHeight(height: CGFloat) {
        guard self.superview != nil else {
            return
        }
//        let height = NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.superview!, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1.0, constant: height)
        let height = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: height)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.superview!.addConstraints([height])
    }
    
    func setViewWidth(width: CGFloat) {
        guard self.superview != nil else {
            return
        }
//        let height = NSLayoutConstraint(item: self, attribute: NSLayoutConstraint.Attribute.trailing, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.superview!, attribute: NSLayoutConstraint.Attribute.trailing, multiplier: 1.0, constant: height)
        let height = NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1.0, constant: width)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.superview!.addConstraints([height])
    }
}

extension UIView {
    
    // Will take screen shot of whole screen and return image. It's working on main thread and may lag UI.
    func takeScreenShot() -> UIImage {
        UIGraphicsBeginImageContext(self.bounds.size)
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
        let rec = self.bounds
        self.drawHierarchy(in: rec, afterScreenUpdates: true)
        self.layer.render(in: UIGraphicsGetCurrentContext()!)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }

    // To give parellex effect on any view.
    func ch_addMotionEffect() {
        let axis_x_motion: UIInterpolatingMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.x", type: UIInterpolatingMotionEffect.EffectType.tiltAlongHorizontalAxis)
        axis_x_motion.minimumRelativeValue = NSNumber(value: -10)
        axis_x_motion.maximumRelativeValue = NSNumber(value: 10)
        
        let axis_y_motion: UIInterpolatingMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.y", type: UIInterpolatingMotionEffect.EffectType.tiltAlongVerticalAxis)
        axis_y_motion.minimumRelativeValue = NSNumber(value: -10)
        axis_y_motion.maximumRelativeValue = NSNumber(value: 10)
        
        let motionGroup : UIMotionEffectGroup = UIMotionEffectGroup()
        motionGroup.motionEffects = [axis_x_motion, axis_y_motion]
        self.addMotionEffect(motionGroup)
    }
    
    func inAnimate(){
        self.alpha = 1.0
        let animation = CAKeyframeAnimation(keyPath: "transform.scale")
        animation.values = [0.01,1.2,0.9,1]
        animation.keyTimes = [0,0.4,0.6,1]
        animation.duration = 0.5
        self.layer.add(animation, forKey: "bounce")
    }
    
    func OutAnimation(comp:@escaping ((Bool)->())){
        CATransaction.begin()
        CATransaction.setCompletionBlock({
            comp(true)
        })
        
        let animation = CAKeyframeAnimation(keyPath: "transform.scale")
        animation.values = [1,1.2,0.9,0.01]
        animation.keyTimes = [0,0.4,0.6,1]
        animation.duration = 0.2
        self.layer.add(animation, forKey: "bounce")
        CATransaction.commit()
    }

    
    //Applying gradient effect
    func applyGradientToView(colours: [UIColor] = [UIColor.hexStringToUIColor(hexStr: "33BFE2"),UIColor.hexStringToUIColor(hexStr: "6297D5")],locations location:[NSNumber] = [0.5,1.0],opacity opc:Float = 1, height: CGFloat, width: CGFloat) -> Void {
        self.layoutIfNeeded()
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = CGRect(x: 0, y: 0, width: _screenSize.width - width, height: height)
        gradient.colors = colours.map { $0.cgColor }
        gradient.startPoint = CGPoint(x: 0.0, y: 1.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        gradient.opacity = opc
        self.layer.insertSublayer(gradient, at: 0)
    }
}
