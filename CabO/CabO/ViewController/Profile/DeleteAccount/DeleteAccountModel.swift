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
    case step1 = 1, step2
    
    var title: String {
        switch self {
        case .step1: return "Delete account"
        case .step2: return ""
        }
    }
    
    var hideRightImage: Bool {
        switch self {
        default: return true
        }
    }
}

// MARK: - DeleteAccountCellType
enum DeleteAccountCellType {
    case title, info,reasonCell, noteTitle, note1, note2, deleteSucces, deleteSuccesTitle, buttonCell
    
    var cellId: String {
        switch self {
        case .title: return "titleCell"
        case .info: return "infoCell"
        case .noteTitle: return "linkLabelCell"
        case .note1: return "infoCell"
        case .note2: return "infoCell"
        case .reasonCell: return InputCell.identifier
        case .deleteSucces: return "deleteSuccess"
        case .deleteSuccesTitle: return TitleTVC.identifier
        case .buttonCell: return ButtonTableCell.identifier
        }
    }
    var infoString: String {
        switch self {
        case .info: return "Your account and data will be permanently deleted as per legal requirements."
        case .note1: return "Your driver profile, ride history, and availability will be removed."
        case .note2: return "You won’t have access to account info, earnings, or past trip records."
        case .deleteSuccesTitle: return "Your Account\nSuccessfully Deleted!"
        default: return ""
        }
    }
    var cellHeight: CGFloat {
        switch self {
        case .reasonCell: return InputCell.normalHeight
        case .buttonCell: return ButtonTableCell.cellHeight
        default: return UITableView.automaticDimension
        }
    }
}

// MARK: - DeleteAccountCell
class DeleteAccountCell: ConstrainedTableViewCell {
    
    /// Outlets
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelLink:UILabel!
    @IBOutlet weak var lblInfo: UILabel!
    
    @IBOutlet var btnClose: TintButton!
    /// Variables
    weak var parent: DeleteAccountVC!
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
    }
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func prepareU() {
    }
    
  
    
    @IBAction func btnCloseTap(_ sender: UIButton) {
        parent.btnBackTap(sender)
    }
    
}


