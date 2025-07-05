//
//  LoginVC.swift
//  CabO
//
//  Created by Octos.
//

import UIKit

class InputCell: ConstrainedTableViewCell {
    
    /// Statis Constants
    static let identifier: String = "inputCell"
    static let textViewIdentifier: String = "textViewCell"
    static let normalHeight: CGFloat = 85 * _widthRatio
    static let textViewHeight: CGFloat = 190 * _widthRatio
    static let errorHeight: CGFloat = 100 * _widthRatio
    static let removeErrorHeight: Int = Int(errorHeight - normalHeight)
    private let placeholderFont: UIFont = AppFont.fontWithName(.mediumFont, size: (14 * _fontRatio))
    private let textFont: UIFont = AppFont.fontWithName(.bold, size: (14 * _fontRatio))
    /// Outlets
    @IBOutlet weak var tfContainer: NRoundView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var placeholder: UILabel!
    @IBOutlet weak var tfInput: NTextFieldConfiguration!
    @IBOutlet weak var txtView: UITextView!
    @IBOutlet weak var textFieldLeading: NSLayoutConstraint!
    @IBOutlet weak var textFieldTrailing: NSLayoutConstraint!
    @IBOutlet weak var labelInfoText: UILabel!
    
    @IBOutlet weak var imgLeft: TintImageView!
    @IBOutlet weak var imgRight: TintImageView!
    @IBOutlet weak var imgRightHeight: NSLayoutConstraint!
    @IBOutlet weak var vwLeftBg: UIView!
    @IBOutlet weak var vwRightBg: UIView!
    @IBOutlet weak var btnInput: UIButton!
    @IBOutlet weak var btnRight: UIButton!
    @IBOutlet weak var labelTextCount: UILabel!
    @IBOutlet weak var rightImgViewWidth: NSLayoutConstraint!
    
    @IBOutlet weak var btnInfo: UIButton!
    
    /// Variables
    var action_infoView: ((AnyObject) -> ())?
    
    var maxLength: Int?
    weak var delegate: ParentVC! {
        didSet {
            prepareUI()
        }
    }
    
    lazy var datePicker: UIDatePicker = {
        let datePick = UIDatePicker()
        datePick.preferredDatePickerStyle = .inline
        datePick.datePickerMode = .date
        datePick.tintColor = .systemBlue
        datePick.addTarget(self, action: #selector(self.dateChanged), for: .valueChanged)
        datePick.frame = CGRect(x: 0, y: 0, width: _screenSize.width, height: 375 + _bottomBarHeight)
        return datePick
    }()
    
    lazy var dateTimePicker: UIDatePicker = {
        let datePick = UIDatePicker()
        datePick.preferredDatePickerStyle = .inline
        datePick.datePickerMode = .dateAndTime
        datePick.tintColor = .systemBlue
        datePick.addTarget(self, action: #selector(self.dateChanged), for: .valueChanged)
        datePick.frame = CGRect(x: 0, y: 0, width: _screenSize.width, height: 400 + _bottomBarHeight + _statusBarHeight)
        return datePick
    }()
    
    lazy var pickerView: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.backgroundColor = AppColor.appBg
        pickerView.tintColor = AppColor.primaryText
        return pickerView
    }()
    
//    lazy var rightview: UIButton = {
//        let btn = UIButton()
////        btn.setImage(#imageLiteral(resourceName: "ic_field_no_error"), for: .normal)
////        btn.setImage(#imageLiteral(resourceName: "ic_field_error"), for: .disabled)
//        btn.sizeToFit()
//        btn.isUserInteractionEnabled = false
//        return btn
//    }()
    lazy var rightEyeview: UIButton = {
        let btn = UIButton()
        let img = UIImage(named: "ic_eye_close")!.withTintColor(AppColor.placeholderText)
        btn.setImage(img.scaleImage(toSize: img.size * _widthRatio), for: .normal)
        btn.sizeToFit()
        btn.addTarget(self, action: #selector(btnEyeTap), for: .touchUpInside)
        return btn
    }()
    
    lazy var changeButton: NRoundShadowButton = {
        let btn = NRoundShadowButton()
        btn.setTitle("Change", for: .normal)
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.titleLabel?.font = AppFont.fontWithName(.mediumFont, size: (12 * _fontRatio))
        btn.backgroundColor = AppColor.themePrimary
        btn.opacity = 0.25
        btn.cornerRadious = 0
        btn.frame = CGRect(x: _screenSize.width - ((DeviceType.iPad ? 160 : 120) * _widthRatio), y: tfContainer.frame.height / 6, width: ((DeviceType.iPad ? 104 : 64) * _widthRatio), height: (30 * _widthRatio))
        btn.addTarget(self, action: #selector(btnChangeDataTap), for: .touchUpInside)
        return btn
    }()
    
//    lazy var leftView: UILabel = {
//        let lbl = UILabel()
//        lbl.text = Config.countryCode
////        lbl.font = AppFont.fontWithName(.book, size: 16)
//        lbl.textColor = AppColor.primaryText
//        lbl.sizeToFit()
//        return lbl
//    }()
    
    lazy var inputAccView: NInputAccessoryView = {
        let view = NInputAccessoryView.initView(leftTitle: nil, rightTitle: "Next")
        view.backgroundColor = AppColor.roleBgGreen
        view.rightBtn.tintColor = AppColor.primaryTextDark
        view.rightBtn.target = self
        view.rightBtn.action = #selector(self.btnToolNextTap)
        return view
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if _appTheme != .system {
            self.overrideUserInterfaceStyle = appTheme
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        tfContainer?.borderColor = AppColor.textfieldBorder
        if let textfield = tfInput {
            tfContainer?.backgroundColor = textfield.isEnabled ? AppColor.textfieldBgDark : AppColor.textfieldBgDark.withAlphaComponent(0.5)
            tfInput?.textColor = textfield.isEnabled ? AppColor.primaryTextDark : AppColor.primaryTextDark.withAlphaComponent(0.5)
        }else{
            tfContainer?.backgroundColor = AppColor.textfieldBgDark
            tfInput?.textColor = AppColor.primaryTextDark
        }
        placeholder?.textColor = AppColor.placeholderText
        lblTitle?.font = placeholderFont
        placeholder?.font = placeholderFont
        tfInput?.font = textFont
        
        txtView?.font = textFont
        txtView?.textColor = AppColor.primaryTextDark
        imgLeft?.image = imgLeft?.image?.withTintColor(AppColor.primaryText)
        vwLeftBg.isHidden = true
        if let _ = delegate as? AddCardVC {
            imgRight?.image = imgRight?.image?.withRenderingMode(.alwaysOriginal)
        } else {
            imgRight?.image = imgRight?.image?.withTintColor(AppColor.primaryTextDark)
        }
        
        self.labelTextCount?.font = AppFont.fontWithName(.regular, size: (12 * _fontRatio))
        self.labelTextCount?.text = "\(txtView?.text?.count ?? 0)/\(maxLength ?? 250)"
    }
    
    @IBAction func btn_infp_tap(_ sender: UIButton) {
        action_infoView?(sender)
    }
}

//MARK: - UI Methods
extension InputCell {
    
    func prepareUI() {
        
        tfInput?.leftViewMode = .never
        tfInput?.autocapitalizationType = .none
        tfInput?.autocorrectionType = .no
        tfInput?.returnKeyType = .next
        tfInput?.isSecureTextEntry = false
        tfInput?.inputAccessoryView = nil
        tfInput?.textColor = AppColor.primaryText
        tfInput?.isUserInteractionEnabled = true
        labelInfoText?.isHidden = true
        
        vwRightBg?.isHidden = true
        imgRight?.isHidden = true
        btnInput?.isHidden = true
        
        btnInfo?.isHidden = true
        
        if let parent = delegate as? LoginVC {
            prepareLoginUI(parent)
        }
        else if let parent = delegate as? ForgotPasswordVC {
            prepareForgotUI(parent)
        }
        else if let parent = delegate as? SignUpVC {
            prepareSignupUI(parent)
        }
        else if let parent = delegate as? ResetPasswordVC {
            prepareResetPassUI(parent)
        }
        else if let parent = delegate as? ChangePasswordVC {
            prepareChangePassUI(parent)
        }
        else if let parent = delegate as? EditProfileVC {
            prepareEditProfileInfoUI(parent)
        }
        else if let parent = delegate as? AddCardVC {
            prepareAddCardUI(parent)
        }
        else if let parent = delegate as? AddCarVC {
            prepareAddCarUI(parent)
        }
        else if let parent = delegate as? CreateRideVC {
            prepareCreateRideUI(parent)
        }
        else if let parent = delegate as? RequestBookRideVC {
            prepareRequestBookRideUI(parent)
        }
        else if let parent = delegate as? AddSupportTicketVC {
            prepareAddSuporTicketUI(parent)
        }
        else if let parent = delegate as? PostRequestVC {
            preparePostRequestUI(parent)
        }
        else if let parent = delegate as? CancellationVC {
            prepareCancellationUI(parent)
        }
        else if let parent = delegate as? RideHistoryFilterVC {
            prepareRideHistoryFilterUI(parent)
        }
        else if let parent = delegate as? RateAndReviewVC {
            prepareRateReviewUI(parent)
        } else if let parent = delegate as? IdVerificationVC {
            prepareIdVerificationUI(parent)
        }else if let parent = delegate as? DeleteAccountVC {
            prepareDeleteAccountUI(parent)
        }
        else if let parent = delegate as? AddDriverVC {
            prepareAddDriverVCUI(parent)
        }
    }
    
    private func prepareAddDriverVCUI(_ parent: AddDriverVC){
        let cellType = parent.arrCells[self.tag]
        lblTitle?.text = cellType.inputTitle
        tfInput?.text = parent.data.getValue(cellType)
        tfInput?.setAttributedPlaceHolder(text: cellType.inputPlaceholder, font: placeholderFont, color: AppColor.placeholderText, spacing: 0)
        placeholder?.text = cellType.inputPlaceholder
        tfInput?.keyboardType = cellType.keyboardType
        tfInput?.returnKeyType = cellType.returnKeyType
        tfInput?.autocapitalizationType = cellType.capitalCase
        tfInput?.inputView = nil
        tfInput?.inputAccessoryView = cellType.inputAccView ? inputAccView : nil
        self.maxLength = cellType.maxLength
        tfInput?.returnKeyType = cellType == .lname ? .done : .next
        tfInput?.tintColor =  AppColor.primaryTextDark
        btnInput?.isHidden = cellType != .driveType
        imgRight?.isHidden = cellType != .driveType
        vwRightBg?.isHidden = cellType != .driveType
        
        imgRight?.image = UIImage(named: "ic_dropdown")?.withTintColor(AppColor.primaryTextDark)
    }
    private func prepareDeleteAccountUI(_ parent: DeleteAccountVC) {
        let cellType = parent.arrCells[self.tag]
        lblTitle.text = "Select Reason"
        tfInput?.text = parent.selectedReasonText
        tfInput?.setAttributedPlaceHolder(text: "Select Reason", font: placeholderFont, color: AppColor.placeholderText, spacing: 0)
        inputAccView.rightBtn.title = "Done"
        placeholder?.text = "Select Reason"
        placeholder?.isHidden = !parent.selectedReasonText.isEmpty
        
        btnInput?.isHidden = cellType != .reasonCell
        imgRight?.isHidden = cellType != .reasonCell
        vwRightBg?.isHidden = cellType != .reasonCell
        
        imgRight?.image = UIImage(named: "ic_dropdown")?.withTintColor(AppColor.primaryTextDark)
        
//        textFieldLeading?.constant = (cellType == .message ? 7 : 12) * _widthRatio
        vwLeftBg?.isHidden = true
        imgLeft?.isHidden = true
    }
    private func prepareIdVerificationUI(_ parent: IdVerificationVC) {
        let cellType = parent.arrCells[self.tag]
        lblTitle.text = cellType.title
        tfInput.setAttributedPlaceHolder(text: cellType.placeholder, font: placeholderFont, color: AppColor.placeholderText, spacing: 0)
        tfInput.autocapitalizationType = .words
        tfInput.text = parent.data.getData(cellType)
        tfInput.returnKeyType = .next
        
        self.maxLength = cellType.maxLength
        imgLeft?.image = UIImage(named: "ic_person")!.withTintColor(AppColor.primaryText)
    }
    
    private func prepareCreateRideUI(_ parent: CreateRideVC) {
        let cellType = parent.arrCells[self.tag]
        lblTitle.text = cellType.title
        txtView?.text = parent.data.desc
        placeholder?.text = "Write something here (Optional)"
        placeholder?.textColor = AppColor.placeholderText
        placeholder?.isHidden = !parent.data.desc.isEmpty
        inputAccView.rightBtn.title = "Done"
        txtView?.inputAccessoryView = inputAccView
        
        vwLeftBg?.isHidden = true
    }
    
    private func preparePostRequestUI(_ parent: PostRequestVC) {
        lblTitle.text = "Message"
        txtView?.text = parent.data.message
        placeholder?.text = "Write something here (Optional)"
        placeholder?.textColor = AppColor.placeholderText
        placeholder?.isHidden = !parent.data.message.isEmpty
        inputAccView.rightBtn.title = "Done"
        txtView?.inputAccessoryView = inputAccView
        
        vwLeftBg?.isHidden = true
    }
    
    private func prepareRateReviewUI(_ parent: RateAndReviewVC) {
        lblTitle.text = "Comment"
        txtView?.text = parent.data.msg
        placeholder?.text = "Write something here (Optional)"
        placeholder?.textColor = AppColor.placeholderText
        placeholder?.isHidden = !parent.data.msg.isEmpty
        inputAccView.rightBtn.title = "Done"
        txtView?.inputAccessoryView = inputAccView
        
        vwLeftBg?.isHidden = true
    }
    
    private func prepareRequestBookRideUI(_ parent: RequestBookRideVC) {
        lblTitle.text = "Message to driver"
        txtView?.text = parent.data.msgForDriver
        placeholder?.text = "Write something here (Optional)"
        placeholder?.textColor = AppColor.placeholderText
        txtView?.isHidden = false
        inputAccView.rightBtn.title = "Done"
        txtView?.inputAccessoryView = inputAccView
        
        vwLeftBg?.isHidden = true
    }
    
    private func prepareAddSuporTicketUI(_ parent: AddSupportTicketVC) {
        let cellType = parent.arrCells[self.tag]
        lblTitle.text = cellType.title
        tfInput?.text = parent.data.getValue(cellType)
        txtView?.text = parent.data.getValue(cellType)
        tfInput?.setAttributedPlaceHolder(text: cellType.inputPlaceholder, font: placeholderFont, color: AppColor.placeholderText, spacing: 0)
        txtView?.inputAccessoryView = inputAccView
        inputAccView.rightBtn.title = "Done"
        placeholder?.text = cellType.inputPlaceholder
        placeholder?.isHidden = !parent.data.getValue(cellType).isEmpty
        self.maxLength = cellType.maxLength
        
        btnInput?.isHidden = cellType != .issueType
        imgRight?.isHidden = cellType != .issueType
        vwRightBg?.isHidden = cellType != .issueType
        
        imgRight?.image = UIImage(named: "ic_dropdown")
        
        textFieldLeading?.constant = (cellType == .message ? 7 : 12) * _widthRatio
        vwLeftBg?.isHidden = true
        imgLeft?.isHidden = true
    }
    
    private func prepareRideHistoryFilterUI(_ parent: RideHistoryFilterVC) {
        let cellType = parent.arrCells[self.tag]
        lblTitle.text = cellType.title
        tfInput?.text = parent.data.getValue(cellType)
        tfInput?.setAttributedPlaceHolder(text: cellType.placeHolder, font: placeholderFont, color: AppColor.placeholderText, spacing: 0)
        tfInput?.inputView = cellType == .date ? datePicker : nil
        tfInput?.inputAccessoryView = cellType == .date ? inputAccView : nil
        
        datePicker.date = parent.data.date ?? Date()
        
        inputAccView.rightBtn.title = "Done"
        
        btnInput?.isHidden = cellType == .date
        imgRight?.isHidden = cellType != .date
        vwRightBg?.isHidden = cellType != .date
        
        tfInput?.tintColor = .clear
        imgLeft?.image = UIImage(named: "ic_dob")
        
        textFieldLeading?.constant = (cellType == .date ? 7 : 12) * _widthRatio
        vwLeftBg?.isHidden = cellType != .date
        imgLeft?.isHidden = cellType != .date
    }
    
    private func prepareCancellationUI(_ parent: CancellationVC) {
        let cellType = parent.arrCells[self.tag]
        lblTitle.text = cellType.title
        tfInput?.text = parent.data.getValue(cellType)
        txtView?.text = parent.data.getValue(cellType)
        tfInput?.setAttributedPlaceHolder(text: cellType.inputPlaceholder, font: placeholderFont, color: AppColor.placeholderText, spacing: 0)
        txtView?.inputAccessoryView = inputAccView
        inputAccView.rightBtn.title = "Done"
        placeholder?.text = cellType.inputPlaceholder
        placeholder?.isHidden = !parent.data.getValue(cellType).isEmpty
        self.maxLength = cellType.maxLength
        
        btnInput?.isHidden = cellType != .issueType
        imgRight?.isHidden = cellType != .issueType
        vwRightBg?.isHidden = cellType != .issueType
        
        imgRight?.image = UIImage(named: "ic_dropdown")
        
        textFieldLeading?.constant = (cellType == .message ? 7 : 12) * _widthRatio
        vwLeftBg?.isHidden = true
        imgLeft?.isHidden = true
    }
    
    private func prepareLoginUI(_ parent: LoginVC) {
        let cellType = parent.arrCells[self.tag]
        lblTitle.text = cellType.inputTitle
        tfInput.setAttributedPlaceHolder(text: cellType.inputPlaceholder, font: placeholderFont, color: AppColor.placeholderText, spacing: 0)
        
        tfInput.text = parent.data.getLoginData(cellType)
        tfInput.isSecureTextEntry = cellType == .pass ? parent.isSecurePass : false
        tfInput.returnKeyType = cellType == .phone ? .next : .done
        tfInput.keyboardType = cellType.keyboard
        tfInput.inputAccessoryView = cellType == .phone ? inputAccView : nil
        
        self.maxLength = cellType.maxLength
        
        imgLeft?.image = cellType.leftImage
        tfInput.rightViewMode = cellType == .pass ? .always : .never
        tfInput.rightView = cellType == .pass ? rightEyeview : nil
    }
    
    private func prepareForgotUI(_ parent: ForgotPasswordVC) {
        let cellType = parent.arrCells[self.tag]
        lblTitle.text = cellType.inputTitle
        tfInput.setAttributedPlaceHolder(text: cellType.inputPlaceholder, font: placeholderFont, color: AppColor.placeholderText, spacing: 0)
        self.maxLength = cellType.maxLength
        tfInput.text = parent.data.getValue(cellType)
        tfInput.keyboardType = cellType.keyboard
        tfInput.returnKeyType = .done
        tfInput.inputAccessoryView = inputAccView
        
        imgLeft?.image = cellType.leftImage
    }
    
    private func prepareSignupUI(_ parent: SignUpVC) {
        let cellType = parent.arrCells[self.tag]
        lblTitle.text = cellType.inputTitle
        tfInput?.text = parent.data.getValue(cellType)
        txtView?.text = parent.data.getValue(cellType)
        tfInput?.setAttributedPlaceHolder(text: cellType.inputPlaceholder, font: placeholderFont, color: AppColor.placeholderText, spacing: 0)
        placeholder?.text = cellType.inputPlaceholder
        if cellType == .bio {
            placeholder?.isHidden = !parent.data.getValue(cellType).isEmpty
        }

        tfInput?.isSecureTextEntry = (cellType == .pass || cellType == .conPass)
        tfInput?.returnKeyType = cellType.returnKeyType
        tfInput?.tintColor = (cellType == .dob || cellType == .gender) ? .clear : AppColor.primaryTextDark
        tfInput?.keyboardType = cellType.keyboard
        tfInput?.autocapitalizationType = cellType.capitalCase
        tfInput?.inputView = cellType == .dob ? datePicker : nil
        tfInput?.inputAccessoryView = cellType.inputAccView ? inputAccView : nil
        txtView?.inputAccessoryView = cellType.inputAccView ? inputAccView : nil
        labelInfoText?.isHidden = cellType.infoText.isEmpty
        labelInfoText?.text = cellType.infoText
        
        self.maxLength = cellType.maxLength
        
        self.alpha = parent.isEditable(cellType) ? 1 : 0.5
        self.isUserInteractionEnabled = parent.isEditable(cellType) ? true : false
        
        if cellType == .gender {
            imgLeft?.image = parent.data.gender != nil ? parent.data.gender?.image : cellType.leftImage
        } else {
            imgLeft?.image = cellType.leftImage
        }
        datePicker.date = parent.data.dob ?? Date().adding(.year, value: -18)
        datePicker.maximumDate = Date().adding(.year, value: -18)
        
        tfInput?.rightViewMode = EnumHelper.checkCases(cellType, cases: [.pass, .conPass]) ? .always : .never
        tfInput?.rightView = EnumHelper.checkCases(cellType, cases: [.pass, .conPass]) ? rightEyeview : nil

        if EnumHelper.checkCases(cellType, cases: [.pass, .conPass]) {
            prepareEyeUI(false)
        }
        btnInput?.isHidden = cellType != .homeAddress
        imgRight?.isHidden = cellType != .homeAddress
        vwRightBg?.isHidden = cellType != .homeAddress
        imgRight?.image = UIImage(named: "ic_map_pin")!.withTintColor(AppColor.appBg)
//        imgRight?.image = imgRight?.image?.withRenderingMode(.alwaysOriginal)
        
        if cellType == .gender {
            btnInput.isHidden = false
        }
    }
    
    private func prepareResetPassUI(_ parent: ResetPasswordVC) {
        let cellType = parent.arrCells[self.tag]
        lblTitle.text = cellType.inputTitle
        tfInput.setAttributedPlaceHolder(text: cellType.inputPlaceholder, font: placeholderFont, color: AppColor.placeholderText, spacing: 0)
        
        tfInput.text = parent.data.getValue(cellType)
        tfInput.isSecureTextEntry = true
        tfInput.returnKeyType = cellType == .pass ? .next : .done
        tfInput.inputAccessoryView = nil
        
        self.maxLength = cellType.maxLength
        
        imgLeft?.image = cellType.leftImage
        
        vwRightBg?.isHidden = true
        imgRight?.isHidden = true
        
        tfInput.rightViewMode = .always
        tfInput.rightView = rightEyeview
    }
    
    private func prepareChangePassUI(_ parent: ChangePasswordVC) {
        let cellType = parent.arrCells[self.tag]
        lblTitle.text = cellType.inputTitle
        tfInput.setAttributedPlaceHolder(text: cellType.inputPlaceholder, font: placeholderFont, color: AppColor.placeholderText, spacing: 0)
        
        tfInput.text = parent.data.getValue(cellType)
        tfInput.isSecureTextEntry = true
        tfInput.returnKeyType = cellType == .conPass ? .done : .next
        tfInput.inputAccessoryView = nil
        
        self.maxLength = cellType.maxLength
        
        imgLeft?.image = cellType.leftImage
        
        vwRightBg?.isHidden = true
        imgRight?.isHidden = true
        
        tfInput.rightViewMode = .always
        tfInput.rightView = rightEyeview
    }
    
    private func prepareEditProfileInfoUI(_ parent: EditProfileVC) {
                
        let cellType = parent.arrCells[self.tag]
        lblTitle?.text = cellType.inputTitle
        tfInput?.text = parent.data.getValue(cellType)
        txtView?.text = parent.data.getValue(cellType)
        tfInput?.setAttributedPlaceHolder(text: cellType.inputPlaceholder, font: placeholderFont, color: AppColor.placeholderText, spacing: 0)
        placeholder?.text = cellType.inputPlaceholder
        if cellType == .bio {
            placeholder?.isHidden = !parent.data.getValue(cellType).isEmpty
        }
        
        tfInput?.keyboardType = cellType.keyboardType
        tfInput?.returnKeyType = cellType.returnKeyType
        tfInput?.autocapitalizationType = cellType.capitalCase
        tfInput?.inputView = cellType == .dob ? datePicker : nil
        tfInput?.inputAccessoryView = cellType.inputAccView ? inputAccView : nil
        txtView?.inputAccessoryView = cellType.inputAccView ? inputAccView : nil
        self.maxLength = cellType.maxLength
        
        if cellType == .gender {
            imgLeft?.image = parent.data.gender != nil ? parent.data.gender?.image : cellType.leftImage
        } else {
            imgLeft?.image = cellType.leftImage
        }
        
        tfInput?.returnKeyType = cellType == .lname ? .done : .next
        tfInput?.tintColor = (cellType == .dob || cellType == .gender) ? .clear : AppColor.primaryTextDark
        labelInfoText?.isHidden = cellType.infoText.isEmpty
        labelInfoText?.text = cellType.infoText
        prepareDisableUI(cellType == .mobile || cellType == .email)
        
        btnInput?.isHidden = cellType != .homeAddress
        imgRight?.isHidden = cellType != .homeAddress
        vwRightBg?.isHidden = cellType != .homeAddress
        imgRight?.image = UIImage(named: "ic_map_pin")!.withTintColor(AppColor.appBg)
        
        datePicker.date = parent.data.dob ?? Date().adding(.year, value: -18)
        datePicker.maximumDate = Date().adding(.year, value: -18)
        if cellType == .gender {
            btnInput.isHidden = false
        }
    }
    
    private func prepareAddCardUI(_ parent: AddCardVC) {
        let cellType = parent.arrCells[self.tag]
        lblTitle?.text = cellType.title
        tfInput?.setAttributedPlaceHolder(text: cellType.placeholder, font: placeholderFont, color: AppColor.placeholderText, spacing: 0)
        tfInput.text = parent.data.getValue(cellType)
        maxLength = cellType.maxLength
        tfInput.keyboardType = cellType.keyboard
        tfInput?.autocapitalizationType = .words
        tfInput?.returnKeyType = cellType.returnKeyType
        tfInput?.inputAccessoryView = cellType.inputAccView ? inputAccView : nil
        inputAccView.rightBtn.title = cellType.returnKeyType == .done ? "Done" : "Next"
        
        textFieldLeading.constant = 12 * _widthRatio
        vwLeftBg.isHidden = true
        imgLeft.isHidden = true
        
        vwRightBg?.isHidden = cellType == .cardNumber ? false : true
        imgRight?.isHidden = cellType == .cardNumber ? false : true
        imgRightHeight?.constant = 35 * _heightRatio
        rightImgViewWidth?.constant = 50 * _widthRatio
    }
    
    private func prepareAddCarUI(_ parent: AddCarVC) {
        let cellType = parent.arrCells[self.tag]
        lblTitle?.text = cellType.title.0
        tfInput.text = parent.data.getValue(cellType)
        tfInput?.setAttributedPlaceHolder(text: cellType.placeholder.0, font: placeholderFont, color: AppColor.placeholderText, spacing: 0)
        
        tfInput?.inputView = cellType != .licencePlate ? pickerView : nil
        tfInput?.inputAccessoryView = cellType != .licencePlate ? inputAccView : nil
        inputAccView.rightBtn.title = "Done"
        
        tfInput?.keyboardType = .asciiCapable
        tfInput?.returnKeyType = cellType.returnKeyType
        
        textFieldLeading.constant = 12 * _widthRatio
        vwLeftBg.isHidden = true
        imgLeft.isHidden = true
        
        tfInput?.tintColor = cellType == .licencePlate ? AppColor.primaryTextDark : .clear
        imgRight?.isHidden = cellType == .licencePlate
        vwRightBg?.isHidden = cellType == .licencePlate
        
        imgRight?.image = UIImage(named: "ic_dropdown")
        
        labelInfoText?.isHidden = cellType.infoText.isEmpty
        labelInfoText?.text = cellType.infoText
        labelInfoText?.textColor = AppColor.placeholderText
    }
    func prepareDisableUI(_ isDisable: Bool) {
        tfContainer?.backgroundColor = isDisable ? AppColor.textfieldBgDark.withAlphaComponent(0.5) : AppColor.textfieldBgDark
        tfInput?.isEnabled = !isDisable
        imgLeft?.tintColor = isDisable ? UIColor.hexStringToUIColor(hexStr: "#A7AECE") : AppColor.primaryTextDark
        lblTitle?.textColor = AppColor.primaryTextDark
        tfInput?.textColor = isDisable ? AppColor.primaryTextDark.withAlphaComponent(0.5) : AppColor.primaryTextDark
//        tfContainer?.borderColor = isDisable ? UIColor.hexStringToUIColor(hexStr: "#DBD5EB") : AppColor.themePrimary
        //Comment this code because change button position changed
//        if isDisable {
//            tfContainer?.addSubview(changeButton)
//        } else {
//            changeButton.removeFromSuperview()
//        }
    }
}

// MARK: - Actions
extension InputCell {
    
    @IBAction func btnInputTap(_ sender: UIButton) {
        if let parent = delegate as? SignUpVC {
            let cellType = parent.arrCells[self.tag]
            if cellType == .gender {
                parent.openGenderPicker(sender)
            }else if cellType == .homeAddress {
                parent.openLocationPickerFor(self.tag)
            }
        } else if let parent = delegate as? EditProfileVC {
            let cellType = parent.arrCells[self.tag]
            if cellType == .gender {
                parent.openGenderPicker(sender)
            }else if cellType == .homeAddress {
                parent.openLocationPickerFor(self.tag)
            }
        } else if let parent = delegate as? AddSupportTicketVC {
            parent.openIssueTypePicker(sender)
        } else if let parent = delegate as? CancellationVC {
            parent.openIssueTypePicker(sender)
        } else if let parent = delegate as? RideHistoryFilterVC {
            parent.openLocationPickerFor(self.tag)
        }else if let parent = delegate as? DeleteAccountVC {
            parent.openIssueTypePicker(sender)
        }else if let parent = delegate as? AddDriverVC {
            parent.openIssueTypePicker(sender)
        }
    }
    
    @objc func btnChangeDataTap() {
        if let parent = delegate as? EditProfileVC {
            let cellType = parent.arrCells[self.tag]
            parent.openEditPopUp(cellType == .email)
        }
    }
    
    private func prepareEyeUI(_ hide: Bool) {
        tfInput?.isSecureTextEntry = !hide
        let img = UIImage(named: hide ? "ic_eye_open" : "ic_eye_close")!.withTintColor(AppColor.placeholderText)
        rightEyeview.setImage( img.scaleImage(toSize: img.size * _widthRatio)!.withTintColor(AppColor.placeholderText), for: .normal)
    }
    
    @objc func btnEyeTap() {
        if let parent = delegate as? LoginVC {
            parent.isSecurePass = !parent.isSecurePass
            prepareEyeUI(parent.isSecurePass)
        }
        else if let parent = delegate as? SignUpVC {
            let cellType = parent.arrCells[self.tag]
            if cellType == .pass {
                parent.passVisible = !parent.passVisible
                prepareEyeUI(parent.passVisible)
            } else if cellType == .conPass {
                parent.confirmPassVisible = !parent.confirmPassVisible
                prepareEyeUI(parent.confirmPassVisible)
            }
        }
        else if let parent = delegate as? ResetPasswordVC {
            let cellType = parent.arrCells[self.tag]
            if cellType == .pass {
                parent.data.passVisible = !parent.data.passVisible
                prepareEyeUI(parent.data.passVisible)
            } else if cellType == .conPass {
                parent.data.confirmPassVisible = !parent.data.confirmPassVisible
                prepareEyeUI(parent.data.confirmPassVisible)
            }
        } else if let _ = delegate as? ChangePasswordVC {
            prepareEyeUI(tfInput.isSecureTextEntry)
        }
    }
    
    @objc func btnToolNextTap() {
        if let parent = delegate as? SignUpVC {
            manageNextTapSignUI(parent)
        }
        else if let parent = delegate as? EditProfileVC {
            manageNextTapEditProfileUI(parent)
        }
        else if let parent = delegate as? AddCarVC {
            let cellType = parent.arrCells[self.tag]
            tfInput.resignFirstResponder()
            parent.fetchMasterDetail(for: cellType)
        }else if tfInput?.returnKeyType == .next {
            if let cell = tableView?.cellForRow(at: IndexPath(row: tag + 1, section: 0)) as? InputCell {
                cell.tfInput?.becomeFirstResponder()
                cell.txtView?.becomeFirstResponder()
            } else {
                tfInput?.resignFirstResponder()
                txtView?.resignFirstResponder()
            }
        } else {
            tfInput?.resignFirstResponder()
            txtView?.resignFirstResponder()
        }
    }
    
    func manageNextTapSignUI(_ parent: SignUpVC) {
        let cellType = parent.arrCells[self.tag]
        if cellType.returnKeyType == .next {
            if let cell = tableView?.cellForRow(at: IndexPath(row: tag + 1, section: 0)) as? InputCell {
                cell.tfInput?.becomeFirstResponder()
                cell.txtView?.becomeFirstResponder()
            } else {
                tfInput?.resignFirstResponder()
                txtView?.resignFirstResponder()
            }
        } else {
            tfInput?.resignFirstResponder()
            txtView?.resignFirstResponder()
        }
    }
    
    func manageNextTapEditProfileUI(_ parent: EditProfileVC) {
        let cellType = parent.arrCells[self.tag]
        if cellType.returnKeyType == .next {
            if let cell = tableView?.cellForRow(at: IndexPath(row: tag + 1, section: 0)) as? InputCell {
                cell.tfInput?.becomeFirstResponder()
                cell.txtView?.becomeFirstResponder()
            } else {
                tfInput?.resignFirstResponder()
                txtView?.resignFirstResponder()
            }
        } else {
            tfInput?.resignFirstResponder()
            txtView?.resignFirstResponder()
        }
    }
    
}

//MARK: - Text Changed
extension InputCell {
    
    @objc func dateChanged() {
        if let parent = delegate as? SignUpVC {
            parent.data.dob = datePicker.date
            tfInput.text = Date.localDateString(from: datePicker.date, format: DateFormat.format_MMMddyyyy)
        }
        else if let parent = delegate as? EditProfileVC {
            parent.data.dob = datePicker.date
            tfInput.text = Date.localDateString(from: datePicker.date, format: DateFormat.format_MMMddyyyy)
        }
        else if let parent = delegate as? RideHistoryFilterVC {
            parent.data.date = datePicker.date
            tfInput.text = Date.localDateString(from: datePicker.date, format: DateFormat.format_MMMddyyyy)
        }
    }
    
    @IBAction func textChanged(_ sender: UITextField) {
        if let parent = delegate as? LoginVC {
            let cellType = parent.arrCells[self.tag]
            parent.data.setLoginData(sender.text!.trimmedString(), cellType: parent.arrCells[self.tag])
            
        }
        else if let parent = delegate as? SignUpVC {
            let cellType = parent.arrCells[self.tag]
            parent.data.setValue(sender.text!.trimmedString(), cellType: parent.arrCells[self.tag])
            if cellType == .phone {
                sender.text = parent.data.getValue(cellType)
            }
        }
        else if let parent = delegate as? ForgotPasswordVC {
            parent.data.setValue(sender.text!.trimmedString(), parent.arrCells[self.tag])
        }
        else if let parent = delegate as? ResetPasswordVC {
            parent.data.setValue(sender.text!.trimmedString(), parent.arrCells[self.tag])
        }
        else if let parent = delegate as? ChangePasswordVC {
            parent.data.setValue(sender.text!.trimmedString(), parent.arrCells[self.tag])
        }
        else if let parent = delegate as? EditProfileVC {
            parent.data.setValue(sender.text!.trimmedString(), parent.arrCells[self.tag])
        }
        else if let parent = delegate as? AddSupportTicketVC {
            parent.data.setValue(sender.text!.trimmedString(), parent.arrCells[self.tag])
        }
        else if let parent = delegate as? CancellationVC {
            parent.data.setValue(sender.text!.trimmedString(), parent.arrCells[self.tag])
        }
        else if let parent = delegate as? AddCarVC {
            parent.data.setValue(sender.text!.trimmedString(), parent.arrCells[self.tag])
        }
        else if let parent = delegate as? IdVerificationVC {
            parent.data.setData(sender.text!.trimmedString(), parent.arrCells[self.tag])
        }
        else if let parent = delegate as? AddCardVC {
            let cellType = parent.arrCells[self.tag]
            if cellType == .cardNumber {
                sender.text = sender.text!.trimmedString().formatCreditCardNumber()
                
                tableView?.beginUpdates()
                let img = CardType(CreditCardValidator.shared.typeFromString(string: sender.text!.removeSpace())?.name.lowercased().removeSpace() ?? "").image
                if let img {
                    imgRight?.image = img.scaleImage(toSize: img.size * _heightRatio)
                } else {
                    imgRight?.image = nil
                }
                
                tableView?.endUpdates()
                
            }
            parent.data.setValue(sender.text!.trimmedString(), parent.arrCells[self.tag])
            if cellType == .expiry {
                sender.text = parent.data.getValue(cellType)
            }
        }
        else if let parent = delegate as? AddDriverVC {
            parent.data.setValue(sender.text!.trimmedString(), parent.arrCells[self.tag])
        }
    }
}

//MARK: - TextField Delegte
extension InputCell: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let parent = delegate as? SignUpVC {
            let cellType = parent.arrCells[self.tag]
            if cellType == .dob {
                parent.data.dob = datePicker.date
                tfInput?.text = Date.localDateString(from: datePicker.date, format: "MMM dd, yyyy")
            }
        }
        self.tfContainer.borderColor = AppColor.themePrimary | AppColor.themePrimary
        self.tfContainer?.backgroundColor = .white
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.tfContainer.borderColor = AppColor.textfieldBorder
        self.tfContainer?.backgroundColor = AppColor.textfieldBgDark
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let parent = delegate as? SignUpVC {
            manageNextTapSignUI(parent)
        } else if let parent = delegate as? EditProfileVC {
            manageNextTapEditProfileUI(parent)
        }
        else {
            if tfInput.returnKeyType == .next {
                if let cell = tableView?.cellForRow(at: IndexPath(row: tag + 1, section: 0)) as? InputCell {
                    cell.tfInput?.becomeFirstResponder()
                }
                else if let cell = tableView?.cellForRow(at: IndexPath(row: tag + 1, section: 0)) as? DualInputCell {
                    cell.textFieldOne?.becomeFirstResponder()
                }
            } else {
                tfInput.resignFirstResponder()
            }
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let maxLength {
            let fullText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
            if let parent = delegate as? LoginVC {
                let cellType = parent.arrCells[self.tag]
                if cellType == .phone {
                    return string.isNumeric && fullText.trimWhiteSpace().removeSpace().count <= maxLength
                }else {
                    return fullText.count <= maxLength
                }
            }
            else if let parent = delegate as? SignUpVC {
                let cellType = parent.arrCells[self.tag]
                if cellType == .phone {
                    return string.isNumeric && fullText.trimWhiteSpace().removeSpace().count <= maxLength
                } else if cellType == .dob || cellType == .gender {
                    return false
                } else if cellType == .email {
                    return parent.isEditable(cellType) && fullText.count <= maxLength
                }else if cellType == .homeAddress{
                    return false
                }
                else {
                    return fullText.count <= maxLength
                }
            }else if let parent = delegate as? ForgotPasswordVC {
                let cellType = parent.arrCells[self.tag]
                if cellType == .phone {
                    return string.isNumeric && fullText.trimWhiteSpace().removeSpace().count <= maxLength
                }else {
                    return fullText.count <= maxLength
                }
            }
            else if let parent = delegate as? EditProfileVC {
                let cellType = parent.arrCells[self.tag]
                if cellType == .dob || cellType == .gender {
                    return false
                } else if cellType == .homeAddress{
                    return false
                }else {
                    return fullText.count <= maxLength
                }
            }
            else if let parent = delegate as? AddCardVC {
                let fullText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
                let cellType = parent.arrCells[self.tag]
                if cellType != .cardHolderName {
                    return string.isNumeric && fullText.trimWhiteSpace().removeSpace().count <= maxLength
                } else {
                    return fullText.count <= maxLength
                }
            }else if let parent = delegate as? AddDriverVC {
                let cellType = parent.arrCells[self.tag]
                if cellType == .mobile {
                    return string.isNumeric && fullText.trimWhiteSpace().removeSpace().count <= maxLength
                }else if cellType == .email {
                    return fullText.count <= maxLength
                }else {
                    return fullText.count <= maxLength
                }
            }
            else {
                return fullText.count <= maxLength
            }
        } else if let parent = delegate as? AddCarVC {
            let cellType = parent.arrCells[self.tag]
            if cellType != .licencePlate {
                return false
            }
        } else if let _ = delegate as? RideHistoryFilterVC {
            return false
        }
        
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if let parent = delegate as? SignUpVC {
            let cellType = parent.arrCells[self.tag]
            if cellType == .email {
                return parent.isEditable(cellType)
            } else {
                return cellType != .gender
            }
        }
        else if let parent = delegate as? EditProfileVC {
            let cellType = parent.arrCells[self.tag]
            return cellType != .email && cellType != .mobile
        }
        else if let parent = delegate as? AddCarVC {
            let cellType = parent.arrCells[self.tag]
            if cellType == .type {
//                if parent.data.carType == nil {
                tfInput.text = parent.arrCarType.first
                parent.data.carType = parent.arrCarType[0]
//                }
                return true
            }else if cellType == .make {
                if parent.data.carCompany == nil {
                    tfInput.text = parent.arrCarCompanies[0].name
                    parent.data.carCompany = parent.arrCarCompanies[0]
                }
                return true
            }
            else if cellType == .model {
                if parent.data.carCompany == nil {
                    ValidationToast.showStatusMessage(message: "Please select make first")
                    return false
                } else if parent.arrCarModels.isEmpty {
                    parent.fetchMasterDetail(for: .make)
                    return false
                } else {
                    if parent.data.carModel == nil {
                        tfInput.text = parent.arrCarModels[0].name
                        parent.data.carModel = parent.arrCarModels[0]
                    }
                    return true
                }
            }
        }
        return true
    }
}

//MARK: - TextView Delegate
extension InputCell: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        placeholder?.isHidden = !textView.text.isEmpty
        
        if let parent = delegate as? SignUpVC {
            parent.data.setValue(textView.text!.trimmedString(), cellType: parent.arrCells[self.tag])
        }
        else if let parent = delegate as? EditProfileVC {
            parent.data.setValue(textView.text!.trimmedString(), parent.arrCells[self.tag])
        }
        else if let parent = delegate as? AddSupportTicketVC {
            parent.data.setValue(textView.text!.trimmedString(), parent.arrCells[self.tag])
        } 
        else if let parent = delegate as? CancellationVC {
            parent.data.setValue(textView.text!.trimmedString(), parent.arrCells[self.tag])
        } 
        else if let parent = delegate as? CreateRideVC {
            parent.data.desc = textView.text!.trimmedString()
        } 
        else if let parent = delegate as? PostRequestVC {
            parent.data.message = textView.text!.trimmedString()
        }
        else if let parent = delegate as? RequestBookRideVC {
            parent.data.msgForDriver = textView.text!.trimmedString()
        }
        else if let parent = delegate as? RateAndReviewVC {
            parent.data.msg = textView.text!.trimmedString()
        }
        self.labelTextCount?.text = "\(textView.text!.count)/\(maxLength ?? 250)"
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let fullText = (textView.text! as NSString).replacingCharacters(in: range, with: text)
        return fullText.count <= maxLength ?? 250
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.tfContainer.borderColor = AppColor.themePrimary | AppColor.themePrimary
        self.tfContainer?.backgroundColor = .white
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.tfContainer.borderColor = AppColor.textfieldBorder
        self.tfContainer?.backgroundColor = AppColor.textfieldBgDark
    }
}

// MARK: UIPickerViewDataSource & Delegate Method(s)
extension InputCell: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if let parent = delegate as? AddCarVC {
            let cellType = parent.arrCells[self.tag]
            if cellType == .make {
                return parent.arrCarCompanies.count
            } else if cellType == .model {
                return parent.arrCarModels.count
            }else if cellType == .type{
                return parent.arrCarType.count
            }
            return 2
        }
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        var strTitle : String = ""
        if let parent = delegate as? AddCarVC {
            let cellType = parent.arrCells[self.tag]
            if cellType == .make {
                strTitle =  parent.arrCarCompanies[row].name
            } else if cellType == .model {
                strTitle =  parent.arrCarModels[row].name
            }else if cellType == .type {
                strTitle = parent.arrCarType[row]
            }
        }
        return NSAttributedString(string: strTitle, attributes: [NSAttributedString.Key.foregroundColor:AppColor.primaryText])
    }
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        if let parent = delegate as? AddCarVC {
//            let cellType = parent.arrCells[self.tag]
//            if cellType == .make {
//                return parent.arrCarCompanies[row].name
//            } else if cellType == .model {
//                return parent.arrCarModels[row].name
//            }else if cellType == .type {
//                return parent.arrCarType[row]
//            }
//         return "aa"
//        }
//        return ""
//    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let parent = delegate as? AddCarVC {
            let cellType = parent.arrCells[self.tag]
            if cellType == .make {
                self.tfInput.text = parent.arrCarCompanies[row].name
                parent.data.carCompany = parent.arrCarCompanies[row]
            } else if cellType == .model {
                self.tfInput.text = parent.arrCarModels[row].name
                parent.data.carModel = parent.arrCarModels[row]
            }else if cellType == .type {
                self.tfInput.text = parent.arrCarType[row]
                parent.data.carType = parent.arrCarType[row]
            }
        }
    }
}

//MARK: - Register Cell
extension InputCell {
    
    class func prepareToRegisterCells(_ sender: UITableView) {
        sender.register(UINib(nibName: "InputCell", bundle: nil), forCellReuseIdentifier: identifier)
        sender.register(UINib(nibName: "TextViewCell", bundle: nil), forCellReuseIdentifier: textViewIdentifier)
    }
}
