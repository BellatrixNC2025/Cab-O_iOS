//
//  MessageInputBar.swift

import Foundation
import UIKit

class LoadingButton: UIButton {
    var originalButtonText: String?
    var activityIndicator: UIActivityIndicatorView!
    var isloading: Bool = false
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    func showLoading() {
        originalButtonText = self.titleLabel?.text
        self.setTitle("", for: .normal)
        self.alpha = 0.3
        if (activityIndicator == nil) {
            activityIndicator = createActivityIndicator()
        }
        isloading = true
        showSpinning()
    }
    
    func hideLoading() {
        if activityIndicator != nil {
            isloading = false
            self.alpha = 1
            self.setTitle(originalButtonText, for: .normal)
            activityIndicator.stopAnimating()
        }
    }
    
    private func createActivityIndicator() -> UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = UIColor.black
        return activityIndicator
    }
    
    private func showSpinning() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(activityIndicator)
        centerActivityIndicatorInButton()
        activityIndicator.startAnimating()
    }
    
    private func centerActivityIndicatorInButton() {
        let xCenterConstraint = NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: activityIndicator, attribute: .centerX, multiplier: 1, constant: 0)
        self.addConstraint(xCenterConstraint)
        
        let yCenterConstraint = NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: activityIndicator, attribute: .centerY, multiplier: 1, constant: 0)
        self.addConstraint(yCenterConstraint)
    }
}

protocol MessageInputBarDelegate: AnyObject {
    func messageInputBar(didTap action: MessageInputBarAction)
}

enum MessageInputBarAction {
       case typing, camera, send
   }

class MessageInputBar: UIView  {
    
    /// Outlet(s)
    @IBOutlet weak var lblPlaceHolder: UILabel!
    @IBOutlet weak var txtV: UITextView!
    @IBOutlet weak var btnSend: LoadingButton!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var sendButtonHeight: NSLayoutConstraint!
    
    /// Variable(s)
    var maxHeight: CGFloat = 130 * _widthRatio
    var minHeight: CGFloat = 54 * _widthRatio // Total View Height
    var paddingTop: CGFloat = 0 // 11 * _widthRatio // TextView Top Padding
    var paddingBottom: CGFloat = 0 // 19 * _widthRatio // TextView Bottom Padding
    weak var delegate: MessageInputBarDelegate?
    var isText: Bool!

    var totalAccesoryMinmumHeight: CGFloat {
        return minHeight + paddingTop + paddingBottom
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        validateButton()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        txtV.tintColor = AppColor.primaryText
        txtV.font = AppFont.fontWithName(.regular, size: 14 * _fontRatio)
        
        sendButtonHeight.constant = 44 * _widthRatio
    }
    
    /// //This is needed so that the inputAccesoryView is properly sized from the auto layout constraints
    override var intrinsicContentSize: CGSize {
        txtV.isScrollEnabled = false
        /// Get Maximum Size of TextView according `textView.text`
        let size = txtV.sizeThatFits(CGSize(width: txtV.frame.width, height: .greatestFiniteMagnitude))
        /// Get Total Height with Top Bottom Padding
        let totalHeight = size.height + paddingTop + paddingBottom
        /// Compare Height
        if totalHeight < maxHeight {
            return CGSize(width: self.bounds.width, height: max(totalHeight, totalAccesoryMinmumHeight))
        } else {
            txtV.isScrollEnabled = true
            return CGSize(width: self.bounds.width, height: maxHeight)
        }
    }
}

// MARK: UI & Utility Method(s)
extension MessageInputBar {
    
    class func loadMessageInputBar(delegate: MessageInputBarDelegate?) -> MessageInputBar {
        let obj = Bundle.main.loadNibNamed("MessageInputBar", owner: self, options: nil)?.first as! MessageInputBar
        obj.delegate = delegate
        obj.layoutIfNeeded()
        return obj
    }
    
    func updateLayout() {
        self.invalidateIntrinsicContentSize()
        self.layoutIfNeeded()
        updateConstraints()
        lblPlaceHolder.isHidden = !txtV.text.isEmpty
    }
    
    func validateButton() { //paperclip , paperplane
        if !txtV.text.trimmedString().isEmpty && !btnSend.isloading {
            self.isText = true
            UIView.animate(withDuration: 0.1) {
                self.btnSend.setImage(UIImage(systemName: "paperplane"), for: .normal)
            }
        } else {
            self.isText = false
            UIView.animate(withDuration: 0.1) {
                self.btnSend.setImage(UIImage(systemName: "paperclip"), for: .normal)
            }
        }
    }
    
    func dismissKeyboard() {
        txtV.resignFirstResponder()
    }
}

// Button Action(s)
extension MessageInputBar {
    
    @IBAction func btnSendAction(_ sender: UIButton) {
        if self.isText {
            delegate?.messageInputBar(didTap: .send)
            txtV.text = ""
            updateLayout()
            validateButton()
        } else {
            delegate?.messageInputBar(didTap: .camera)
        }
    }
    
    @IBAction func btnCameraAction(_ sender: UIButton) {
        delegate?.messageInputBar(didTap: .camera)
    }
}

// MARK: - TextField Delegate Method(s)
extension MessageInputBar: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        updateLayout()
        validateButton()
        delegate?.messageInputBar(didTap: .typing)
    }
}
