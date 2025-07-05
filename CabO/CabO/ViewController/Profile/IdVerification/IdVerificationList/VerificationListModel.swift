//
//  IdVerificationModel.swift
//  CabO
//
//  Created by OctosMac on 03/07/25.
//
import Foundation
import UIKit

// MARK: - VerificaionListModel
enum VerificaionListModel: CaseIterable {
case DrivingLicence
case AdharCard
case PanCard
    
    var celld: String {
        switch self {
        default: return "verificaionListCell"
        }
    }
    var title: String {
        switch self {
        case .DrivingLicence: return "Driving Licence*"
        case .AdharCard:  return "Adhar Card*"
        case .PanCard:  return "Pan Card"
        }
    }
}

//MARK: - ProfileMenuCell
class VerificaionListCell: ConstrainedTableViewCell {
    
    /// Outlets
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgRight: UIImageView!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet var btnAdd : NRoundButton!
    @IBOutlet var btnView: NRoundButton!
    @IBOutlet var btnReupload : NRoundButton!
    weak var parent: IdVerificationListVC!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        btnView.superview?.isHidden = true
        lblStatus.superview?.isHidden = true
    }
    
    func prepareUI(_ cellType: VerificaionListModel) {
        lblTitle?.text = cellType.title
        
        self.layoutIfNeeded()
    }
    @IBAction func btnViewTap(_ sender: UIButton) {
        parent.btnViewTap(sender)
    }
    @IBAction func btnAddTap(_ sender: UIButton) {
        parent.btnAddTap(sender)
    }
    
}
