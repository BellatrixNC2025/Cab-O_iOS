//
//  RideTipTVC.swift
//  CabO
//
//  Created by Octos.
//

import UIKit

class RideTipTVC: ConstrainedTableViewCell {

    static let identifier: String = "RideTipTVC"
    
    /// Outlets
    @IBOutlet weak var btn5: UIButton!
    @IBOutlet weak var btn10: UIButton!
    @IBOutlet weak var btnOther: UIButton!
    
    @IBOutlet weak var vw5: UIView!
    @IBOutlet weak var vw10: UIView!
    @IBOutlet weak var vwOther: UIView!
    
    @IBOutlet weak var tfInput: UITextField!
    @IBOutlet weak var tfContainer: NRoundView!
    
    private let placeholderFont: UIFont = AppFont.fontWithName(.regular, size: (14 * _fontRatio))
    
    /// Variables
    lazy var inputAccView: NInputAccessoryView = {
        let view = NInputAccessoryView.initView(leftTitle: nil, rightTitle: "Done")
        view.backgroundColor = AppColor.headerBg
        view.rightBtn.tintColor = AppColor.primaryText
        view.rightBtn.target = self
        view.rightBtn.action = #selector(self.btnToolNextTap)
        return view
    }()
    
    var action_tipAmount_tap: ((Int) -> ())?
    var action_pay_tip: (() -> ())?
    weak var parent: ParentVC!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        tfContainer?.borderColor = AppColor.placeholderText
        tfInput?.font = placeholderFont
    }
}

// MARK: - UI & Actions
extension RideTipTVC {
    
    func prepareUI(_ tip: String) {
        tfInput?.setAttributedPlaceHolder(text: "Enter tip amount", font: placeholderFont, color: AppColor.placeholderText, spacing: 0)
        tfInput?.text = tip
        tfInput?.keyboardType = .numberPad
        tfInput?.inputAccessoryView = inputAccView
    }
    
    func updateTipAmountSelection(_ tag: Int) {
        vw5?.backgroundColor =       tag == 0 ? AppColor.themeGreen : .clear
        vw10?.backgroundColor =      tag == 1 ? AppColor.themeGreen : .clear
        vwOther?.backgroundColor =   tag == 2 ? AppColor.themeGreen : .clear
        
        tfContainer?.isHidden = tag != 2
    }
    
    @IBAction func btnTipAmountTap(_ sender: UIButton) {
        updateTipAmountSelection(sender.tag)
        action_tipAmount_tap?(sender.tag)
    }
    
    @IBAction func btnPayTipaTap(_ sender: UIButton) {
        action_pay_tip?()
    }
    
    @objc func btnToolNextTap() {
        tfInput?.resignFirstResponder()
    }
}

// MARK: - UITextFieldDelegate
extension RideTipTVC: UITextFieldDelegate {
    
    @IBAction func textChanged(_ sender: UITextField) {
        if let parent = parent as? RideDetailVC {
            parent.tipAmount = sender.text!.trimmedString()
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.tfContainer.borderColor = UIColor.hexStringToUIColor(hexStr: "#394675") | UIColor.hexStringToUIColor(hexStr: "#FFFEFF")
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.tfContainer.borderColor = AppColor.placeholderText
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        tfInput.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        _ = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        return string.isNumeric
    }
}

// MARK: - Register Cell
extension RideTipTVC {
    
    class func prepareToRegister(_ sender: UITableView) {
        sender.register(UINib(nibName: "RideTipTVC", bundle: nil), forCellReuseIdentifier: identifier)
    }
}
