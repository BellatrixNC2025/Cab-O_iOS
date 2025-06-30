//
//  LoginVC.swift
//  CabO
//
//  Created by Octos.
//

import UIKit

class ButtonTableCell: ConstrainedTableViewCell {

    static let identifier: String = "buttonCell"
    static let cellHeight: CGFloat = 78 * _widthRatio
    
    /// Outlets
    @IBOutlet weak var bgView: NRoundView!
    @IBOutlet weak var btn: NRoundButton!
    
    /// Variables
    var btnTapAction: ((UIButton) -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        btn.backgroundColor = btn.isEnabled ? AppColor.themePrimary : AppColor.themePrimary
    }
}

// MARK: - UI & Actions
extension ButtonTableCell {
    
    func prepareStateUI(enable: Bool, enableColor: UIColor = AppColor.themePrimary, disableColor: UIColor = AppColor.themePrimary) {
        btn.isEnabled = enable
        btn.backgroundColor = btn.isEnabled ? enableColor : disableColor
    }
    
    @IBAction func btnTap(_ sender: UIButton) {
        btnTapAction?(sender)
    }
}

//MARK: - Register Cell
extension ButtonTableCell {
    
    class func prepareToRegisterCells(_ sender: UITableView) {
        sender.register(UINib(nibName: "ButtonTableCell", bundle: nil), forCellReuseIdentifier: identifier)
    }
}
