//
//  DriverListModel.swift
//  CabO
//
//  Created by OctosMac on 03/07/25.
//

import UIKit

class DriverListCell: ConstrainedTableViewCell {
    
    
    /// Outlets
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var imgUser: NRoundImageView!
    @IBOutlet weak var labelName: UILabel!
    
    @IBOutlet var btnView: NRoundButton!
    @IBOutlet var btnLogout: NRoundButton!
    @IBOutlet weak var viewStatus: NRoundView!
    @IBOutlet weak var labelStatus: UILabel!
    @IBOutlet weak var imgStatus: TintImageView!
    
    /// Variables
    weak var parent: DriverListVC!
    // MARK: - UI Methods
    func prepareCarStatusUI(_ status: DocStatus) {
        labelStatus.text = status.title
        labelStatus.textColor = status.statusColor
        viewStatus.borderColor = status.statusColor
        imgStatus.image = status.imgStatus
        imgStatus.tintColor = status.statusColor
    }
    
    func prepareUI(_ model: DriverModel, _ isFromEdit: Bool = false) {
        imgUser.borderColor = AppColor.primaryTextDark
        
        imgUser?.loadFromUrlString(model.img, placeholder: _userPlaceImage)
        labelName.text = model.fullName
        btnView.setTitle(isFromEdit ? "Edit" : "View", for: .normal)
//        prepareCarStatusUI(car.carStatus)
    }
    @IBAction func btnViewTap(_ sender: UIButton) {
//        parent.btnCloseTap(sender)
    }
    @IBAction func btnLogoutTap(_ sender: UIButton) {
//        parent.btnSubmitTap(sender)
    }
}
