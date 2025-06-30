//
//  CarListCell.swift
//  CabO
//
//  Created by Octos.
//

import UIKit

class CarListCell: ConstrainedTableViewCell {
    
    static let identifier: String = "carListCell"
    static let normalHeight: CGFloat = 85 * _widthRatio
    
    /// Outlets
    @IBOutlet weak var bgView: UIView!
    @IBOutlet weak var imgCarImage: NRoundImageView!
    @IBOutlet weak var labelCarName: UILabel!
    @IBOutlet weak var labelCarColor: UILabel!
    
    @IBOutlet weak var viewStatus: NRoundView!
    @IBOutlet weak var labelStatus: UILabel!
    @IBOutlet weak var imgStatus: TintImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        viewStatus?.setViewHeight(height: (DeviceType.iPad ? 22 : 18) * _widthRatio)
        imgStatus?.setViewHeight(height: (DeviceType.iPad ? 32 : 28) * _widthRatio)
    }
}

// MARK: - UI Methods
extension CarListCell {
    
    func prepareCarStatusUI(_ status: DocStatus) {
        labelStatus.text = status.title
        labelStatus.textColor = status.statusColor
        viewStatus.borderColor = status.statusColor
        imgStatus.image = status.imgStatus
        imgStatus.tintColor = status.statusColor
    }
    
    func prepareUI(_ car: CarListModel, _ isSelected: Bool = false) {
        bgView.backgroundColor = isSelected ? AppColor.vwBgColor : AppColor.headerBg
        labelCarName.textColor = isSelected ? AppColor.primaryTextDark : AppColor.primaryText
        labelCarColor.textColor = isSelected ? AppColor.primaryTextDark : AppColor.primaryText
        imgCarImage.borderColor = isSelected ? AppColor.primaryTextDark : AppColor.primaryText
        
        imgCarImage?.loadFromUrlString(car.image, placeholder: _carPlaceImage?.withTintColor(isSelected ? AppColor.primaryTextDark : AppColor.primaryText))
        labelCarName.text = car.company
        labelCarColor.text = car.descStr
        
        prepareCarStatusUI(car.carStatus)
    }
}

//MARK: - Register Cell
extension CarListCell {
    
    class func prepareToRegisterCells(_ sender: UITableView) {
        sender.register(UINib(nibName: "CarListCell", bundle: nil), forCellReuseIdentifier: identifier)
    }
}
