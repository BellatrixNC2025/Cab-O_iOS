//
//  VerifyOtpCells.swift
//  CabO
//
//  Created by Octos.
//

import Foundation
import UIKit

//MARK: - OTP Timer Cell
class OTPTimerCell: ConstrainedTableViewCell {
    
    /// Outlets
    @IBOutlet weak var lblTimer: UILabel!
    @IBOutlet weak var lblResend: NLinkLabel!
    
    /// Variables
    weak var delegate: ParentVC! {
        didSet {
            startTimer()
        }
    }
    
    override func prepareForReuse() {
        stopTimer()
    }
    
    weak var timer: Timer?
    
    var strTime: String {
        if let parent = delegate as? VerifyOtpVC {
            let minutes = Int(parent.otpCounter) / 60 % 60
            let seconds = Int(parent.otpCounter) % 60
            return String(format:"%02i:%02i", minutes, seconds)
        } else if let parent = delegate as? StartBookingVC {
            let minutes = Int(parent.otpCounter) / 60 % 60
            let seconds = Int(parent.otpCounter) % 60
            return String(format:"%02i:%02i", minutes, seconds)
        } else {
            return String(format:"%02i:%02i", 0, 0)
        }
    }
    
    var resendInStr: NSAttributedString {
        let fontSize = 13 * _fontRatio
        let normalAttribute = [NSAttributedString.Key.foregroundColor: AppColor.primaryTextDark
                               , NSAttributedString.Key.font: AppFont.fontWithName(.mediumFont, size: fontSize)]
        let tagAtributes: [NSAttributedString.Key : Any] = [ NSAttributedString.Key.foregroundColor: AppColor.themePrimary, NSAttributedString.Key.attachment : "resend", NSAttributedString.Key.font: AppFont.fontWithName(.bold, size: fontSize)]
        let para = NSMutableParagraphStyle()
        para.minimumLineHeight = 20
        para.maximumLineHeight = 20
        para.alignment = .center
        let mutableStr = NSMutableAttributedString(attributedString: NSAttributedString.attributedText(texts: ["Resend code in ", strTime], attributes: [normalAttribute, tagAtributes]))
        let range = NSMakeRange(0, mutableStr.string.count)
        mutableStr.addAttribute(NSAttributedString.Key.paragraphStyle, value: para, range: range)
        
        return mutableStr
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layoutIfNeeded()
    }
    
    func startTimer() {
        stopTimer()
        updateTimerUI()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    @objc func updateTimer() {
        if let parent = delegate as? VerifyOtpVC {
            if parent.otpCounter > 1 {
                parent.otpCounter -= 1
            } else {
                stopTimer()
            }
        }
        else if let parent = delegate as? StartBookingVC {
            if parent.otpCounter > 1 {
                parent.otpCounter -= 1
            } else {
                stopTimer()
            }
        }
        updateTimerUI()
    }
    
    func updateTimerUI() {
        if let parent = delegate as? VerifyOtpVC {
            lblTimer.isHidden = !(parent.otpCounter > 1)
            lblResend.isHidden = (parent.otpCounter > 1)
            if parent.otpCounter > 1 {
                lblTimer.attributedText = resendInStr
            } else {
                lblTimer.text = ""
            }
        } else if let parent = delegate as? StartBookingVC {
            lblTimer.isHidden = !(parent.otpCounter > 1)
            lblResend.isHidden = (parent.otpCounter > 1)
            if parent.otpCounter > 1 {
                lblTimer.attributedText = resendInStr
            } else {
                lblTimer.text = ""
            }
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

//MARK: - ChageInfoCell
class ChangeOtpInfoCell: ConstrainedTableViewCell {
    
    /// Outlets
    @IBOutlet weak var lblInfo: UILabel!
    @IBOutlet weak var buttonEdit: NRoundButton!
    
    /// Variables
    var btnChangeAction: (() -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func btnChangeTap(_ sender: UIButton) {
        btnChangeAction?()
    }
}

