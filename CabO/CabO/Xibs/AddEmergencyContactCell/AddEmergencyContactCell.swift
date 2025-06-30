//
//  AddEmergencyContactCell.swift
//  CabO
//
//  Created by Octos.
//

import UIKit

class AddEmergencyContactCell: ConstrainedTableViewCell {
    
    static let identifier: String = "addEmergencyContactCell"
    static let normalHeight: CGFloat = 150 * _widthRatio
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
    @IBOutlet weak var imgLeftTwo: UIImageView!
    @IBOutlet weak var imgRightTwo: UIImageView!
    @IBOutlet weak var vwLeftBgTwo: UIView!
    @IBOutlet weak var vwRightBgTwo: UIView!
    @IBOutlet weak var btnInputTwo: UIButton!
    @IBOutlet weak var tfLeadingTwo: NSLayoutConstraint!
    
    @IBOutlet weak var buttonRemove: UIButton!
    @IBOutlet weak var viewTfOne: UIView!
    @IBOutlet weak var viewTfTwo: UIView!
    
    /// Variables
    var maxLengthOne:Int?
    var maxLengthTwo:Int?
    var btnRemoveCallBack: ((Int) -> ())?
    
    weak var delegate: ParentVC! {
        didSet{
            prepareUI()
        }
    }

    lazy var inputAccView: NInputAccessoryView = {
        let view = NInputAccessoryView.initView(leftTitle: nil, rightTitle: "Next")
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

        textFieldOne?.font = placeholderFont
        textFieldTwo?.font = placeholderFont
    }
}

//MARK: - UI Methods
extension AddEmergencyContactCell {
    
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
        
        if let parent = delegate as? SignUpVC {
            prepareSignupUI(parent)
        } else if let parent = delegate as? EditProfileVC {
            prepareEditProfileUI(parent)
        }
    }
    
    private func prepareSignupUI(_ parent: SignUpVC) {
        lblTitleOne.text = "Contact - \(self.tag + 1)"
                
        textFieldOne.text = parent.data.arrEmergencyContacts[self.tag].getValue(0)
        textFieldTwo.text = parent.data.arrEmergencyContacts[self.tag].getValue(1)
        
        textFieldOne.setAttributedPlaceHolder(text: "Name", font: placeholderFont, color: AppColor.placeholderText, spacing: 0)
        textFieldTwo.setAttributedPlaceHolder(text: "Mobile Number", font: placeholderFont, color: AppColor.placeholderText, spacing: 0)
        
        textFieldOne.keyboardType = .asciiCapable
        textFieldTwo.keyboardType = .phonePad
        textFieldOne.autocapitalizationType = .words
        textFieldTwo.autocapitalizationType = .words
                        
        textFieldOne.inputAccessoryView = nil
        textFieldTwo.inputAccessoryView = inputAccView
        
        maxLengthOne = 32
        maxLengthTwo = 10
        inputAccView.rightBtn.title = "Done"
    }
    
    private func prepareEditProfileUI(_ parent: EditProfileVC) {
        lblTitleOne.text = "Contact - \(self.tag + 1)"
        
        textFieldOne.text = parent.arrEmergencyContacts[self.tag].getValue(0)
        textFieldTwo.text = parent.arrEmergencyContacts[self.tag].getValue(1)
        
        textFieldOne.setAttributedPlaceHolder(text: "Name", font: placeholderFont, color: AppColor.placeholderText, spacing: 0)
        textFieldTwo.setAttributedPlaceHolder(text: "Mobile Number", font: placeholderFont, color: AppColor.placeholderText, spacing: 0)
        
        textFieldOne.keyboardType = .asciiCapable
        textFieldTwo.keyboardType = .phonePad
        textFieldOne.autocapitalizationType = .words
        textFieldTwo.autocapitalizationType = .words
                        
        textFieldOne.inputAccessoryView = nil
        textFieldTwo.inputAccessoryView = inputAccView
        
        maxLengthOne = 32
        maxLengthTwo = 10
        inputAccView.rightBtn.title = "Done"
    }
}

// MARK: - Actions
extension AddEmergencyContactCell {
    
    @IBAction func btnRemoveTap(_ sender: UIButton) {
        btnRemoveCallBack?(self.tag)
    }
    
    @objc func btnToolNextTap() {
        if let _ = delegate as? SignUpVC {
            if textFieldOne.isFirstResponder {
                textFieldTwo.becomeFirstResponder()
            } else {
                textFieldTwo.resignFirstResponder()
            }
        }
        else if let _ = delegate as? EditProfileVC {
            if textFieldOne.isFirstResponder {
                textFieldTwo.becomeFirstResponder()
            } else {
                textFieldTwo.resignFirstResponder()
            }
        }
    }
}

//MARK: - TextField Delegate
extension AddEmergencyContactCell: UITextFieldDelegate {
    
    @IBAction func textChangeOne(_ sender: UITextField) {
        if let parent = delegate as? SignUpVC {
            parent.data.arrEmergencyContacts[self.tag].setValue(sender.text!.trimmedString(), sender.tag)
        } else if let parent = delegate as? EditProfileVC {
            parent.arrEmergencyContacts[self.tag].setValue(sender.text!.trimmedString(), sender.tag)
        }
    }
    
    @IBAction func textChangedTwo(_ sender: UITextField) {
        if let parent = delegate as? SignUpVC {
            parent.data.arrEmergencyContacts[self.tag].setValue(sender.text!.trimmedString(), sender.tag)
            sender.text = sender.text?.trimmedString().formatPhoneNumber()
        } else if let parent = delegate as? EditProfileVC {
            parent.arrEmergencyContacts[self.tag].setValue(sender.text!.trimmedString(), sender.tag)
            sender.text = sender.text?.trimmedString().formatPhoneNumber()
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let fullText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        if textField.tag == 0 {
            if let maxLengthOne {
                return fullText.count <= maxLengthOne
            }
        } else {
            if let maxLengthTwo {
                return string.isNumeric && fullText.removeSpace().count <= maxLengthTwo
            }
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let _ = delegate as? SignUpVC {
            if textField.tag == 0 {
                textFieldTwo.becomeFirstResponder()
            } else {
                textFieldTwo.resignFirstResponder()
            }
        }
        else if let _ = delegate as? EditProfileVC {
            if textField.tag == 0 {
                textFieldTwo.becomeFirstResponder()
            } else {
                textFieldTwo.resignFirstResponder()
            }
        }
        return true
    }
    
}

//MARK: - Register Cell
extension AddEmergencyContactCell {
    
    class func prepareToRegisterCells(_ sender: UITableView) {
        sender.register(UINib(nibName: "AddEmergencyContactCell", bundle: nil), forCellReuseIdentifier: identifier)
    }
}
