//
//  CreateRidePreferenceCell.swift
//  CabO
//
//  Created by Octos.
//

import UIKit

class CreateRideLuggageTableCell: ConstrainedTableViewCell {

    static var identifier: String = "createRideLuggageTableCell"
    static var cellHeight: CGFloat = 44 * _widthRatio
    
    /// Outlets
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblCount: UILabel!
    @IBOutlet weak var btnSelect: UIButton!
    
    /// Variables
    var selectionCallBack: (() -> ())?
    var plusMinusCallBack: ((Int) -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

// MARK: - UI& Actions
extension CreateRideLuggageTableCell {
    
    func prepareUI(_ lugg: RidePrefModel, selected: Bool = false) {
        btnSelect.isSelected = selected
        lblTitle.text = lugg.title
        lblCount.text = "\(lugg.count)"
    }
    
    @IBAction func btn_selectTap(_ sender: UIButton) {
        selectionCallBack?()
    }
    
    @IBAction func btn_plusMinus_tap(_ sender: UIButton) {
        plusMinusCallBack?(sender.tag)
    }
}


//MARK: - Register Cell
extension CreateRideLuggageTableCell {
    
    class func prepareToRegisterCells(_ sender: UITableView) {
        sender.register(UINib(nibName: "CreateRideLuggageTableCell", bundle: nil), forCellReuseIdentifier: identifier)
    }
}
