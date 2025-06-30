//
//  StartBookingVC.swift
//  CabO
//
//  Created by Octos.
//

import UIKit

// MARK: - StartBooking Cell
class StartBookingCell: ConstrainedTableViewCell {
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

// MARK: - StartBooking CellType
enum StartBookingCellType: CaseIterable {
    
    case user, seat, info, otp, resend, btn
    
    var cellId: String {
        switch self {
        case .user: return "userCell"
        case .seat: return "seatCell"
        case .info: return "infoCell"
        case .otp: return OtpCell.otpIdentifier
        case .resend: return "timerCell"
        case .btn: return ButtonTableCell.identifier
        }
    }
    
    var cellHeight: CGFloat {
        switch self {
        case .otp: return OtpCell.normalHeight
        case .btn: return ButtonTableCell.cellHeight + 24
        case .resend: return 44 * _widthRatio
        default: return UITableView.automaticDimension
        }
    }
}

// MARK: - StartBookingVC
class StartBookingVC: ParentVC {
    
    /// Variables
    var arrCells: [StartBookingCellType] = [.user, .seat, .info, .otp, .resend, .btn]
    var data: BookingRequestDetailModel!
    var rideId: Int!
    
    var isResendOtp: Bool = false
    var otpStr:String = ""
    var errOtpStr: String = ""
    var otpCounter: Int = 0
    
    var resendOtpStr: NSAttributedString {
        let fontSize = 13 * _fontRatio
        let tagAtributes: [NSAttributedString.Key : Any] = [ NSAttributedString.Key.foregroundColor: AppColor.primaryText, NSAttributedString.Key.attachment : "resend", NSAttributedString.Key.font: AppFont.fontWithName(.bold, size: fontSize), NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue]
        let para = NSMutableParagraphStyle()
        para.minimumLineHeight = 20
        para.maximumLineHeight = 20
        para.alignment = .center
        let mutableStr = NSMutableAttributedString(attributedString: NSAttributedString.attributedText(texts: ["Resend"], attributes: [tagAtributes]))
        let range = NSMakeRange(0, mutableStr.string.count)
        mutableStr.addAttribute(NSAttributedString.Key.paragraphStyle, value: para, range: range)
        
        return mutableStr
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepareUI()
        if data.verificationCode.isEmpty {
            resendCode()
        }
    }
}

// MARK: - UI Methods
extension StartBookingVC {
    
    func prepareUI() {
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 50, right: 0)
        registerCells()
        addKeyboardObserver()
    }
    
    func registerCells() {        
        OtpCell.prepareToRegisterCells(tableView)
        ButtonTableCell.prepareToRegisterCells(tableView)
    }
}

// MARK: - Actions
extension StartBookingVC {
    
    func btnResenrOtpTap() {
        otpStr = ""
        otpCounter = Setting.otpTimeSec
        tableView.reloadData()
        resendCode()
    }
    
    func buttonStartTap() {
        if otpStr.count < 4 {
            ValidationToast.showStatusMessage(message: "Please enter valid verification code")
        } else {
            startBooking()
        }
    }
}

// MARK: - TableView Methods
extension StartBookingVC : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrCells.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cellType = arrCells[indexPath.row]
        if cellType == .info {
            return "Please enter the verification code received on a rider's phone".heightWithConstrainedWidth(width: _screenSize.width - (90 * _widthRatio), font: AppFont.fontWithName(.regular, size: 12 * _fontRatio)) + (36 * _widthRatio)
        }
        return cellType.cellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellType = arrCells[indexPath.row]
        return tableView.dequeueReusableCell(withIdentifier: cellType.cellId, for: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cellType = arrCells[indexPath.row]
        if let cell = cell as? StartBookingCell {
            if cellType == .user {
                cell.lblTitle.text = data.fullName
                if !data.image.isEmpty {
                    cell.imgView?.loadFromUrlString(data.image, placeholder: _userPlaceImage)
                } else {
                    cell.imgView.image = _userPlaceImage
                }
            } else if cellType == .seat {
                cell.lblTitle.text = data.seatReq.stringValue
            }
        }
        else if let cell = cell as? OtpCell {
            cell.parentVC = self
        }
        else if let cell = cell as? OTPTimerCell {
            cell.tag = indexPath.row
            cell.delegate = self
            cell.lblResend.setTagText(attriText: resendOtpStr, linebreak: .byTruncatingTail)
            cell.lblResend.delegate = self
        }
        else if let cell = cell as? ButtonTableCell {
            cell.btn.setTitle("Verify", for: .normal)
            cell.btnTapAction = { [weak self] (_) in
                guard let self = self else { return }
                self.buttonStartTap()
            }
        }
    }
}

// MARK: - NLinkLabelDelagete
extension StartBookingVC: NLinkLabelDelagete {
    
    func tapOnEmpty(index: IndexPath?) {}
    
    func tapOnTag(tagName: String, type: ActiveType, tappableLabel: NLinkLabel) {
        nprint(items: tagName)
        if tagName == "resend" {
            btnResenrOtpTap()
        }
    }
}

// MARK: - UIKeyboard Observer
extension StartBookingVC {
    
    func addKeyboardObserver() {
        _defaultCenter.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        _defaultCenter.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: NSNotification){
        if let userInfo = notification.userInfo {
            if let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                guard let _ = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {return}
                tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height + 10, right: 0)
            }
        }
    }
    
    @objc func keyboardWillHide(_ notification: NSNotification){
        guard let _ = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {return}
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 0, right: 0)
    }
}

// MARK: - API Call
extension StartBookingVC {
    
    func resendCode() {
        showCentralSpinner()
        var param: [String: Any] = [:]
        param["source"] = "rider_code"
//        param["sourceid"] = data.mobile
        param["sourceid"] = data.bookRideId
        
        WebCall.call.resendOtp(param: param) { [weak self] (json, status) in
            guard let `self` = self else { return }
            self.hideCentralSpinner()
            if status == 200 {
                self.showSuccessMsg(data: json, yCord: _statusBarHeight)
                self.otpStr = ""
                self.tableView.reloadData()
            }
        }
    }
    
    func startBooking() {
        var param: [String: Any] = [:]
        param["ride_id"] = rideId
        param["book_ride_id"] = data.bookRideId
        param["ride_status"] = "start_booking"
        param["verification_code"] = otpStr
        param["date_time"] = Date().converDisplayDateTimeFormet()
        
        showCentralSpinner()
        WebCall.call.updateRideStatus(param) { [weak self] (json, status) in
            guard let self = self else { return }
            self.hideCentralSpinner()
            if status == 200 {
                self.showSuccessMsg(data: json, yCord: _navigationHeight)
                _defaultCenter.post(name: Notification.Name.rideDetailsUpdate, object: nil)
                self.navigationController?.popToViewController(ofClass: RideDetailVC.self, animated: true)
            } else {
                self.showError(data: json, yCord: _navigationHeight)
            }
        }
    }
}
