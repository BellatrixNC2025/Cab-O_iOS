//
//  DeleteAccountModel.swift
//  CabO
//
//  Created by Octos.
//

import Foundation
import UIKit

// MARK: - DeleteAccountStep
enum DeleteAccountStep: Int {
    case step1 = 1, step2, step3
    
    var title: String {
        switch self {
        case .step1: return "Select reason"
        case .step2: return "Delete account?"
        case .step3: return "Account deleted"
        }
    }
    
    var hideRightImage: Bool {
        switch self {
        case .step3: return false
        default: return true
        }
    }
}

// MARK: - DeleteAccountCellType
enum DeleteAccountCellType {
    case title, info, description, linkLabel, reasonCell, otherReason
    
    var cellId: String {
        switch self {
        case .title: return "titleCell"
        case .info: return "infoCell"
        case .linkLabel: return "linkLabelCell"
        case .description: return "descriptionCell"
        case .reasonCell: return "reasonCell"
        case .otherReason: return "otherReasonCell"
        }
    }
}

// MARK: - DeleteAccountCell
class DeleteAccountCell: ConstrainedTableViewCell {
    
    /// Outlets
    @IBOutlet weak var imgRightTitle: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelLink:NLinkLabel!
    @IBOutlet weak var buttonReasonRadio: UIButton!
    @IBOutlet weak var lblReasonTitle: UILabel!
    @IBOutlet weak var placeholder: UILabel!
    @IBOutlet weak var textContainer: NRoundView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var labelTextCount: UILabel!
    
    /// Variables
    weak var parent: DeleteAccountVC!
    var maxLength: Int?
    
    lazy var inputAccView: NInputAccessoryView = {
        let view = NInputAccessoryView.initView(leftTitle: nil, rightTitle: "Done")
        view.rightBtn.target = self
        view.rightBtn.action = #selector(self.btnToolNextTap)
        return view
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textView?.font = AppFont.fontWithName(.regular, size: 12 * _fontRatio)
        textView?.inputAccessoryView = inputAccView
        placeholder?.font = AppFont.fontWithName(.regular, size: 12 * _fontRatio)
        labelTextCount?.font = AppFont.fontWithName(.regular, size: (12 * _fontRatio))
        labelTextCount?.text = "\(textView?.text?.count ?? 0)/\(maxLength ?? 250)"
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.labelTextCount?.font = AppFont.fontWithName(.regular, size: (12 * _fontRatio))
        self.labelTextCount?.text = "\(textView?.text?.count ?? 0)/\(maxLength ?? 250)"
    }
    
    func prepareU() {
        textView?.text = parent.otherReason
        placeholder?.isHidden = !parent.otherReason.isEmpty
    }
    
    @IBAction func btnChooseReasonTap(_ sender: UIButton) {
        parent.actionChooseReason(self.tag)
    }
    
    @objc func btnToolNextTap() {
        textView?.resignFirstResponder()
    }
}

//MARK: - TextView Delegate
extension DeleteAccountCell: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        placeholder?.isHidden = !textView.text.isEmpty
        parent.otherReason = textView.text
        self.labelTextCount?.text = "\(textView.text!.count)/\(maxLength ?? 250)"
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if parent.selectedReason != self.tag {
            parent.actionChooseReason(self.tag)
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let fullText = (textView.text! as NSString).replacingCharacters(in: range, with: text)
        return fullText.count <= 250
    }
}
