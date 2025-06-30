//
//  TitleTVC.swift
//  CabO
//
//  Created by Octos.
//

import UIKit

class TitleTVC: ConstrainedTableViewCell {

    static let identifier: String = "titleTVC"
    
    /// Outlets
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnInfo: UIButton!
    @IBOutlet weak var btnRight: UIButton!
    
    /// Variables
    var action_infoView: ((AnyObject) -> ())?
    var action_right_btn: ((AnyObject) -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    static func height(for title: String, width: CGFloat, font: UIFont = AppFont.fontWithName(.mediumFont, size: (20 * _fontRatio))) -> CGFloat {
        let height = title.heightWithConstrainedWidth(width: width, font: font)
        return height + 24
    }
}

// MARK: - UI & Actions
extension TitleTVC {
    
    func prepareUI(_ title: String, _ font: UIFont, clr: UIColor, showInfo: Bool = false) {
        lblTitle.text = title
        lblTitle.font = font
        lblTitle.textColor = clr
        btnInfo?.isHidden = !showInfo
    }
    
    @IBAction func btn_infp_tap(_ sender: UIButton) {
        action_infoView?(sender)
    }
    
    @IBAction func btn_right_tap(_ sender: UIButton) {
        action_right_btn?(sender)
    }
}

//MARK: - Register Cell
extension TitleTVC {
    
    class func prepareToRegisterCells(_ sender: UITableView) {
        sender.register(UINib(nibName: "TitleTVC", bundle: nil), forCellReuseIdentifier: identifier)
    }
}
