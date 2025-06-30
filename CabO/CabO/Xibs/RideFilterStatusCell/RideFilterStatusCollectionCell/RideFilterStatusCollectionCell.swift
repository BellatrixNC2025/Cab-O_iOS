//
//  RideFilterStatusCollectionCell.swift
//  CabO
//
//  Created by Octos.
//

import UIKit

class RideFilterStatusCollectionCell: ConstrainedCollectionViewCell {
    
    static var identifier: String = "RideFilterStatusCollectionCell"
    
    /// Outlets
    @IBOutlet weak var bgView: NRoundView!
    @IBOutlet weak var gradientView: RoundGradientView!
    @IBOutlet weak var lblTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

// MARK: - UI Methods
extension RideFilterStatusCollectionCell {
    
    func prepareUI(_ pref: RideStatus, _ isSelected: Bool = false) {
        gradientView.isHidden = true
        
        lblTitle.text = pref.title
        bgView.backgroundColor = isSelected ? AppColor.vwBgColor : AppColor.headerBg
        lblTitle.textColor = isSelected ? AppColor.primaryTextDark : AppColor.primaryText
    }
    
    func prepareUI(_ type: EmergencyType, _ isSelected: Bool = false) {
        self.bgView.cornerRadious = 0
        lblTitle.text = type.name
        gradientView.isHidden = !isSelected
        
        bgView.backgroundColor = !isSelected ? AppColor.vwBgColor : AppColor.headerBg
        lblTitle.textColor = !isSelected ? AppColor.primaryTextDark : .white
    }
}

//MARK: - Register Cell
extension RideFilterStatusCollectionCell {
    
    class func prepareToRegister(_ sender: UICollectionView) {
        sender.register(UINib(nibName: "RideFilterStatusCollectionCell", bundle: nil), forCellWithReuseIdentifier: identifier)
    }
}
