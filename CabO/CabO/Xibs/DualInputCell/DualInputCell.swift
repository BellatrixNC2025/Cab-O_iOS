//
//  LoginVC.swift
//  CabO
//
//  Created by Octos.
//

import UIKit

class DualInputCell: UITableViewCell {

    static let identifier: String = "dualInputCell"
    static let normalHeight: CGFloat = 85 * _widthRatio
    private let placeholderFont: UIFont = AppFont.fontWithName(.regular, size: 14 * _fontRatio)
    
    /// Outlets
    @IBOutlet weak var textFieldOne: NTextFieldConfiguration!
    @IBOutlet weak var lblTitleOne: UILabel!
    @IBOutlet weak var imgLeftOne: UIImageView!
    @IBOutlet weak var imgRightOne: UIImageView!
    @IBOutlet weak var vwLeftBgOne: UIView!
    @IBOutlet weak var vwRightBgOne: UIView!
    @IBOutlet weak var btnInputOne: UIButton!
    @IBOutlet weak var tfLeadingOne: NSLayoutConstraint!
    
    @IBOutlet weak var textFieldTwo: NTextFieldConfiguration!
    @IBOutlet weak var lblTitleTwo: UILabel!
    @IBOutlet weak var imgLeftTwo: UIImageView!
    @IBOutlet weak var imgRightTwo: UIImageView!
    @IBOutlet weak var vwLeftBgTwo: UIView!
    @IBOutlet weak var vwRightBgTwo: UIView!
    @IBOutlet weak var btnInputTwo: UIButton!
    @IBOutlet weak var tfLeadingTwo: NSLayoutConstraint!
    
    @IBOutlet weak var viewTfOne: UIView!
    @IBOutlet weak var viewTfTwo: UIView!
    @IBOutlet weak var tfContainerOne: NRoundView!
    @IBOutlet weak var tfContainerTwo: NRoundView!
    
    /// Variables
    var maxLengthOne:Int?
    var maxLengthTwo:Int?
    
    weak var delegate: ParentVC! {
        didSet{
            prepareUI()
        }
    }
    
    lazy var datePicker: UIDatePicker = {
        let datePick = UIDatePicker()
        datePick.preferredDatePickerStyle = .inline
        datePick.datePickerMode = .date
        datePick.datePickerMode = .date
        datePick.addTarget(self, action: #selector(self.dateChanged), for: .valueChanged)
        datePick.frame = CGRect(x: 0, y: 0, width: _screenSize.width, height: 375 + _bottomBarHeight)
        return datePick
    }()
    
    lazy var pickerView: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.backgroundColor = AppColor.headerBg
        return pickerView
    }()
    
    lazy var inputAccView: NInputAccessoryView = {
        let view = NInputAccessoryView.initView(leftTitle: nil, rightTitle: "Next")
        view.backgroundColor = AppColor.headerBg
        view.rightBtn.tintColor = AppColor.primaryText
        view.rightBtn.target = self
        view.rightBtn.action = #selector(self.btnToolNextTap)
        return view
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        lblTitleOne?.font = placeholderFont
        lblTitleTwo?.font = placeholderFont

        textFieldOne?.font = placeholderFont
        textFieldTwo?.font = placeholderFont
    }
    
}


//MARK: - UI Methods
extension DualInputCell {
    
    func prepareUI() {
        
        textFieldOne?.leftViewMode = .never
        textFieldOne?.autocapitalizationType = .none
        textFieldOne?.autocorrectionType = .no
        textFieldOne?.returnKeyType = .next
        textFieldOne?.isSecureTextEntry = false
        textFieldOne?.inputAccessoryView = nil
        textFieldOne?.textColor = AppColor.primaryText
        textFieldOne?.isUserInteractionEnabled = true
        
        vwRightBgOne?.isHidden = true
        imgRightOne?.isHidden = true
        btnInputOne?.isHidden = true
        
        textFieldTwo?.leftViewMode = .never
        textFieldTwo?.autocapitalizationType = .none
        textFieldTwo?.autocorrectionType = .no
        textFieldTwo?.returnKeyType = .next
        textFieldTwo?.isSecureTextEntry = false
        textFieldTwo?.inputAccessoryView = nil
        textFieldTwo?.textColor = AppColor.primaryText
        textFieldTwo?.isUserInteractionEnabled = true
        
        vwRightBgTwo?.isHidden = true
        imgRightTwo?.isHidden = true
        btnInputTwo?.isHidden = true
        
        if let parent = delegate as? AddCarVC {
            prepareAddCarUI(parent)
        } else if let parent = delegate as? IdVerificationVC {
            prepareIdVerificationUI(parent)
        }
    }
    
    private func prepareAddCarUI(_ parent: AddCarVC) {
        let cellType = parent.arrCells[self.tag]
        
        lblTitleOne.text = cellType.title.0
        textFieldOne?.text = parent.data.carYear?.year ?? ""
        textFieldOne?.setAttributedPlaceHolder(text: cellType.placeholder.0, font: placeholderFont, color: AppColor.placeholderText, spacing: 0)
        tfLeadingOne.constant = 12 * _widthRatio
        vwLeftBgOne.isHidden = true
        imgLeftOne.isHidden = true
        
        vwRightBgOne.isHidden = false
        imgRightOne.isHidden = false
        imgRightOne.image = UIImage(named: "ic_dropdown")!.withTintColor(AppColor.primaryText)
        vwRightBgTwo.isHidden = false
        imgRightTwo.isHidden = false
        imgRightTwo.image = UIImage(named: "ic_dropdown")!.withTintColor(AppColor.primaryText)
        
        lblTitleTwo.text = cellType.title.1
        textFieldTwo?.text = parent.data.carColor?.color ?? ""
        textFieldTwo?.setAttributedPlaceHolder(text: cellType.placeholder.1, font: placeholderFont, color: AppColor.placeholderText, spacing: 0)
        tfLeadingTwo.constant = 12 * _widthRatio
        vwLeftBgTwo.isHidden = true
        imgLeftTwo.isHidden = true
        
        textFieldOne.inputView = pickerView
        textFieldOne.inputAccessoryView = inputAccView
        textFieldTwo.inputView = pickerView
        textFieldTwo.inputAccessoryView = inputAccView
    }
    
    private func prepareIdVerificationUI(_ parent: IdVerificationVC) {
        let cellType = parent.arrCells[self.tag]
        
        lblTitleOne.text = cellType.title
        textFieldOne?.text = parent.data.fName
        textFieldOne?.setAttributedPlaceHolder(text: cellType.title, font: placeholderFont, color: AppColor.placeholderText, spacing: 0)
        textFieldOne.autocapitalizationType = .words
        textFieldOne.returnKeyType = .next
        tfLeadingOne.constant = 0 * _widthRatio
        vwLeftBgOne.isHidden = false
        imgLeftOne.isHidden = false
        imgLeftOne.image = UIImage(named: "ic_person")!.withTintColor(AppColor.primaryText)
        maxLengthOne = cellType.maxLength
        
        lblTitleTwo.text = cellType.title
        textFieldTwo?.text = parent.data.lName
        textFieldTwo?.setAttributedPlaceHolder(text: cellType.title, font: placeholderFont, color: AppColor.placeholderText, spacing: 0)
        textFieldTwo.autocapitalizationType = .words
        textFieldTwo.returnKeyType = .done
        tfLeadingTwo.constant = 0 * _widthRatio
        vwLeftBgTwo.isHidden = false
        imgLeftTwo.isHidden = false
        imgLeftTwo.image = UIImage(named: "ic_person")!.withTintColor(AppColor.primaryText)
        maxLengthTwo = cellType.maxLength
    }
}

// MARK: - Actions
extension DualInputCell {
    
    @objc func dateChanged() {
        if self.textFieldOne.isFirstResponder {
            textFieldOne.text = Date.localDateString(from: datePicker.date, format: DateFormat.format_MMMddyyyy)
        } else {
            textFieldTwo.text = Date.localDateString(from: datePicker.date, format: DateFormat.format_MMMddyyyy)
        }
    }
    
    @IBAction func btnInputOneTap(_ sender: UIButton) {
        
    }
    
    @IBAction func btnInputTowTap(_ sender: UIButton) {
        
    }
    
    @objc func btnToolNextTap() {
        if let parent = delegate as? AddCarVC {
            if textFieldOne.isFirstResponder {
                parent.fetchMasterDetail(for: .yearAndColor)
                textFieldOne.resignFirstResponder()
            } else {
                textFieldTwo.resignFirstResponder()
            }
        } else {
            if textFieldOne.isFirstResponder {
                textFieldTwo.becomeFirstResponder()
            } else {
                if let cell = tableView?.cellForRow(at: IndexPath(row: tag + 1, section: 0)) as? InputCell {
                    cell.tfInput.becomeFirstResponder()
                } else {
                    textFieldTwo.resignFirstResponder()
                }
            }
        }
    }
}

//MARK: - TextField Delegate
extension DualInputCell: UITextFieldDelegate {
    
    @IBAction func textChangeOne(_ sender: UITextField) {
        if let parent = delegate as? IdVerificationVC {
            parent.data.fName = sender.text!.trimmedString()
        }
    }
    
    @IBAction func textChangedTwo(_ sender: UITextField) {
        if let parent = delegate as? IdVerificationVC {
            parent.data.lName = sender.text!.trimmedString()
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.tag == 0 {
            if let _ = delegate as? AddCarVC {
                return false
            } else if let maxLengthOne {
                let fullText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
                return fullText.count <= maxLengthOne
            }
        } else if textField.tag == 1 {
            if let _ = delegate as? AddCarVC {
                return false
            } else if let maxLengthTwo {
                let fullText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
                return fullText.count <= maxLengthTwo
            }
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let _ = delegate as? IdVerificationVC {
            if textField.returnKeyType == .next {
                textFieldTwo.becomeFirstResponder()
            } else {
                textFieldTwo.resignFirstResponder()
            }
        }
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField.tag == 0 {
            if let parent = delegate as? AddCarVC {
                if parent.data.carCompany == nil {
                    ValidationToast.showStatusMessage(message: "Please select make first")
                    return false
                } else if parent.data.carModel == nil {
                    ValidationToast.showStatusMessage(message: "Please select model first")
                    return false
                } else if parent.arrCarYears.isEmpty {
                    parent.fetchMasterDetail(for: .model)
                    return false
                } else {
                    if parent.data.carYear == nil {
                        textFieldOne.text = parent.arrCarYears[0].year
                        parent.data.carYear = parent.arrCarYears[0]
                    }
                    return true
                }
            }
        } else {
            if let parent = delegate as? AddCarVC {
                if parent.data.carCompany == nil {
                    ValidationToast.showStatusMessage(message: "Please select make first")
                    return false
                } else if parent.data.carModel == nil {
                    ValidationToast.showStatusMessage(message: "Please select model first")
                    return false
                } else if parent.data.carYear == nil {
                    ValidationToast.showStatusMessage(message: "Please select year first")
                    return false
                } else if parent.arrCarColors.isEmpty {
                    parent.fetchMasterDetail(for: .yearAndColor)
                    return false
                } else {
                    if parent.data.carColor == nil {
                        textFieldTwo.text = parent.arrCarColors[0].color
                        parent.data.carColor = parent.arrCarColors[0]
                    }
                    return true
                }
            }
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 0 {
            self.tfContainerOne.borderColor = UIColor.hexStringToUIColor(hexStr: "#394675") | UIColor.hexStringToUIColor(hexStr: "#FFFEFF")
        } else {
            self.tfContainerTwo.borderColor = UIColor.hexStringToUIColor(hexStr: "#394675") | UIColor.hexStringToUIColor(hexStr: "#FFFEFF")
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 0 {
            self.tfContainerOne.borderColor = AppColor.placeholderText
        } else {
            self.tfContainerTwo.borderColor = AppColor.placeholderText
        }
    }
}

// MARK: UIPickerViewDataSource & Delegate Method(s)
extension DualInputCell: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if let parent = delegate as? AddCarVC {
            let _ = parent.arrCells[self.tag]
            if textFieldOne.isFirstResponder {
                return parent.arrCarYears.count
            } else {
                return parent.arrCarColors.count
            }
        }
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if let parent = delegate as? AddCarVC {
            let _ = parent.arrCells[self.tag]
            if textFieldOne.isFirstResponder {
                return parent.arrCarYears[row].year
            } else {
                return parent.arrCarColors[row].color
            }
        }
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if let parent = delegate as? AddCarVC {
            let _ = parent.arrCells[self.tag]
            if textFieldOne.isFirstResponder {
                self.textFieldOne.text = parent.arrCarYears[row].year
                parent.data.carYear = parent.arrCarYears[row]
            } else {
                if !parent.arrCarColors.isEmpty {
                    self.textFieldTwo.text = parent.arrCarColors[row].color
                    parent.data.carColor = parent.arrCarColors[row]
                }
            }
        }
    }
}

//MARK: - Register Cell
extension DualInputCell {
    
    class func prepareToRegisterCells(_ sender: UITableView) {
        sender.register(UINib(nibName: "DualInputCell", bundle: nil), forCellReuseIdentifier: identifier)
    }
}
