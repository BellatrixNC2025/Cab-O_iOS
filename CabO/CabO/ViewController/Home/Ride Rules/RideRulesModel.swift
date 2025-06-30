//
//  RideRulesModel.swift
//  CabO
//
//  Created by Octos.
//

import Foundation
import UIKit

// MARK: - RideRules ScreenType
enum RideRulesScreenType {
    case crete, book
    
    var title: String {
        switch self {
        case .crete: return "Rules when posting a ride"
        case .book: return "Rules when booking a ride"
        }
    }
}

// MARK: - RideRule CellsType
enum RideRuleCellsType {
    case title, rule, termsConditions, btn
    
    var cellId: String {
        switch self {
        case .title: return TitleTVC.identifier
        case .rule: return "ruleCell"
        case .termsConditions: return "termsCell"
        case .btn: return ButtonTableCell.identifier
        }
    }
    
    var cellHeight: CGFloat {
        switch self {
        case .btn: return ButtonTableCell.cellHeight
        default: return UITableView.automaticDimension
        }
    }
}


// MARK: - CreateRide Rules Cell
class CreateRideRulesCell: ConstrainedTableViewCell {
    
    /// Outlets
    @IBOutlet weak var lblTerms: NLinkLabel!
    
    @IBOutlet weak var imgRule: UIImageView!
    @IBOutlet weak var labelRuleTitle: UILabel!
    @IBOutlet weak var labelRuleDesc: UILabel!
    
    /// Variables
    var action_termsTap:(() -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func action_tncTap(_ sender: UIButton) {
        sender.isSelected.toggle()
        action_termsTap?()
    }
}
